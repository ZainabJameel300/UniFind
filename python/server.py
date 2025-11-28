# Some Notes for the Server Code!

#-------------------------!!--------------------------------

# Flask — the class used to create the web application (the server).
# request — object that holds incoming HTTP request data (form fields, files, JSON, headers, etc.).
# jsonify — helper that builds a JSON Response (sets Content-Type: application/json and serializes Python dicts).
# CORS — enables Cross-Origin Resource Sharing. Browsers restrict requests from one origin (your Flutter app served locally or running on a device) to another origin (your Flask server). Enabling CORS lets your Flutter app talk to the Flask server from a different origin.


# server.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
from io import BytesIO
import requests
from sentence_transformers import SentenceTransformer
import os
import numpy as np
from datetime import datetime


# Firebase Admin SDK imports , this will enable us to read from the database
import firebase_admin
from firebase_admin import credentials, firestore

# -------------------------------------------------------
# Flask setup
# -------------------------------------------------------
app = Flask(__name__)
CORS(app)

# -------------------------------------------------------
# Firebase setup
# -------------------------------------------------------
# Initialize Firebase with your service account key
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client() #load our database so we can work on it

# -------------------------------------------------------
# CLIP model setup
# -------------------------------------------------------
print("Loading CLIP model...")
model = SentenceTransformer('clip-ViT-B-32')  # small & standard CLIP via sentence-transformers
print("Model loaded.")

# -------------------------------------------------------
# Helper to download image
# -------------------------------------------------------
def download_image(url):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    return Image.open(BytesIO(resp.content)).convert("RGB")

@app.before_request
def log_request_info():
    print(f"Incoming request: {request.method} {request.path}")


