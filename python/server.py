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
#  Test Firestore connection route , this just to test that python can read from the DB!
# -------------------------------------------------------
@app.route("/test_firestore", methods=["GET"])
def test_firestore():
    """
    Fetch a few documents from Firestore to confirm connection.
    """
    try:
        posts_ref = db.collection("posts").limit(3)
        docs = posts_ref.get()
        results = [doc.to_dict() for doc in docs]
        return jsonify(results), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# -------------------------------------------------------
# Run the Flask app
# -------------------------------------------------------
if __name__ == "__main__":
    os.makedirs("uploads", exist_ok=True)
    app.run(host="0.0.0.0", port=5000)
