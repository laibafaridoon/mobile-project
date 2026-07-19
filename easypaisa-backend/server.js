const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS so Flutter app can communicate with the backend
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configuration constants from environment
const STORE_ID = process.env.EASYPAISA_STORE_ID || '12345';
const HASH_KEY = process.env.EASYPAISA_HASH_KEY || 'demohashkey12345';
const EASYPAISA_INITIATE_URL = process.env.EASYPAISA_INITIATE_URL || 'https://easypay.easypaisa.com.pk/easypay-service/rest/v4/initiate-transaction';
const EASYPAISA_VERIFY_URL = process.env.EASYPAISA_VERIFY_URL || 'https://easypay.easypaisa.com.pk/easypay-service/rest/v4/confirm-transaction';

// In-memory simple database to simulate transaction storage (in production, use Firestore Admin SDK or DB)
const transactions = {};

/**
 * Endpoint to initiate a payment transaction.
 * Request body: { appointmentId, patientId, doctorId, amount, mobileNumber, email }
 */
app.post('/api/payment/create', async (req, res) => {
  const { appointmentId, patientId, doctorId, amount, mobileNumber, email } = req.body;

  if (!appointmentId || !amount || !mobileNumber) {
    return res.status(400).json({
      success: false,
      message: 'Missing required parameters: appointmentId, amount, and mobileNumber are required.',
    });
  }

  // 1. Arrange parameters exactly in the sequence defined by the Easypaisa integration spec
  const orderRefNum = appointmentId;
  const transAmount = parseFloat(amount).toFixed(2);
  const callbackUrl = process.env.CALLBACK_URL || 'http://localhost:5000/api/payment/callback';

  // String format pattern: storeId=XXXX&orderId=XXXX&amount=XXXX&mobileNo=XXXX
  const hashString = `storeId=${STORE_ID}&orderId=${orderRefNum}&amount=${transAmount}&mobileNo=${mobileNumber}`;

  // 2. Generate HMAC-SHA256 signature securely on the server
  let merchantHashedVal = '';
  try {
    const hmac = crypto.createHmac('sha256', HASH_KEY);
    hmac.update(hashString);
    merchantHashedVal = hmac.digest('hex');
  } catch (err) {
    console.error('[Crypto Error] Signature generation failed:', err);
    return res.status(500).json({ success: false, message: 'Internal cryptographical signing error.' });
  }

  // 3. Construct API Payload for Easypaisa
  const payload = {
    storeId: STORE_ID,
    orderId: orderRefNum,
    transactionAmount: transAmount,
    transactionType: 'MA', // Mobile Account (OTC)
    mobileAccountNo: mobileNumber,
    emailAddress: email || 'patient@smarthospital.com',
    merchantHashedVal: merchantHashedVal,
    postBackURL: callbackUrl
  };

  try {
    console.log('[Easypaisa] Sending initiate payload:', payload);
    
    // In Sandbox, we might mock this call or handle the real sandbox API
    if (process.env.MOCK_EASYPAISA === 'true') {
      const mockTxnId = `EP-TXN-${Date.now()}`;
      const mockRef = `EP-REF-${Math.floor(Math.random() * 900000 + 100000)}`;
      
      transactions[orderRefNum] = {
        appointmentId: orderRefNum,
        transactionId: mockTxnId,
        paymentReference: mockRef,
        amount: transAmount,
        status: 'Pending',
        createdAt: new Date(),
      };

      return res.status(200).json({
        success: true,
        transactionId: mockTxnId,
        paymentReference: mockRef,
        message: 'Mock initiation successful. Push prompt simulated.',
      });
    }

    const response = await axios.post(EASYPAISA_INITIATE_URL, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    console.log('[Easypaisa] Response received:', response.data);

    if (response.data && response.data.responseCode === '0000') {
      const txnId = response.data.transactionId;
      
      transactions[orderRefNum] = {
        appointmentId: orderRefNum,
        transactionId: txnId,
        amount: transAmount,
        status: 'Pending',
        createdAt: new Date(),
      };

      return res.status(200).json({
        success: true,
        transactionId: txnId,
        message: 'Payment request initiated. Please check your phone for the PIN entry prompt.',
      });
    } else {
      return res.status(400).json({
        success: false,
        message: response.data.responseDesc || 'Payment initiation failed.',
      });
    }
  } catch (error) {
    console.error('[Easypaisa API Error]:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to communicate with Easypaisa Merchant Gateways.',
    });
  }
});

