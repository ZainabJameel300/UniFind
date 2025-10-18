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
    """
    Expects form fields:
      - title (string)
      - image_url (string)  <-- URL to the image (Firebase download URL)
    Returns JSON: { "embedding": [float, float, ...] }
    """
    title = request.form.get("title", "")
    image_url = request.form.get("image_url", "")

    if not image_url:
        return jsonify({"error": "image_url is required"}), 400

    try:
        # get image (from Firebase Storage link or elsewhere)
        img = download_image(image_url)

        # encode text and image separately, then combine
        text_emb = model.encode(title, convert_to_tensor=True, show_progress_bar=False)
        img_emb = model.encode(img, convert_to_tensor=True, show_progress_bar=False)

        combined = ((text_emb + img_emb) / 2).cpu().tolist()  # convert to python list

        return jsonify({"embedding": combined})
    except Exception as e:
        # return helpful error for debugging
        return jsonify({"error": str(e)}), 500
    
# -------------------------------------------------------
# Find matches route
# -------------------------------------------------------
@app.route("/find_matches", methods=["POST"])
def find_matches():
    """
    Expects JSON:
    {
        "embedding": [float, ...],
        "uid": "current_user_uid",
        "type": "Lost" or "Found"
    }
    Returns: top 3 similar items from Firestore excluding user's own posts and only of the opposite type.
    """
    try:
        data = request.get_json()
        new_emb = np.array(data.get("embedding", []))
        current_uid = data.get("uid", "")
        post_type = data.get("type", "")

        if new_emb.size == 0:
            return jsonify({"error": "Embedding is required"}), 400
        if not current_uid:
            return jsonify({"error": "User UID is required"}), 400
        if post_type not in ("Lost", "Found"):
            return jsonify({"error": "Post type is required and must be 'Lost' or 'Found'"}), 400

        # Determine opposite type to search
        target_type = "Lost" if post_type == "Found" else "Found"

        # Query Firestore for posts with the opposite type (avoid inequality queries combination issues)
        posts_ref = db.collection("posts").where("type", "==", target_type)
        docs = posts_ref.get()

        candidates = []
        for doc in docs:
            post = doc.to_dict()
            # skip posts without embeddings or posts created by the same user
            if "embedding" in post and post.get("uid") != current_uid:
                candidates.append(post)

        if not candidates:
            return jsonify({"matches": []}), 200

        # Compute cosine similarity
        def cosine_similarity(a, b):
            return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

        for post in candidates:
            post_emb = np.array(post["embedding"])
            post["similarity_score"] = cosine_similarity(new_emb, post_emb)

        # Sort descending by similarity and take top 3
        top_matches = sorted(candidates, key=lambda x: x["similarity_score"], reverse=True)[:3]

        # Return only relevant fields
        response = [
            {
                "postID": m["postID"],
                "title": m.get("title", ""),
                "type": m.get("type", ""),
                "location": m.get("location", ""),
                "picture": m.get("picture", ""),
                "similarity_score": round(m["similarity_score"], 4)
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
    app.run(host="0.0.0.0", port=5000)
