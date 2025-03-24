const express = require('express');
const ethers = require('ethers');
const app = express();
app.use(express.json());

// Sepolia testnet provider
const provider = new ethers.providers.JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/-08irZtFq0AjAZVdTJyoCnLQ33YZVq-3');

// Relayer's wallet (replace with your private key)
const wallet = new ethers.Wallet('f4aff8d2f05271e4ead222de409d32ab8dad28789b26d96cd3cf8cb8e4a2a7c1', provider);

// API endpoint to relay transactions
app.post('/relay', async (req, res) => {
  const signedTransaction = req.body.signedTransaction;
  try {
    const txResponse = await wallet.sendTransaction(signedTransaction);
    res.send(`Transaction sent: ${txResponse.hash}`);
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Start the server
app.listen(3000, () => {
  console.log('Relayer server listening on port 3000');
});