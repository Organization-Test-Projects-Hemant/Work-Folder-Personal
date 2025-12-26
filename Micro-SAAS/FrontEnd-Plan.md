# Front End Structure and File Creation

This document outlines the structure and files to be created for the front end of the DOCX to PDF converter.

## File Structure

- **static/**: Folder for static files
  - **css/**: Folder for CSS files
    - `style.css`: Styles for the main page
  - **js/**: Folder for JavaScript files
    - `script.js`: Client-side logic for handling file uploads
  - **html/**: Folder for HTML files
    - `index.html`: Main page for user interaction
    - `success.html`: Page displayed after successful payment
    - `cancel.html`: Page displayed after payment cancellation

## Steps to Create Files

1. Create the `static/` folder in the project root.
2. Inside `static/`, create `css/`, `js/`, and `html/` folders.
3. Create the following files:
   - `static/css/style.css`
   - `static/js/script.js`
   - `static/html/index.html`
   - `static/html/success.html`
   - `static/html/cancel.html`

Plan to Implement the Front End
Based on the requirements, here's a phased step-by-step plan to build the front end (HTML, CSS, JavaScript) for the DOCX to PDF converter. This focuses solely on the user interface and client-side logic, assuming the backend is already set up.

Phase 1: Set Up Project Structure
Create a dedicated folder for front-end files (e.g., static/ or templates/ in the project root).
Organize subfolders for HTML pages, CSS stylesheets, and JavaScript files.
Ensure the folder is accessible from the Flask backend for serving static files.
Phase 2: Build the Main Page (index.html)
Create an HTML file for the homepage with a clear heading (e.g., "DOCX to PDF Converter").
Add a file input element restricted to .docx files only.
Include a "Convert" button for user interaction.
Add a placeholder div for displaying status messages (e.g., "Uploading...", "Redirecting to payment...").
Link the CSS and JavaScript files in the HTML head and body.
Phase 3: Implement Styling (style.css)
Create a CSS file to style the main page for a clean, presentable look.
Apply basic layout: center content, use readable fonts, and ensure responsive design.
Style the file input, button, and message area with clear alignment and visual feedback (e.g., hover effects).
Add minimal branding elements if needed, keeping it simple and professional.
Phase 4: Write Client-Side JavaScript (script.js)
Create a JavaScript file to handle user interactions on the main page.
Implement logic to capture the selected file when the "Convert" button is clicked.
Send the file via AJAX (or Fetch API) to the backend's /upload endpoint.
Handle the response: extract the Stripe Session ID from the backend.
Use Stripe.js to redirect the user to the Stripe Checkout page with the Session ID.
Add error handling for failed uploads or invalid responses, displaying messages in the placeholder div.
Phase 5: Create Success and Cancel Pages
Build a success page (e.g., success.html) with a message confirming payment and indicating conversion is in progress.
Add JavaScript to poll the backend periodically (e.g., every few seconds) to check if the PDF is ready.
Once ready, display a download link for the PDF file.
Build a cancel page (e.g., cancel.html) with a simple message about payment cancellation and an option to try again.
Ensure both pages link back to the main page and include the same CSS for consistency.
Phase 6: Integrate and Test
Link all pages and files together, ensuring routes match the backend (e.g., /success, /cancel).
Test the front end in a browser: simulate file selection, upload, and redirects (using test Stripe keys).
Verify responsiveness on different devices and browsers.
Add basic accessibility features (e.g., alt text, keyboard navigation) if time allows.
This plan keeps the front end simple, focused on the user journey, and integrates with the backend via AJAX and redirects.