# -------------------------------------------------------
# Generate embedding route
# -------------------------------------------------------
@app.route("/generate_embedding", methods=["POST"])
def generate_embedding():
    description = request.form.get("description", "")
    image_url = request.form.get("image_url", "")

    try:
        # TEXT embedding always
        text_emb = model.encode(description, convert_to_tensor=True, show_progress_bar=False)
        text_emb_list = text_emb.cpu().tolist()

        image_emb_list = []
        combined_list = text_emb_list  # default if no image

        # If image exists ---> also compute image + combined
        if image_url:
            img = download_image(image_url)
            img_emb = model.encode(img, convert_to_tensor=True, show_progress_bar=False)
            image_emb_list = img_emb.cpu().tolist()

            # Combined embedding = average of (text + image)
            combined_list = ((text_emb + img_emb) / 2).cpu().tolist()

        return jsonify({
            "text_embedding": text_emb_list,
            "image_embedding": image_emb_list,
            "combined_embedding": combined_list
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    

# -------------------------------------------------------
# Find matches route 
# -------------------------------------------------------
@app.route("/find_matches", methods=["POST"])
def find_matches_filtered():
    try:
        data = request.get_json()

        # ----------------------------
        # Extract caller data
        # ----------------------------
        text_emb = np.array(data.get("text_embedding", []))
        image_emb = data.get("image_embedding", [])
        combined_emb = np.array(data.get("combined_embedding", []))

        caller_has_image = bool(data.get("has_image", False))
        current_uid = data.get("uid", "")
        post_type = data.get("type", "")
        post_id = data.get("postID", "")
        selected_location = data.get("location", None)
        selected_date_raw = data.get("date", None)

        # Validate
        if text_emb.size == 0 or not current_uid or post_type not in ("Lost", "Found"):
            return jsonify({"error": "Invalid request"}), 400

        # ----------------------------
        # Determine target type should be the oppiste type (opposite)
        # ----------------------------
        target_type = "Lost" if post_type == "Found" else "Found"
        posts_ref = db.collection("posts").where("type", "==", target_type)
        docs = posts_ref.get()

        # ----------------------------
        # This ensures that the date versions between firebase and python don't have aproblem with eachother
        # ----------------------------
        selected_date = None
        if selected_date_raw:
            try:
                selected_date = datetime.fromtimestamp(selected_date_raw["_seconds"])
                selected_date = selected_date.replace(hour=0, minute=0, second=0, microsecond=0)
            except:
                selected_date = None

        # ----------------------------
        # Collect candidate posts
        # ----------------------------
        candidates = []
        for doc in docs:
            post = doc.to_dict()

            # Skip same user
            if post.get("uid") == current_uid:
                continue

            # Skip claimed items
            if post.get("claim_status") is True:
                continue

            # Filter by location
            if selected_location and post.get("location") != selected_location:
                continue

            # Filter by date ±2 days
            if selected_date and post.get("date"):
                post_date = post["date"]     # Firestore timestamp object

                # Convert Firestore timestamp to Python datetime
                if hasattr(post_date, "timestamp"):
                    post_date = datetime.fromtimestamp(post_date.timestamp())

                # Normalize timezone if needed
                if post_date.tzinfo is not None:
                    post_date = post_date.replace(tzinfo=None)

                selected_date_naive = selected_date.replace(tzinfo=None)

                # If difference > 2 days --> skip
                if abs((post_date - selected_date_naive).days) > 2:
                    continue

            if "embedding_text" not in post:
                continue

            text2 = post["embedding_text"]
            image2 = post.get("embedding_image") or []
            combined2 = post.get("embedding_combined") or text2
            has_image2 = bool(image2)

            candidates.append({
                "data": post,
                "text_emb": text2,
                "image_emb": image2,
                "combined_emb": combined2,
                "_has_image": has_image2
            })

        # ----------------------------
        # Cosine similarity
        # ----------------------------
        def cosine(a, b):
            a, b = np.array(a), np.array(b)
            if np.linalg.norm(a) == 0 or np.linalg.norm(b) == 0:
                return 0.0
            return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

        # ----------------------------
        # Compute similarities
        # ----------------------------
        matches = []
        for cand in candidates:
            post = cand["data"]
            post_has_image = cand["_has_image"]

            if caller_has_image and post_has_image:
                # both have images ---> combined vs combined
                similarity = cosine(combined_emb, cand["combined_emb"])
            else:
                # otherwise --> text vs text
                similarity = cosine(text_emb, cand["text_emb"])

            post["similarity_score"] = similarity
            matches.append(post)

        # ----------------------------
        # Return top matches >= 0.75
        # ----------------------------
        top_matches = sorted(
            [m for m in matches if m["similarity_score"] >= 0.75],
            key=lambda x: x["similarity_score"],
            reverse=True
        )[:4]

        # ----------------------------
        # Create notifications
        # ----------------------------
        for match in top_matches:
            try:
                notification_ref = db.collection("notifications").document()
                notification_data = {
                    "notificationID": notification_ref.id,
                    "toUserID": match["uid"],
                    "userPostID": match["postID"],
                    "matchPostID": post_id,
                    "matchScore": round(match["similarity_score"], 2),
                    "message": f"Possible match found for your post '{match['title']}'.",
                    "timestamp": firestore.SERVER_TIMESTAMP,
                    "isRead": False,
                }
                notification_ref.set(notification_data)
            except Exception as e:
                print(f"Notification error: {e}")

        # ----------------------------
        # The response payload
        # ----------------------------
        response = [{
            "postID": m.get("postID"),
            "uid": m.get("uid"),
            "title": m.get("title"),
            "type": m.get("type"),
            "location": m.get("location"),
            "picture": m.get("picture"),
            "date": m.get("date").isoformat() if m.get("date") else None,
            "similarity_score": round(m["similarity_score"], 4)
        } for m in top_matches]

        return jsonify({"matches": response}), 200

    except Exception as e:
        print("Error in find_matches_filtered:", e)
        return jsonify({"error": str(e)}), 500

# -------------------------------------------------------
# Run the Flask app
# -------------------------------------------------------
if __name__ == "__main__":
    os.makedirs("uploads", exist_ok=True)
    app.run(host="0.0.0.0", port= 5001)
