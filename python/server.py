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
def find_matches():
    try:
        data = request.get_json()
        new_emb = np.array(data.get("embedding", []))
        current_uid = data.get("uid", "")
        post_type = data.get("type", "")
        post_id = data.get("postID", "")
        selected_location = data.get("location", "")
        selected_date_raw = data.get("date", None)
        caller_has_image = bool(data.get("has_image", False))

        if new_emb.size == 0:
            return jsonify({"error": "Embedding is required"}), 400
        if not current_uid:
            return jsonify({"error": "User UID is required"}), 400
        if post_type not in ("Lost", "Found"):
            return jsonify({"error": "Post type must be Lost or Found"}), 400

        # Determine opposite type
        target_type = "Lost" if post_type == "Found" else "Found"

        # Query opposite-type posts
        posts_ref = db.collection("posts").where("type", "==", target_type)
        docs = posts_ref.get()

        # ---------------------------
        # Date conversion
        # ---------------------------
        selected_date = None
        if selected_date_raw:
            try:
                selected_date = datetime.fromtimestamp(selected_date_raw["_seconds"])
                selected_date = selected_date.replace(hour=0, minute=0, second=0, microsecond=0)
            except Exception as e:
                print("Error parsing selected_date:", e)
                selected_date = None

        # IMPORTANT FIX — MUST BE OUTSIDE THE EXCEPT
        candidates = []

        # ---------------------------
        # Build candidate list
        # ---------------------------
        for doc in docs:
            post = doc.to_dict()

            # Skip same user
            if post.get("uid") == current_uid:
                continue

            # Skip claimed
            if post.get("claim_status") is True:
                continue

            # Location filter
            if selected_location and post.get("location") != selected_location:
                continue

            # ---------- DATE FILTER (±2 days) ----------
            if selected_date:
                post_date = post.get("date")
                if not post_date:
                    continue

                try:
                    post_date_dt = post_date.to_datetime()
                except:
                    post_date_dt = post_date

                post_date_norm = post_date_dt.replace(hour=0, minute=0, second=0, microsecond=0)

                if post_date_norm.tzinfo:
                    post_date_norm = post_date_norm.replace(tzinfo=None)
                if selected_date.tzinfo:
                    selected_date_norm = selected_date.replace(tzinfo=None)
                else:
                    selected_date_norm = selected_date

                days_diff = abs((post_date_norm - selected_date_norm).total_seconds() / 86400)
                if days_diff > 2:
                    continue
            # ------------------------------------------------

            # Embedding existence check
            has_new_text = "embedding_text" in post
            has_old_embedding = "embedding" in post

            if not (has_new_text or has_old_embedding):
                continue

            post["_has_image"] = bool(post.get("embedding_image"))
            candidates.append(post)

        if not candidates:
            return jsonify({"matches": []}), 200

        # Cosine similarity helper
        def cosine_similarity(a, b):
            a = np.array(a)
            b = np.array(b)
            return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

        caller_emb = new_emb.tolist()

        # ---------------------------
        # Compute similarity
        # ---------------------------
        for post in candidates:

            # New embedding system
            if "embedding_text" in post:
                text_emb = post["embedding_text"]
                image_emb = post.get("embedding_image", [])
                combined_emb = post.get("embedding_combined", text_emb)

            else:
                # OLD posts — only 1 embedding exists
                text_emb = post["embedding"]
                image_emb = []
                combined_emb = text_emb

            post_has_image = post.get("_has_image", False)

            # Matching rules:
            # both have images → COMBINED
            # otherwise → TEXT
            if caller_has_image and post_has_image:
                ref_emb = combined_emb
            else:
                ref_emb = text_emb

            post["similarity_score"] = cosine_similarity(caller_emb, ref_emb)

        # Sort by similarity
        sorted_candidates = sorted(
            candidates, key=lambda x: x["similarity_score"], reverse=True
        )

        # Apply threshold 0.8
        filtered_matches = [m for m in sorted_candidates if m["similarity_score"] >= 0.8]

        # Keep top 4
        top_matches = filtered_matches[:4]

        # ---------------------------
        # Create notifications
        # ---------------------------
        for match in top_matches:
            notification_ref = db.collection("notifications").document()
            notification_ref.set({
                "notificationID": notification_ref.id,
                "toUserID": match["uid"],
                "userPostID": match["postID"],
                "matchPostID": post_id,
                "matchScore": round(match["similarity_score"], 2),
                "message": f"Possible match found for your post '{match['title']}'.",
                "timestamp": firestore.SERVER_TIMESTAMP,
                "isRead": False,
            })

        print(f"{len(top_matches)} notifications added successfully!")

        # Response for Flutter
        response = [
            {
                "postID": m.get("postID", ""),
                "uid": m.get("uid", ""),
                "title": m.get("title", ""),
                "type": m.get("type", ""),
                "location": m.get("location", ""),
                "picture": m.get("picture", ""),
                "date": m.get("date").isoformat() if m.get("date") else None,
                "similarity_score": round(m["similarity_score"], 4),
            }
            for m in top_matches
        ]

        return jsonify({"matches": response}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------------------------------------
# Run the Flask app
# -------------------------------------------------------
if __name__ == "__main__":
    os.makedirs("uploads", exist_ok=True)
    app.run(host="0.0.0.0", port= 5001)
