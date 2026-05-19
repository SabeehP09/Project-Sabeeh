const express = require('express');
const os = require('os');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// File to persist visitor count across container restarts
const COUNTER_FILE = path.join(__dirname, 'counter.json');

// Helper: read counter from file
function getCounter() {
  try {
    if (fs.existsSync(COUNTER_FILE)) {
      const data = fs.readFileSync(COUNTER_FILE, 'utf8');
      const obj = JSON.parse(data);
      return typeof obj.count === 'number' ? obj.count : 0;
    }
  } catch (err) {
    console.error('Error reading counter file:', err.message);
  }
  return 0;
}

// Helper: write counter to file
function saveCounter(count) {
  try {
    fs.writeFileSync(COUNTER_FILE, JSON.stringify({ count }), 'utf8');
  } catch (err) {
    console.error('Error writing counter file:', err.message);
  }
}

// Initialize counter
let visitorCounter = getCounter();

// Middleware to count visits
app.use((req, res, next) => {
  // Only count actual page loads, not favicon or health checks
  if (req.path === '/' && req.method === 'GET') {
    visitorCounter += 1;
    saveCounter(visitorCounter);
  }
  next();
});

// Health check endpoint (required for demo video)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Main application endpoint
app.get('/', (req, res) => {
  const timestamp = new Date().toISOString();
  const containerId = os.hostname(); // In Docker, this is the container ID
  const containerShortId = containerId.length > 12 ? containerId.substring(0, 12) : containerId;

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AWS Docker K8s App</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
      color: #ffffff;
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }
    .container {
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(10px);
      border-radius: 20px;
      padding: 40px;
      max-width: 600px;
      width: 100%;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
      border: 1px solid rgba(255, 255, 255, 0.2);
      text-align: center;
    }
    h1 { font-size: 2rem; margin-bottom: 10px; }
    .subtitle { font-size: 1rem; opacity: 0.9; margin-bottom: 30px; }
    .info-box {
      background: rgba(255, 255, 255, 0.15);
      border-radius: 12px;
      padding: 20px;
      margin: 15px 0;
      text-align: left;
    }
    .info-box h3 {
      font-size: 0.85rem;
      text-transform: uppercase;
      letter-spacing: 1px;
      opacity: 0.8;
      margin-bottom: 8px;
    }
    .info-box p {
      font-size: 1.1rem;
      font-weight: 600;
      word-break: break-all;
    }
    .counter {
      font-size: 3rem;
      font-weight: bold;
      color: #ffd700;
      margin: 10px 0;
    }
    .badge {
      display: inline-block;
      background: #28a745;
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 0.85rem;
      margin-top: 20px;
    }
    footer {
      margin-top: 30px;
      font-size: 0.8rem;
      opacity: 0.7;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚀 Node.js on AWS</h1>
    <p class="subtitle">Docker & Kubernetes Deployment</p>

    <div class="info-box">
      <h3>⏰ Current Timestamp</h3>
      <p>${timestamp}</p>
    </div>

    <div class="info-box">
      <h3>🐳 Container ID</h3>
      <p>${containerShortId}</p>
    </div>

    <div class="info-box" style="text-align: center;">
      <h3>👥 Visitor Counter</h3>
      <div class="counter">${visitorCounter}</div>
    </div>

    <span class="badge">Running on AWS Free Tier</span>

    <footer>
      Deployed via ECR & Minikube on EC2 t2.micro
    </footer>
  </div>
</body>
</html>
  `;

  res.setHeader('Content-Type', 'text/html');
  res.send(html);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
  console.log(`Container/Host ID: ${os.hostname()}`);
});
