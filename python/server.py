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

        # If image exists → also compute image + combined
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
def find_matches_robust():
    try:
        data = request.get_json()
        caller_emb = np.array(data.get("embedding", []))
        caller_has_image = bool(data.get("has_image", False))
        current_uid = data.get("uid", "")
        post_type = data.get("type", "")
        post_id = data.get("postID", "")
        selected_date_raw = data.get("date", None)

        if caller_emb.size == 0 or not current_uid or post_type not in ("Lost", "Found"):
            return jsonify({"error": "Invalid request"}), 400

        # Determine opposite post type
        target_type = "Lost" if post_type == "Found" else "Found"
        docs = db.collection("posts").where("type", "==", target_type).get()

        # Convert selected date from Firestore timestamp
        selected_date = None
        if selected_date_raw:
            try:
                selected_date = datetime.fromtimestamp(selected_date_raw["_seconds"])
                selected_date = selected_date.replace(hour=0, minute=0, second=0, microsecond=0)
            except Exception as e:
                print("Error parsing selected_date:", e)
                selected_date = None

        candidates = []
        for doc in docs:
            post = doc.to_dict()

            # Skip same user or claimed posts
            if post.get("uid") == current_uid or post.get("claim_status") is True:
                continue

            # Date filter ±2 days
            if selected_date and post.get("date"):
                post_date = post["date"]
                if hasattr(post_date, "to_datetime"):
                    post_date = post_date.to_datetime()
                if post_date.tzinfo is not None:
                    post_date = post_date.astimezone().replace(tzinfo=None)
                selected_date_naive = selected_date
                post_date = post_date.replace(hour=0, minute=0, second=0, microsecond=0)
                selected_date_naive = selected_date_naive.replace(hour=0, minute=0, second=0, microsecond=0)
                if abs((post_date - selected_date_naive).days) > 2:
                    continue

            text_emb = post.get("embedding_text")
            image_emb = post.get("embedding_image") or []
            combined_emb = post.get("embedding_combined") or text_emb
            if not text_emb:
                continue

            post["_has_image"] = bool(image_emb)
            candidates.append({
                "data": post,
                "text_emb": text_emb,
                "image_emb": image_emb,
                "combined_emb": combined_emb
            })

        # Cosine similarity helper
        def cosine(a, b):
            a, b = np.array(a), np.array(b)
            if np.linalg.norm(a) == 0 or np.linalg.norm(b) == 0:
                return 0.0
            return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

        matches = []
        for cand in candidates:
            post = cand["data"]
            post_has_image = post.get("_has_image", False)

            #The NEW LOGIC:
            # - if both have images → use weighted combined
            # - else → text-only similarity
            if caller_has_image and post_has_image:
                ref_emb = cand["combined_emb"]
                similarity = cosine(caller_emb, ref_emb)
            else:
                # Compare text embeddings only
                similarity = cosine(caller_emb, cand["text_emb"])

            post["similarity_score"] = similarity
            matches.append(post)

        # Filter and sort top matches
        top_matches = sorted(
            [m for m in matches if m["similarity_score"] >= 0.75], 
            key=lambda x: x["similarity_score"],
            reverse=True
        )[:4]

        # Add notifications and print
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
                print(f"Notification error for {match['postID']}: {e}")

        print(f"{len(top_matches)} notifications added successfully!")

        # Return matches
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
        print("Error in robust find_matches:", e)
        return jsonify({"error": str(e)}), 500


# -------------------------------------------------------
# Run the Flask app
# -------------------------------------------------------
if __name__ == "__main__":
    os.makedirs("uploads", exist_ok=True)
    app.run(host="0.0.0.0", port= 5001)
