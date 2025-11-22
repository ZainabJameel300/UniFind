# migrate_old_embeddings.py
import firebase_admin
from firebase_admin import credentials, firestore
from sentence_transformers import SentenceTransformer
from PIL import Image
import requests
from io import BytesIO
import numpy as np

# -----------------------
# Firebase Setup
# -----------------------
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# -----------------------
# CLIP Model
# -----------------------
model = SentenceTransformer('clip-ViT-B-32')
print("Model Loaded!")

# -----------------------
# Download Image Helper
# -----------------------
def download_image(url):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    return Image.open(BytesIO(resp.content)).convert("RGB")

# -----------------------
# Process All Posts
# -----------------------
posts_ref = db.collection("posts").stream()

for doc in posts_ref:
    data = doc.to_dict()
    post_id = doc.id

    print(f"Processing Post: {post_id}")

    description = data.get("description", "")
    picture_url = data.get("picture", "")

    # Compute text embedding
    text_emb = model.encode(description).tolist()

    # Compute image embedding (if exists)
    if picture_url:
        try:
            img = download_image(picture_url)
            img_emb = model.encode(img).tolist()
        except Exception as e:
            print(f"Image error for {post_id}: {e}")
            img_emb = None
    else:
        img_emb = None

    # Compute combined (only if image exists)
    if img_emb is not None:
        combined = ((np.array(text_emb) + np.array(img_emb)) / 2).tolist()
    else:
        combined = text_emb  # fallback to text only

    # Update Firestore
    db.collection("posts").document(post_id).update({
        "embedding_text": text_emb,
        "embedding_image": img_emb,
        "embedding_combined": combined
    })

    print(f"Updated: {post_id}")

print("Migration finished successfully!")