/**
 * Endpoint to verify a transaction's status.
 * Request body: { appointmentId, transactionId }
 */
app.post('/api/payment/verify', async (req, res) => {
  const { appointmentId, transactionId } = req.body;

  if (!appointmentId) {
    return res.status(400).json({ success: false, message: 'appointmentId is required.' });
  }

  // Check in memory db first
  const txnRecord = transactions[appointmentId];

  try {
    if (process.env.MOCK_EASYPAISA === 'true') {
      if (txnRecord) {
        txnRecord.status = 'Paid';
        txnRecord.updatedAt = new Date();
      }
      return res.status(200).json({
        success: true,
        status: 'Paid',
        message: 'Transaction successfully verified (Mock Mode).',
      });
    }

    // Call official Easypaisa status verification endpoint
    const payload = {
      storeId: STORE_ID,
      transactionId: transactionId || txnRecord?.transactionId,
      orderId: appointmentId
    };

    const response = await axios.post(EASYPAISA_VERIFY_URL, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    if (response.data && response.data.responseCode === '0000') {
      if (txnRecord) {
        txnRecord.status = 'Paid';
        txnRecord.updatedAt = new Date();
      }
      return res.status(200).json({
        success: true,
        status: 'Paid',
        message: 'Payment verified successfully.',
      });
    } else {
      return res.status(400).json({
        success: false,
        status: 'Failed',
        message: response.data.responseDesc || 'Verification checks failed.',
      });
    }
  } catch (error) {
    console.error('[Verify API Error]:', error.message);
    return res.status(500).json({
      success: false,
      status: 'Failed',
      message: 'Could not contact verification service.',
    });
  }
});

/**
 * Endpoint to fetch the current payment status of an appointment.
 */
app.get('/api/payment/status/:orderId', (req, res) => {
  const { orderId } = req.params;
  const txnRecord = transactions[orderId];

  if (!txnRecord) {
    return res.status(404).json({ success: false, message: 'Transaction record not found.' });
  }

  return res.status(200).json({
    success: true,
    status: txnRecord.status,
  });
});

/**
 * Webhook/Callback receiver.
 * Easypaisa triggers this IPN callback endpoint asynchronously after a transaction completes.
 */
app.post('/api/payment/callback', (req, res) => {
  console.log('[Easypaisa Webhook Received]:', req.body);

  const { orderId, transactionId, responseCode, responseDesc } = req.body;

  if (orderId && responseCode === '0000') {
    const txnRecord = transactions[orderId];
    if (txnRecord) {
      txnRecord.status = 'Paid';
      txnRecord.transactionId = transactionId || txnRecord.transactionId;
      txnRecord.updatedAt = new Date();
    } else {
      transactions[orderId] = {
        appointmentId: orderId,
        transactionId: transactionId,
        status: 'Paid',
        createdAt: new Date(),
        updatedAt: new Date(),
      };
    }
    console.log(`[Webhook] Order ${orderId} marked as PAID.`);
  } else {
    console.warn(`[Webhook] Payment failed or incomplete for order ${orderId}: ${responseDesc}`);
  }

  // Always return success status to Easypaisa to prevent duplicate callbacks
  return res.status(200).send('OK');
});

app.listen(PORT, () => {
  console.log(`[Server] ✓ Secure Easypaisa Gateway running on http://localhost:${PORT}`);
});
