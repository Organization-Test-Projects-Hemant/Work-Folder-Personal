

### **1. Main App Function**

*   **Core Purpose:** Provide a simple, single-purpose web service to convert a user's `.docx` (Microsoft Word) file into a `.pdf` file.
*   **User Journey:**
    1.  The user arrives at a clean, straightforward webpage.
    2.  They are prompted to upload one `.docx` file.
    3.  After selecting a file, they are guided to make a $1.00 payment.
    4.  Once the payment is confirmed, the system automatically starts the file conversion in the background.
    5.  The user is taken to a success page where they can download their converted `.pdf` file.
*   **Key Features:**
    *   Accepts `.docx` file uploads.
    *   Integrates a payment step before the service is rendered.
    *   Delivers the final `.pdf` file back to the user for download.

### **2. Tech Stack**

*   **Backend:** Python (with Flask framework)
*   **Frontend:** HTML, CSS, JavaScript
*   **File Conversion Tool:** Pandoc
*   **Version Control:** Git & GitHub

### **3. Admin & Analytics**

*   **Operational Dashboard (Our Custom Build):**
    *   A private, password-protected admin area on our website.
    *   Provides at-a-glance statistics: total conversions today, revenue, pending jobs, and failures.
    *   Displays a real-time list of all conversion jobs, showing the status of each (e.g., `awaiting_payment`, `completed`, `failed`).
*   **Payment Management (Provided by Stripe):**
    *   We will use the pre-built Stripe Dashboard for all financial management.
    *   It will allow us to see detailed payment histories, reasons for failed payments, issue refunds, and generate financial reports.
*   **Website Traffic Analytics (Provided by Google Analytics):**
    *   We will use the standard Google Analytics dashboard to understand user behavior.
    *   It will show us where our users are coming from, how they found the site, and how they navigate through the pages.

### **4. Payment**

*   **Payment Processor:** Stripe.
*   **Process Flow:** We will use Stripe Checkout, which provides a secure, externally-hosted page for payment.
    *   Our application tells Stripe to create a payment session for $1.00.
    *   The user is redirected to Stripe to enter their card details.
    *   Our application receives a secure, automated notification (a "webhook") from Stripe once the payment is successful.
*   **Mode:** The entire system will be built and tested using Stripe's "Test Mode" with fake credit card numbers.

### **5. Infrastructure (DigitalOcean)**

*   **Application Hosting (Compute):**
    *   **Service:** DigitalOcean App Platform.
    *   **Function:** This is where our main Python application code will run. It will handle all the logic, from file uploads to starting the conversion.
*   **File Storage:**
    *   **Service:** DigitalOcean Spaces.
    *   **Function:** All user-uploaded `.docx` files and the resulting `.pdf` files will be stored here. This keeps them safe and separate from the application server.
*   **Database:**
    *   **Service:** DigitalOcean Managed PostgreSQL.
    *   **Function:** This will store the records and status of every conversion job, allowing our admin dashboard to track the entire process.
	
	