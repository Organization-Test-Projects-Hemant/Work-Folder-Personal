import requests
import os
import threading
import time
from app import app

def run_app():
    app.run(debug=False, host='127.0.0.1', port=5000, use_reloader=False)

# Start the Flask app in a separate thread
server_thread = threading.Thread(target=run_app, daemon=True)
server_thread.start()

# Wait for the server to start
time.sleep(2)

try:
    # Test the hello world endpoint
    response = requests.get('http://127.0.0.1:5000/')
    print(f"Hello World response: {response.text}")

    # Test the index page
    response = requests.get('http://127.0.0.1:5000/index')
    if response.status_code == 200 and 'DOCX to PDF Converter' in response.text:
        print("Index page served successfully")
    else:
        print(f"Index page test failed: {response.status_code}")

    # Create a dummy docx file for testing
    with open('test.docx', 'w') as f:
        f.write('This is a test docx file')

    # Test the upload endpoint
    with open('test.docx', 'rb') as f:
        files = {'file': f}
        response = requests.post('http://127.0.0.1:5000/upload', files=files)
        print(f"Upload response: {response.json()}")

    # Test invalid file type
    with open('test.txt', 'w') as f:
        f.write('This is a test txt file')

    with open('test.txt', 'rb') as f:
        files = {'file': f}
        response = requests.post('http://127.0.0.1:5000/upload', files=files)
        print(f"Invalid file type response: {response.json()}")

    print("All tests passed!")

except Exception as e:
    print(f"Test failed: {e}")

