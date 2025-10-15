# Some Notes for the Server Code!

#-------------------------!!--------------------------------

# Flask — the class used to create the web application (the server).
# request — object that holds incoming HTTP request data (form fields, files, JSON, headers, etc.).
# jsonify — helper that builds a JSON Response (sets Content-Type: application/json and serializes Python dicts).
# CORS — enables Cross-Origin Resource Sharing. Browsers restrict requests from one origin (your Flutter app served locally or running on a device) to another origin (your Flask server). Enabling CORS lets your Flutter app talk to the Flask server from a different origin.


from flask import Flask, request, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)  # Allow connection from Flutter

@app.route('/test', methods=['POST'])
def test_connection():
    title = request.form.get('title')
    image = request.files.get('image')
    
    print(f"📩 Received title: {title}")
    print(f"📸 Received image: {image.filename if image else 'No image'}")

    # Just saving temporarily to confirm it’s working
    if image:
        save_path = os.path.join("uploads", image.filename)
        os.makedirs("uploads", exist_ok=True)
        image.save(save_path)

    return jsonify({
        "message": f"Received '{title}' and image successfully!"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
