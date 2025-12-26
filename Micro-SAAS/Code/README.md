# Micro-SAAS Backend

This is the backend for the Micro-SAAS application that converts .docx files to PDF.

## Setup

1. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

2. Run the Flask application:
   ```bash
   python app.py
   ```

The server will start on http://127.0.0.1:5000

## Endpoints

- `GET /`: Returns "Hello, World!" - basic health check
- `GET /index`: Serves the main HTML page for file upload
- `POST /upload`: Accepts .docx file uploads with validation
- Static files are served from `/static/` path

## Port Configuration

The Flask backend runs on **port 5000**, while the frontend HTML may be served on a different port (e.g., 5502 by VS Code's live server).

- **Backend API**: `http://127.0.0.1:5000/`
- **Frontend**: Served by your development server (port may vary)
- **JavaScript**: Makes API calls to port 5000 for uploads and server checks

### Upload Endpoint

- Accepts multipart/form-data with a 'file' field
- Validates file type (.docx only)
- Validates file size (max 10MB)
- Saves file to 'uploads/' directory
- Returns JSON response with success/error message

## Testing

To test the application, run the included test script:

```bash
python test_app.py
```

This will:

- Start the Flask server automatically
- Test the "Hello, World!" endpoint
- Test file upload with a valid .docx file
- Test file upload with an invalid file type
- Clean up all test files

**Expected output:**

```
Hello World response: Hello, World!
Upload response: {'filename': 'test.docx', 'message': 'File uploaded successfully'}
Invalid file type response: {'error': 'Invalid file type. Only .docx files are allowed.'}
All tests passed!
```

## Testing the Full Application

### Option 1: Quick Launch (Recommended)

Run the launcher script to start the server and open your browser automatically:

```bash
./run_app.sh
```

### Option 2: Manual Launch

1. Start the server:

   ```bash
   python app.py
   ```

2. Open your browser and go to:

   ```
   http://127.0.0.1:5000/index
   ```

3. Select a .docx file and click "Convert"
4. The JavaScript will check server status and upload the file

### Manual Testing

If you prefer to test manually:

1. Start the server:

   ```bash
   python app.py
   ```

2. Open your browser and go to:

   ```
   http://127.0.0.1:5000/index
   ```

3. Select a .docx file and click "Convert"
4. The JavaScript will check server status and upload the file

### Troubleshooting "Unexpected end of JSON input" Error

This error occurs when the JavaScript tries to parse a response as JSON but receives invalid or empty data. Here's how to debug:

1. **Check if server is running**: Make sure `python app.py` is running
2. **Open browser console**: Press F12 and check the Console tab for detailed error messages
3. **Test with simple HTML**: Open `test_upload.html` in your browser for isolated testing
4. **Check network tab**: Look at the actual HTTP request/response in browser dev tools

**Common causes:**

- Server not running when upload is attempted
- CORS issues (should be resolved with flask-cors)
- Server returning HTML error page instead of JSON
- Network connectivity issues

### Direct API Testing

Test the upload endpoint directly:

```bash
# Create test file
echo "test content" > test.docx

# Test upload
curl -X POST -F "file=@test.docx" http://127.0.0.1:5000/upload

# Expected response:
# {"filename": "test.docx", "message": "File uploaded successfully"}
```

## Troubleshooting

### MIME Type Errors

If you see errors like "MIME type ('text/html') is not a supported stylesheet":

1. **Check server status**: Ensure Flask server is running on port 5000
2. **Verify static paths**: HTML should reference `/static/css/style.css` and `/static/js/script.js`
3. **File existence**: Confirm CSS/JS files exist in `../static/` directory
4. **Browser cache**: Hard refresh (Ctrl+F5) to clear cached resources

### 404 Errors for Static Files

- Static files are served from `/static/<path>` routes
- Flask automatically handles MIME types for `.css`, `.js` extensions
- Check browser network tab for exact failed requests

### Upload Errors

- "Unexpected end of JSON input": Server not running or network issue
- "Invalid file type": Only `.docx` files are accepted
- Check browser console and server logs for detailed error messages
