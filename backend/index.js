// index.js in the 'backend' folder

const express = require('express');
const app = express();
const PORT = 3000; // You can use any port

app.get('/', (req, res) => {
  res.send('Hello from the Real Estate App Backend!');
});

app.listen(PORT, () => {
  console.log(`✅ Server is running on http://localhost:${PORT}`);
});