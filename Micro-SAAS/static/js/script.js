// Function to check if the server is running
async function checkServerStatus () {
  try {
    const response = await fetch ('http://127.0.0.1:5000/', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return response.ok && response.status === 200;
  } catch (error) {
    console.log ('Server status check failed:', error);
    return false;
  }
}

// Function to start the server (this will show instructions since JS can't start Python server)
function startServer () {
  alert (
    'Python server is not running. Please start it by running:\n\ncd Micro-SAAS/Code\npython app.py\n\nThen refresh this page.'
  );
  return false;
}

document
  .getElementById ('convertButton')
  .addEventListener ('click', async function () {
    const fileInput = document.getElementById ('fileInput');
    const statusMessage = document.getElementById ('statusMessage');

    // Clear previous messages
    statusMessage.textContent = '';
    statusMessage.style.color = 'black';

    if (fileInput.files.length === 0) {
      statusMessage.textContent = 'Please select a .docx file.';
      statusMessage.style.color = 'red';
      return;
    }

    const selectedFile = fileInput.files[0];

    // Validate file type
    if (!selectedFile.name.toLowerCase ().endsWith ('.docx')) {
      statusMessage.textContent = 'Please select a valid .docx file.';
      statusMessage.style.color = 'red';
      return;
    }

    // Check if server is running
    const serverRunning = await checkServerStatus ();
    if (!serverRunning) {
      statusMessage.textContent = 'Server is not running. Starting server...';
      statusMessage.style.color = 'orange';

      // Try to start server (will show alert with instructions)
      if (!startServer ()) {
        return;
      }
    }

    // Show uploading message
    statusMessage.textContent = 'Uploading file...';
    statusMessage.style.color = 'blue';

    const formData = new FormData ();
    formData.append ('file', selectedFile);

    try {
      console.log ('Starting upload request to http://127.0.0.1:5000/upload');
      const response = await fetch ('http://127.0.0.1:5000/upload', {
        method: 'POST',
        body: formData,
      });

      console.log ('Upload response status:', response.status);
      console.log ('Upload response ok:', response.ok);

      // Check if response is ok before trying to parse JSON
      if (!response.ok) {
        // If server returns error status, try to get text response
        const errorText = await response.text ();
        console.error ('Server error response:', errorText);
        throw new Error (`Server error (${response.status}): ${errorText}`);
      }

      // Try to parse as JSON
      let data;
      try {
        const responseText = await response.text ();
        console.log ('Raw response text:', responseText);
        data = JSON.parse (responseText);
        console.log ('Parsed JSON data:', data);
      } catch (jsonError) {
        console.error ('JSON parsing failed:', jsonError);
        throw new Error (`Invalid response format: ${jsonError.message}`);
      }

      if (data.message && data.filename) {
        statusMessage.textContent = `File uploaded successfully: ${data.filename}`;
        statusMessage.style.color = 'green';

        // Here you would typically proceed to payment processing
        // For now, we'll just show the success message
        setTimeout (() => {
          statusMessage.textContent +=
            '\n\nNext step: Payment processing (to be implemented)';
        }, 1000);
      } else {
        statusMessage.textContent =
          'Upload failed: ' + (data.error || 'Unknown error');
        statusMessage.style.color = 'red';
      }
    } catch (error) {
      console.error ('Upload error details:', error);
      statusMessage.textContent = 'Upload failed: ' + error.message;
      statusMessage.style.color = 'red';
    }
  });

// Check server status on page load
window.addEventListener ('load', async function () {
  const statusMessage = document.getElementById ('statusMessage');
  const serverRunning = await checkServerStatus ();

  if (!serverRunning) {
    statusMessage.textContent =
      'Warning: Python server is not running. Please start it first.';
    statusMessage.style.color = 'orange';
  }
});
