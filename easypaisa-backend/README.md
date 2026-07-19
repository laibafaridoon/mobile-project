# Secure Easypaisa Gateway Server

This is the secure backend server component designed to intermediate between the **Smart Hospital Flutter App** and the **Official Easypaisa Merchant APIs**.

By keeping your merchant credentials, Store ID, and Hash Key on this server, we guarantee that decompiled client APKs cannot expose your gateway credentials.

---

## 🛠️ Setup & Installation

### 1. Prerequisites
- [Node.js](https://nodejs.org/) (v16 or higher)
- npm (Node Package Manager)

### 2. Install Dependencies
Run the following command inside this directory:
```bash
npm install
```

### 3. Configure Environment Variables
Copy the `.env.example` file to `.env`:
```bash
cp .env.example .env
```
Open `.env` and fill in your merchant details:
- `EASYPAISA_STORE_ID`: Provided by Easypaisa team.
- `EASYPAISA_HASH_KEY`: Your digital HMAC signature salt.
- `CALLBACK_URL`: Webhook URL for transaction confirmations.

---

## 🚀 Running the Server

### Development Mode (with hot-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

---

## 📡 API Reference

### 1. Create Transaction (Initiate Payment)
- **Endpoint:** `POST /api/payment/create`
- **Request Body:**
  ```json
  {
    "appointmentId": "appointment-uuid-v4-string",
    "patientId": "user-uid-string",
    "doctorId": "doctor-id-string",
    "amount": 2500.00,
    "mobileNumber": "03001234567",
    "email": "patient@gmail.com"
  }
  ```
- **Response (Success):**
  ```json
  {
    "success": true,
    "transactionId": "99988221",
    "message": "Payment request initiated. Please check your phone for the PIN entry prompt."
  }
  ```

### 2. Verify Transaction Status
- **Endpoint:** `POST /api/payment/verify`
- **Request Body:**
  ```json
  {
    "appointmentId": "appointment-uuid-v4-string",
    "transactionId": "99988221"
  }
  ```
- **Response (Success):**
  ```json
  {
    "success": true,
    "status": "Paid",
    "message": "Payment verified successfully."
  }
  ```

### 3. IPN Webhook Callback
- **Endpoint:** `POST /api/payment/callback`
- **Usage:** Triggered automatically by Easypaisa servers asynchronously once the user enters their wallet credentials/PIN.
- **Response:** Sends `200 OK` upon receiving response checks.
