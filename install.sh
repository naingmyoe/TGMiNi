#!/bin/bash

# =====================================================
# Outline VPN Telegram Mini App - Auto Installer
# Port: 8084
# =====================================================

set -e

# ============ COLORS ============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════╗
║   🔐  Outline VPN Telegram Mini App Installer   ║
║              Port: 8084                          ║
╚══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

PROJECT_NAME="outline-mini-app"
INSTALL_DIR="$(pwd)/$PROJECT_NAME"
APP_PORT=8084

echo -e "${BLUE}📁 Install directory:${NC} $INSTALL_DIR"
echo -e "${BLUE}🔌 Port:${NC} $APP_PORT"
echo ""

# ============ CHECK OS ============
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
else
  OS="unknown"
fi
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# ============ CHECK NODE.JS ============
if ! command -v node &> /dev/null; then
  echo -e "${YELLOW}⚠ Node.js not found. Installing...${NC}"
  if [[ "$OS" == "linux" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [[ "$OS" == "mac" ]]; then
    if ! command -v brew &> /dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install node
  else
    echo -e "${RED}✗ Please install Node.js: https://nodejs.org${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}✓${NC} Node.js: $(node -v)"
echo -e "${GREEN}✓${NC} npm: $(npm -v)"
echo ""

# ============ CREATE STRUCTURE ============
echo -e "${CYAN}📦 Creating project structure...${NC}"
mkdir -p "$INSTALL_DIR"/{frontend,backend/{routes,services,models}}
echo -e "${GREEN}✓${NC} Folders created"

# ============ PACKAGE.JSON ============
cat > "$INSTALL_DIR/package.json" << 'PKGEOF'
{
  "name": "outline-mini-app",
  "version": "1.0.0",
  "description": "Telegram Web Mini App for selling Outline VPN keys",
  "main": "backend/server.js",
  "scripts": {
    "start": "node backend/server.js",
    "dev": "nodemon backend/server.js"
  },
  "dependencies": {
    "express": "^4.19.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "axios": "^1.7.2",
    "sqlite3": "^5.1.7",
    "jsonwebtoken": "^9.0.2"
  },
  "devDependencies": {
    "nodemon": "^3.1.0"
  }
}
PKGEOF
echo -e "${GREEN}✓${NC} package.json"

# ============ .ENV ============
cat > "$INSTALL_DIR/backend/.env" << ENVEOF
# ============ SERVER ============
PORT=$APP_PORT

# ============ TELEGRAM ============
BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN_HERE

# ============ OUTLINE SERVER ============
OUTLINE_API_URL=https://your-outline-server.com:PORT/YOUR_SECRET_PATH
OUTLINE_CERT_SHA256=YOUR_CERT_FINGERPRINT

# ============ SECURITY ============
JWT_SECRET=$(openssl rand -hex 32)

# ============ ADMIN ============
ADMIN_TELEGRAM_ID=123456789
ENVEOF
echo -e "${GREEN}✓${NC} .env (PORT=$APP_PORT)"

# ============ BACKEND: db.js ============
cat > "$INSTALL_DIR/backend/models/db.js" << 'DBEOF'
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const db = new sqlite3.Database(path.join(__dirname, '..', 'app.db'));

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS users (
    telegram_id INTEGER PRIMARY KEY,
    username TEXT,
    first_name TEXT,
    balance INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS outline_keys (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    telegram_id INTEGER,
    outline_key_id TEXT,
    access_url TEXT,
    plan_name TEXT,
    data_limit_bytes INTEGER,
    data_used_bytes INTEGER DEFAULT 0,
    expires_at DATETIME,
    status TEXT DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    telegram_id INTEGER,
    type TEXT,
    amount INTEGER,
    method TEXT,
    status TEXT DEFAULT 'pending',
    ref TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS plans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    data_gb INTEGER,
    days INTEGER,
    price INTEGER,
    active INTEGER DEFAULT 1
  )`);

  db.get("SELECT COUNT(*) as c FROM plans", (err, row) => {
    if (row && row.c === 0) {
      const plans = [
        ['1 GB Plan', 1, 7, 500],
        ['5 GB Plan', 5, 30, 2000],
        ['20 GB Plan', 20, 30, 6000],
        ['50 GB Plan', 50, 60, 12000]
      ];
      plans.forEach(p => {
        db.run("INSERT INTO plans (name, data_gb, days, price) VALUES (?, ?, ?, ?)", p);
      });
    }
  });
});

module.exports = db;
DBEOF
echo -e "${GREEN}✓${NC} backend/models/db.js"

# ============ BACKEND: outline.js ============
cat > "$INSTALL_DIR/backend/services/outline.js" << 'OUTLINEEOF'
const axios = require('axios');
const https = require('https');
require('dotenv').config();

const OUTLINE_API_URL = process.env.OUTLINE_API_URL;
const httpsAgent = new https.Agent({ rejectUnauthorized: false });

async function createAccessKey(name) {
  const res = await axios.post(`${OUTLINE_API_URL}/access-keys`, { name }, { httpsAgent });
  return res.data;
}
async function getAccessKey(keyId) {
  const res = await axios.get(`${OUTLINE_API_URL}/access-keys/${keyId}`, { httpsAgent });
  return res.data;
}
async function setDataLimit(keyId, bytes) {
  await axios.put(`${OUTLINE_API_URL}/access-keys/${keyId}/data-limit`, { limit: { bytes } }, { httpsAgent });
  return true;
}
async function deleteAccessKey(keyId) {
  await axios.delete(`${OUTLINE_API_URL}/access-keys/${keyId}`, { httpsAgent });
  return true;
}
async function getUsage(keyId) {
  try {
    const res = await axios.get(`${OUTLINE_API_URL}/metrics/transfer`, { httpsAgent });
    return res.data.bytesTransferredByUserId[keyId] || 0;
  } catch { return 0; }
}

module.exports = { createAccessKey, getAccessKey, setDataLimit, deleteAccessKey, getUsage };
OUTLINEEOF
echo -e "${GREEN}✓${NC} backend/services/outline.js"

# ============ BACKEND: auth.js ============
cat > "$INSTALL_DIR/backend/routes/auth.js" << 'AUTHEOF'
const express = require('express');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const db = require('../models/db');
const router = express.Router();
const BOT_TOKEN = process.env.BOT_TOKEN;

function verifyTelegramInitData(initData) {
  const params = new URLSearchParams(initData);
  const hash = params.get('hash');
  params.delete('hash');
  const dataCheckString = [...params.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${k}=${v}`).join('\n');
  const secretKey = crypto.createHmac('sha256', 'WebAppData').update(BOT_TOKEN).digest();
  const calculatedHash = crypto.createHmac('sha256', secretKey).update(dataCheckString).digest('hex');
  return calculatedHash === hash;
}

router.post('/login', (req, res) => {
  const { initData } = req.body;
  if (!initData || !verifyTelegramInitData(initData)) {
    return res.status(401).json({ error: 'Invalid initData' });
  }
  const params = new URLSearchParams(initData);
  const user = JSON.parse(params.get('user'));
  db.run(
    `INSERT INTO users (telegram_id, username, first_name) VALUES (?, ?, ?)
     ON CONFLICT(telegram_id) DO UPDATE SET username=excluded.username, first_name=excluded.first_name`,
    [user.id, user.username || '', user.first_name || ''],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get("SELECT * FROM users WHERE telegram_id = ?", [user.id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        const token = jwt.sign({ telegramId: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.json({ token, user: row });
      });
    }
  );
});

module.exports = router;
AUTHEOF
echo -e "${GREEN}✓${NC} backend/routes/auth.js"

# ============ BACKEND: keys.js ============
cat > "$INSTALL_DIR/backend/routes/keys.js" << 'KEYSEOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../models/db');
const outline = require('../services/outline');
const router = express.Router();

function auth(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });
  try { req.user = jwt.verify(token, process.env.JWT_SECRET); next(); }
  catch { res.status(401).json({ error: 'Invalid token' }); }
}

router.get('/plans', (req, res) => {
  db.all("SELECT * FROM plans WHERE active = 1", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

router.get('/my-keys', auth, (req, res) => {
  db.all(
    "SELECT * FROM outline_keys WHERE telegram_id = ? ORDER BY created_at DESC",
    [req.user.telegramId],
    async (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      const updated = await Promise.all(rows.map(async (key) => {
        try {
          const used = await outline.getUsage(key.outline_key_id);
          return { ...key, data_used_bytes: used };
        } catch { return key; }
      }));
      res.json(updated);
    }
  );
});

router.post('/purchase', auth, (req, res) => {
  const { planId } = req.body;
  const telegramId = req.user.telegramId;
  db.get("SELECT * FROM plans WHERE id = ?", [planId], (err, plan) => {
    if (err || !plan) return res.status(404).json({ error: 'Plan not found' });
    db.get("SELECT balance FROM users WHERE telegram_id = ?", [telegramId], async (err, user) => {
      if (err) return res.status(500).json({ error: err.message });
      if (user.balance < plan.price) return res.status(400).json({ error: 'Insufficient balance' });
      try {
        const outlineKey = await outline.createAccessKey(`user_${telegramId}`);
        const bytesLimit = plan.data_gb * 1024 * 1024 * 1024;
        await outline.setDataLimit(outlineKey.id, bytesLimit);
        const expiresAt = new Date(Date.now() + plan.days * 24 * 3600 * 1000);
        db.run("UPDATE users SET balance = balance - ? WHERE telegram_id = ?", [plan.price, telegramId]);
        db.run(
          `INSERT INTO outline_keys (telegram_id, outline_key_id, access_url, plan_name, data_limit_bytes, expires_at)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [telegramId, outlineKey.id, outlineKey.accessUrl, plan.name, bytesLimit, expiresAt.toISOString()],
          function (err) {
            if (err) return res.status(500).json({ error: err.message });
            db.run(
              `INSERT INTO transactions (telegram_id, type, amount, method, status)
               VALUES (?, 'purchase', ?, 'wallet', 'completed')`,
              [telegramId, plan.price]
            );
            res.json({ success: true, keyId: this.lastID, accessUrl: outlineKey.accessUrl });
          }
        );
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to create key' });
      }
    });
  });
});

module.exports = router;
KEYSEOF
echo -e "${GREEN}✓${NC} backend/routes/keys.js"

# ============ BACKEND: wallet.js ============
cat > "$INSTALL_DIR/backend/routes/wallet.js" << 'WALLETEOF'
const express = require('express');
const jwt = require('jsonwebtoken');
const db = require('../models/db');
const router = express.Router();

function auth(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });
  try { req.user = jwt.verify(token, process.env.JWT_SECRET); next(); }
  catch { res.status(401).json({ error: 'Invalid token' }); }
}

router.get('/balance', auth, (req, res) => {
  db.get("SELECT balance FROM users WHERE telegram_id = ?", [req.user.telegramId], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ balance: row?.balance || 0 });
  });
});

router.get('/transactions', auth, (req, res) => {
  db.all(
    "SELECT * FROM transactions WHERE telegram_id = ? ORDER BY created_at DESC LIMIT 20",
    [req.user.telegramId],
    (err, rows) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(rows);
    }
  );
});

router.post('/topup', auth, (req, res) => {
  const { amount, method } = req.body;
  if (!amount || amount < 500) return res.status(400).json({ error: 'Minimum top-up is 500 MMK' });
  db.run("UPDATE users SET balance = balance + ? WHERE telegram_id = ?",
    [amount, req.user.telegramId], function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.run(
        `INSERT INTO transactions (telegram_id, type, amount, method, status)
         VALUES (?, 'topup', ?, ?, 'completed')`,
        [req.user.telegramId, amount, method || 'manual']
      );
      res.json({ success: true, amount });
    }
  );
});

module.exports = router;
WALLETEOF
echo -e "${GREEN}✓${NC} backend/routes/wallet.js"

# ============ BACKEND: server.js ============
cat > "$INSTALL_DIR/backend/server.js" << SERVEREOF
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const authRoutes = require('./routes/auth');
const keyRoutes = require('./routes/keys');
const walletRoutes = require('./routes/wallet');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/keys', keyRoutes);
app.use('/api/wallet', walletRoutes);

app.use(express.static(path.join(__dirname, '..', 'frontend')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'index.html'));
});

const PORT = process.env.PORT || $APP_PORT;
app.listen(PORT, '0.0.0.0', () => {
  console.log('');
  console.log('🚀 Outline VPN Mini App');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🌐 Server:  http://localhost:' + PORT);
  console.log('📱 API:     http://localhost:' + PORT + '/api');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
});
SERVEREOF
echo -e "${GREEN}✓${NC} backend/server.js (PORT=$APP_PORT)"

# ============ FRONTEND: index.html ============
echo -e "${CYAN}📝 Writing frontend/index.html...${NC}"

cat > "$INSTALL_DIR/frontend/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Outline VPN Store</title>
<script src="https://telegram.org/js/telegram-web-app.js"></script>
<style>
* { margin:0; padding:0; box-sizing:border-box; -webkit-tap-highlight-color:transparent; }
:root {
  --bg: var(--tg-theme-bg-color, #0e1621);
  --card: var(--tg-theme-secondary-bg-color, #17212b);
  --text: var(--tg-theme-text-color, #ffffff);
  --hint: var(--tg-theme-hint-color, #8fa3b8);
  --link: var(--tg-theme-link-color, #2a9df4);
  --button: var(--tg-theme-button-color, #2a9df4);
  --button-text: var(--tg-theme-button-text-color, #ffffff);
  --success: #4CAF50; --danger: #F44336; --warning: #FFB800;
}
html, body { background:var(--bg); color:var(--text);
  font-family:-apple-system,BlinkMacSystemFont,'SF Pro Text','Segoe UI',Roboto,sans-serif;
  height:100%; overflow:hidden; -webkit-font-smoothing:antialiased; }
.hidden { display:none !important; }

.loading { height:100vh; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:20px; color:var(--hint); }
.spinner { width:40px; height:40px; border:3px solid rgba(42,157,244,.2); border-top-color:var(--link); border-radius:50%; animation:spin .8s linear infinite; }
@keyframes spin { to { transform:rotate(360deg); } }

.app { height:100vh; display:flex; flex-direction:column; position:relative; padding-bottom:70px; }
.page { display:none; flex:1; overflow-y:auto; padding:16px; animation:fadeIn .2s ease; }
.page.active { display:block; }
@keyframes fadeIn { from{opacity:0; transform:translateY(6px);} to{opacity:1; transform:translateY(0);} }

.topbar { display:flex; justify-content:space-between; align-items:center; padding:8px 0 16px; }
.topbar h1 { font-size:20px; font-weight:700; flex:1; text-align:center; }
.back-btn { background:none; border:none; color:var(--link); font-size:22px; cursor:pointer; padding:4px 8px; }
.topbar > span { width:40px; }

.wallet-card { background:linear-gradient(135deg,#2a9df4,#1878c9); border-radius:16px; padding:18px; margin-bottom:20px; box-shadow:0 8px 24px rgba(42,157,244,.3); }
.wallet-label { font-size:12px; opacity:.85; margin-bottom:6px; }
.wallet-amount { font-size:26px; font-weight:700; margin-bottom:12px; }
.wallet-btn { background:rgba(255,255,255,.25); color:#fff; border:none; padding:8px 16px; border-radius:20px; font-size:12px; font-weight:600; cursor:pointer; }

.section-title { font-size:12px; color:var(--hint); margin-bottom:12px; font-weight:700; letter-spacing:.8px; }

.plans-list { display:flex; flex-direction:column; gap:10px; }
.plan { background:var(--card); border-radius:14px; padding:14px; display:flex; align-items:center; gap:12px; border:1px solid rgba(255,255,255,.04); transition:transform .15s; }
.plan:active { transform:scale(.98); }
.plan-dot { width:10px; height:10px; border-radius:50%; flex-shrink:0; }
.plan-dot.green  { background:var(--success); box-shadow:0 0 10px var(--success); }
.plan-dot.yellow { background:var(--warning); box-shadow:0 0 10px var(--warning); }
.plan-dot.red    { background:var(--danger);  box-shadow:0 0 10px var(--danger); }
.plan-info { flex:1; }
.plan-name { font-size:14px; font-weight:600; margin-bottom:3px; }
.plan-valid { font-size:11px; color:var(--hint); }
.plan-price { font-size:13px; font-weight:700; color:var(--link); }
.buy-btn { background:var(--button); color:var(--button-text); border:none; padding:8px 14px; border-radius:10px; font-size:12px; font-weight:600; cursor:pointer; transition:opacity .15s; }
.buy-btn:active { opacity:.8; }

.skeleton { height:60px; background:linear-gradient(90deg,#17212b 0%,#1f2c3a 50%,#17212b 100%); background-size:200% 100%; animation:shimmer 1.5s infinite; border-radius:14px; }
@keyframes shimmer { 0%{background-position:200% 0;} 100%{background-position:-200% 0;} }

.keys-list { display:flex; flex-direction:column; gap:10px; }
.keycard { background:var(--card); border-radius:14px; padding:14px; border-left:3px solid var(--success); }
.keycard.expired { border-left-color:var(--danger); }
.key-head { display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; }
.key-name { font-size:14px; font-weight:600; }
.badge { font-size:9px; padding:3px 8px; border-radius:10px; font-weight:700; }
.badge.active  { background:rgba(76,175,80,.2); color:var(--success); }
.badge.expired { background:rgba(244,67,54,.2); color:var(--danger); }
.progress { height:5px; background:rgba(255,255,255,.05); border-radius:3px; overflow:hidden; margin:8px 0; }
.progress-bar { height:100%; background:linear-gradient(90deg,#2a9df4,#5eb5f7); border-radius:3px; transition:width .4s; }
.progress-bar.red { background:linear-gradient(90deg,#F44336,#ff6b5e); }
.key-meta { display:flex; justify-content:space-between; font-size:11px; color:var(--hint); margin-bottom:10px; }
.key-actions { display:flex; gap:8px; }
.key-actions button { flex:1; padding:9px; border-radius:10px; border:1px solid var(--link); background:transparent; color:var(--link); font-size:11px; font-weight:600; cursor:pointer; }
.key-actions button.primary { background:var(--link); color:#fff; }
.key-actions button.danger  { border-color:var(--danger); background:var(--danger); color:#fff; }

.empty-state { text-align:center; padding:60px 20px; color:var(--hint); }
.empty-icon { font-size:56px; margin-bottom:12px; }
.empty-state p { font-size:15px; margin-bottom:4px; }
.empty-state small { font-size:12px; opacity:.7; }

.ssbox { background:rgba(42,157,244,.05); border:1px dashed var(--link); border-radius:12px; padding:14px; font-family:'Courier New',monospace; font-size:11px; color:var(--link); word-break:break-all; line-height:1.6; margin-bottom:14px; }

.qr-wrap { text-align:center; margin-bottom:20px; }
.qr { display:inline-block; padding:14px; background:#fff; border-radius:16px; box-shadow:0 8px 24px rgba(0,0,0,.3); }
.qr img, .qr canvas { display:block; width:180px !important; height:180px !important; }

.btn { width:100%; padding:14px; border-radius:12px; font-size:14px; font-weight:600; cursor:pointer; border:none; margin-bottom:10px; transition:opacity .15s,transform .15s; }
.btn:active { transform:scale(.98); }
.btn-primary { background:var(--button); color:var(--button-text); }
.btn-outline { background:transparent; border:1.5px solid var(--link); color:var(--link); }

.how-to ol { padding-left:20px; font-size:12px; color:var(--hint); line-height:2; }
.how-to b { color:var(--link); }

.big-balance { text-align:center; padding:24px 0; }
.big-balance .lbl { font-size:12px; color:var(--hint); margin-bottom:8px; }
.big-balance .amt { font-size:34px; font-weight:700; color:var(--text); }

.amount-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-bottom:22px; }
.amount-box { background:var(--card); border:1.5px solid rgba(255,255,255,.05); border-radius:12px; padding:18px 8px; text-align:center; font-size:14px; font-weight:700; cursor:pointer; transition:all .15s; }
.amount-box.selected { border-color:var(--link); background:rgba(42,157,244,.1); color:var(--link); }

.pay-options { margin-bottom:20px; }
.pay-option { background:var(--card); border:1.5px solid rgba(255,255,255,.05); border-radius:12px; padding:14px; margin-bottom:8px; display:flex; align-items:center; gap:12px; cursor:pointer; transition:all .15s; }
.pay-option.selected { border-color:var(--link); background:rgba(42,157,244,.08); }
.pay-circle { width:18px; height:18px; border-radius:50%; border:2px solid var(--hint); flex-shrink:0; position:relative; }
.pay-circle.selected { border-color:var(--link); }
.pay-circle.selected::after { content:''; position:absolute; inset:3px; background:var(--link); border-radius:50%; }
.pay-name { font-size:13px; font-weight:600; flex:1; }
.pay-icon { font-size:18px; }

.tx-list { display:flex; flex-direction:column; gap:6px; }
.tx-item { display:flex; justify-content:space-between; align-items:center; padding:10px 12px; background:var(--card); border-radius:10px; font-size:12px; }
.tx-item .amount { font-weight:700; }
.tx-item .amount.plus  { color:var(--success); }
.tx-item .amount.minus { color:var(--danger); }
.tx-item .date { color:var(--hint); font-size:10px; }

.profile-head { text-align:center; padding:20px 0; }
.avatar { width:84px; height:84px; border-radius:50%; background:linear-gradient(135deg,#2a9df4,#5eb5f7); margin:0 auto 12px; display:flex; align-items:center; justify-content:center; font-size:36px; color:#fff; box-shadow:0 8px 24px rgba(42,157,244,.35); }
.user-name { font-size:17px; font-weight:700; margin-bottom:3px; }
.user-id { font-size:12px; color:var(--hint); }

.menu { margin-top:20px; }
.menu-item { background:var(--card); border-radius:12px; padding:14px; margin-bottom:8px; display:flex; align-items:center; gap:12px; cursor:pointer; transition:background .15s; font-size:13px; }
.menu-item:active { background:rgba(42,157,244,.1); }
.menu-item .mi { font-size:16px; width:24px; }
.menu-item .arrow { color:var(--hint); margin-left:auto; font-size:18px; }

.bottom-nav { position:fixed; bottom:0; left:0; right:0; display:flex; justify-content:space-around; padding:10px 0 14px; background:var(--card); border-top:1px solid rgba(255,255,255,.05); z-index:100; }
.nav-item { text-align:center; font-size:10px; color:var(--hint); cursor:pointer; transition:color .15s; padding:4px 14px; }
.nav-item.active { color:var(--link); }
.nav-item .ni { font-size:18px; display:block; margin-bottom:3px; }

.toast { position:fixed; bottom:90px; left:50%; transform:translateX(-50%) translateY(100px); background:rgba(42,157,244,.95); color:#fff; padding:12px 22px; border-radius:25px; font-size:13px; font-weight:600; box-shadow:0 8px 24px rgba(0,0,0,.3); transition:transform .3s ease; z-index:999; max-width:85%; text-align:center; }
.toast.show { transform:translateX(-50%) translateY(0); }
.toast.error { background:rgba(244,67,54,.95); }
.toast.success { background:rgba(76,175,80,.95); }
</style>
</head>
<body>

<div id="loading" class="loading">
  <div class="spinner"></div>
  <p>Connecting to Telegram...</p>
</div>

<div id="app" class="app hidden">

  <div class="page active" id="page-home">
    <div class="topbar"><h1>🔐 Outline VPN</h1></div>
    <div class="wallet-card">
      <div class="wallet-label">💰 Wallet Balance</div>
      <div class="wallet-amount" id="home-balance">0 MMK</div>
      <button class="wallet-btn" onclick="navigate('page-wallet')">+ Top Up</button>
    </div>
    <h3 class="section-title">🔥 AVAILABLE PLANS</h3>
    <div id="plans-list" class="plans-list">
      <div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>
    </div>
  </div>

  <div class="page" id="page-keys">
    <div class="topbar"><h1>🔑 My Keys</h1></div>
    <div id="keys-list" class="keys-list">
      <div class="empty-state">
        <div class="empty-icon">📭</div>
        <p>No keys yet</p>
        <small>Buy a plan from Home</small>
      </div>
    </div>
  </div>

  <div class="page" id="page-key-detail">
    <div class="topbar">
      <button class="back-btn" onclick="navigate('page-keys')">←</button>
      <h1>Key Details</h1><span></span>
    </div>
    <div class="qr-wrap"><div id="qrcode" class="qr"></div></div>
    <h3 class="section-title">📋 YOUR OUTLINE KEY</h3>
    <div class="ssbox" id="key-url">ss://...</div>
    <button class="btn btn-primary" onclick="copyKey()">📋 Copy Key</button>
    <button class="btn btn-outline" onclick="shareKey()">📤 Share</button>
    <div class="how-to">
      <h3 class="section-title">📖 HOW TO USE</h3>
      <ol>
        <li>Download <b>Outline</b> app</li>
        <li>Tap "Add Server"</li>
        <li>Paste key or scan QR</li>
        <li>Connect &amp; enjoy 🚀</li>
      </ol>
    </div>
  </div>

  <div class="page" id="page-wallet">
    <div class="topbar">
      <button class="back-btn" onclick="navigate('page-home')">←</button>
      <h1>My Wallet</h1><span></span>
    </div>
    <div class="big-balance">
      <div class="lbl">💰 Current Balance</div>
      <div class="amt" id="wallet-balance">0 MMK</div>
    </div>
    <h3 class="section-title">📥 TOP UP AMOUNT</h3>
    <div class="amount-grid" id="amount-grid">
      <div class="amount-box" data-amount="1000">1,000</div>
      <div class="amount-box selected" data-amount="5000">5,000</div>
      <div class="amount-box" data-amount="10000">10,000</div>
    </div>
    <h3 class="section-title">💳 PAYMENT METHOD</h3>
    <div class="pay-options" id="pay-options">
      <div class="pay-option selected" data-method="kbzpay">
        <div class="pay-circle selected"></div>
        <div class="pay-name">KBZ Pay</div>
        <div class="pay-icon">🏦</div>
      </div>
      <div class="pay-option" data-method="wave">
        <div class="pay-circle"></div>
        <div class="pay-name">Wave Money</div>
        <div class="pay-icon">🌊</div>
      </div>
      <div class="pay-option" data-method="ayapay">
        <div class="pay-circle"></div>
        <div class="pay-name">AYA Pay</div>
        <div class="pay-icon">💳</div>
      </div>
    </div>
    <button class="btn btn-primary" onclick="doTopup()">💳 Proceed to Pay</button>
    <h3 class="section-title" style="margin-top:20px;">📜 RECENT</h3>
    <div id="tx-list" class="tx-list"></div>
  </div>

  <div class="page" id="page-profile">
    <div class="topbar"><h1>Profile</h1></div>
    <div class="profile-head">
      <div class="avatar" id="avatar">👤</div>
      <div class="user-name" id="user-name">User</div>
      <div class="user-id" id="user-id">@user</div>
    </div>
    <div class="menu">
      <div class="menu-item" onclick="navigate('page-wallet')">
        <span class="mi">💰</span><span>My Wallet</span><span class="arrow">›</span>
      </div>
      <div class="menu-item" onclick="navigate('page-keys')">
        <span class="mi">🔑</span><span>My Keys</span><span class="arrow">›</span>
      </div>
      <div class="menu-item">
        <span class="mi">📜</span><span>Transaction History</span><span class="arrow">›</span>
      </div>
      <div class="menu-item">
        <span class="mi">🎁</span><span>Refer &amp; Earn</span><span class="arrow">›</span>
      </div>
      <div class="menu-item">
        <span class="mi">💬</span><span>Support</span><span class="arrow">›</span>
      </div>
    </div>
  </div>

  <nav class="bottom-nav">
    <div class="nav-item active" data-page="page-home">
      <span class="ni">🏠</span><span>Home</span>
    </div>
    <div class="nav-item" data-page="page-keys">
      <span class="ni">🔑</span><span>My Keys</span>
    </div>
    <div class="nav-item" data-page="page-profile">
      <span class="ni">👤</span><span>Me</span>
    </div>
  </nav>

</div>

<div id="toast" class="toast"></div>

<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>

<script>
const API_BASE = window.location.origin + '/api';

let state = {
  token: null, user: null, currentKey: null, plans: [],
  selectedAmount: 5000, selectedMethod: 'kbzpay'
};

window.addEventListener('load', async () => {
  const tg = window.Telegram?.WebApp;
  if (tg) {
    tg.ready(); tg.expand();
    tg.setHeaderColor('#0e1621');
    tg.setBackgroundColor('#0e1621');
  }
  const initData = tg?.initData || '';
  if (!initData) return startDemo();
  try {
    const res = await fetch(API_BASE + '/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ initData })
    });
    if (!res.ok) throw new Error('Login failed');
    const data = await res.json();
    state.token = data.token;
    state.user = data.user;
    document.getElementById('loading').classList.add('hidden');
    document.getElementById('app').classList.remove('hidden');
    await loadAll();
  } catch (err) { console.error(err); startDemo(); }
});

function startDemo() {
  state.token = 'demo';
  state.user = { telegram_id: 123456789, username: 'demo', first_name: 'Demo User', balance: 5000 };
  document.getElementById('loading').classList.add('hidden');
  document.getElementById('app').classList.remove('hidden');
  state.plans = [
    { id: 1, name: '1 GB Plan',  data_gb: 1,  days: 7,  price: 500 },
    { id: 2, name: '5 GB Plan',  data_gb: 5,  days: 30, price: 2000 },
    { id: 3, name: '20 GB Plan', data_gb: 20, days: 30, price: 6000 },
    { id: 4, name: '50 GB Plan', data_gb: 50, days: 60, price: 12000 }
  ];
  state.demoKeys = [{
    id: 1, outline_key_id: 'demo-001',
    access_url: 'ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpkZW1vQDEuMi4zLjQ6MTIzNA==#Outline-Key',
    plan_name: '5 GB Plan', data_limit_bytes: 5 * 1024**3,
    data_used_bytes: 3.2 * 1024**3,
    expires_at: new Date(Date.now() + 25 * 24 * 3600 * 1000).toISOString(),
    status: 'active'
  }];
  renderPlans();
  renderKeys(state.demoKeys);
  updateBalances();
  renderTransactions([
    { type: 'topup', amount: 5000, created_at: new Date().toISOString() },
    { type: 'purchase', amount: -2000, created_at: new Date(Date.now() - 86400000).toISOString() }
  ]);
  updateProfile();
}

async function loadAll() {
  await Promise.all([loadPlans(), loadKeys(), loadBalance(), loadTransactions()]);
  updateProfile();
}

async function loadPlans() {
  try {
    const res = await fetch(API_BASE + '/keys/plans');
    state.plans = await res.json();
    renderPlans();
  } catch (e) { console.error(e); }
}

async function loadKeys() {
  try {
    const res = await fetch(API_BASE + '/keys/my-keys', {
      headers: { 'Authorization': 'Bearer ' + state.token }
    });
    renderKeys(await res.json());
  } catch (e) { console.error(e); }
}

async function loadBalance() {
  try {
    const res = await fetch(API_BASE + '/wallet/balance', {
      headers: { 'Authorization': 'Bearer ' + state.token }
    });
    const { balance } = await res.json();
    state.user.balance = balance;
    updateBalances();
  } catch (e) { console.error(e); }
}

async function loadTransactions() {
  try {
    const res = await fetch(API_BASE + '/wallet/transactions', {
      headers: { 'Authorization': 'Bearer ' + state.token }
    });
    renderTransactions(await res.json());
  } catch (e) { console.error(e); }
}

function renderPlans() {
  const list = document.getElementById('plans-list');
  if (!state.plans.length) {
    list.innerHTML = '<div class="empty-state"><p>No plans available</p></div>';
    return;
  }
  const colors = ['green', 'yellow', 'red', 'green'];
  list.innerHTML = state.plans.map((p, i) => `
    <div class="plan">
      <div class="plan-dot ${colors[i % colors.length]}"></div>
      <div class="plan-info">
        <div class="plan-name">${p.name}</div>
        <div class="plan-valid">Valid ${p.days} days</div>
      </div>
      <div class="plan-price">${p.price.toLocaleString()}</div>
      <button class="buy-btn" onclick="buyPlan(${p.id})">Buy</button>
    </div>
  `).join('');
}

function renderKeys(keys) {
  const list = document.getElementById('keys-list');
  if (!keys || !keys.length) {
    list.innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">📭</div>
        <p>No keys yet</p>
        <small>Buy a plan from Home</small>
      </div>`;
    return;
  }
  list.innerHTML = keys.map(k => {
    const used = k.data_used_bytes || 0;
    const limit = k.data_limit_bytes || 1;
    const pct = Math.min(100, (used / limit) * 100);
    const isExpired = new Date(k.expires_at) < new Date() || k.status === 'expired';
    const daysLeft = Math.max(0, Math.ceil((new Date(k.expires_at) - Date.now()) / 86400000));
    const usedGB = (used / 1024**3).toFixed(2);
    const limitGB = (limit / 1024**3).toFixed(0);
    return `
      <div class="keycard ${isExpired ? 'expired' : ''}">
        <div class="key-head">
          <span class="key-name">🔑 ${k.plan_name || 'Key #' + k.id}</span>
          <span class="badge ${isExpired ? 'expired' : 'active'}">${isExpired ? 'EXPIRED' : 'ACTIVE'}</span>
        </div>
        <div class="progress">
          <div class="progress-bar ${isExpired ? 'red' : ''}" style="width:${pct}%"></div>
        </div>
        <div class="key-meta">
          <span>${usedGB} / ${limitGB} GB used</span>
          <span>${isExpired ? 'Expired' : daysLeft + ' days left'}</span>
        </div>
        <div class="key-actions">
          ${isExpired
            ? '<button class="danger" onclick="showToast(\'Renew feature coming soon\',\'error\')">🔄 Renew</button>'
            : `<button class="primary" onclick="showKeyDetail(${k.id})">📋 View Key</button>
               <button onclick="showKeyDetail(${k.id})">📱 QR</button>`}
        </div>
      </div>
    `;
  }).join('');
}

function updateBalances() {
  const bal = (state.user?.balance || 0).toLocaleString() + ' MMK';
  document.getElementById('home-balance').textContent = bal;
  document.getElementById('wallet-balance').textContent = bal;
}

function renderTransactions(txs) {
  const list = document.getElementById('tx-list');
  if (!txs || !txs.length) {
    list.innerHTML = '<div class="tx-item"><span>No transactions yet</span></div>';
    return;
  }
  list.innerHTML = txs.slice(0, 10).map(t => {
    const isPlus = t.type === 'topup' || t.amount > 0;
    const date = new Date(t.created_at).toLocaleDateString();
    return `
      <div class="tx-item">
        <span class="amount ${isPlus ? 'plus' : 'minus'}">
          ${isPlus ? '+' : ''}${Math.abs(t.amount).toLocaleString()} MMK
        </span>
        <span class="date">${date}</span>
      </div>
    `;
  }).join('');
}

function updateProfile() {
  const u = state.user;
  document.getElementById('user-name').textContent = u.first_name || 'User';
  document.getElementById('user-id').textContent =
    (u.username ? '@' + u.username : '') + ' · ID: ' + u.telegram_id;
  document.getElementById('avatar').textContent = (u.first_name || 'U').charAt(0).toUpperCase();
}

async function buyPlan(planId) {
  const plan = state.plans.find(p => p.id === planId);
  if (!plan) return;
  if (state.user.balance < plan.price) {
    showToast('Insufficient balance. Please top up.', 'error');
    return;
  }
  if (state.token === 'demo') {
    state.user.balance -= plan.price;
    updateBalances();
    showToast('✅ Purchased ' + plan.name + ' (demo)', 'success');
    return;
  }
  try {
    const res = await fetch(API_BASE + '/keys/purchase', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + state.token
      },
      body: JSON.stringify({ planId })
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error);
    showToast('✅ Purchase successful!', 'success');
    await loadAll();
  } catch (e) {
    showToast(e.message || 'Purchase failed', 'error');
  }
}

function showKeyDetail(keyId) {
  let key;
  if (state.token === 'demo') {
    key = state.demoKeys.find(k => k.id === keyId);
  } else {
    // fetch from state if not loaded
    key = null;
  }
  if (!key) {
    showToast('Key not found', 'error');
    return;
  }
  state.currentKey = key;
  document.getElementById('key-url').textContent = key.access_url;
  const qrEl = document.getElementById('qrcode');
  qrEl.innerHTML = '';
  if (window.QRCode) {
    QRCode.toCanvas(key.access_url, { width: 180, margin: 1 }, (err, canvas) => {
      if (!err) qrEl.appendChild(canvas);
    });
  }
  navigate('page-key-detail');
}

function copyKey() {
  if (!state.currentKey) return;
  const url = state.currentKey.access_url;
  if (navigator.clipboard) {
    navigator.clipboard.writeText(url).then(() => showToast('📋 Key copied!', 'success'));
  } else {
    const ta = document.createElement('textarea');
    ta.value = url;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
    showToast('📋 Key copied!', 'success');
  }
}

function shareKey() {
  if (!state.currentKey) return;
  const url = state.currentKey.access_url;
  if (navigator.share) {
    navigator.share({ title: 'Outline VPN Key', text: url });
  } else {
    showToast('Share not supported', 'error');
  }
}

async function doTopup() {
  const amount = state.selectedAmount;
  const method = state.selectedMethod;
  if (state.token === 'demo') {
    state.user.balance += amount;
    updateBalances();
    showToast('✅ Top up ' + amount.toLocaleString() + ' MMK (demo)', 'success');
    return;
  }
  try {
    const res = await fetch(API_BASE + '/wallet/topup', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + state.token
      },
      body: JSON.stringify({ amount, method })
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error);
    showToast('✅ Top up successful!', 'success');
    await loadBalance();
    await loadTransactions();
  } catch (e) {
    showToast(e.message || 'Top up failed', 'error');
  }
}

function navigate(pageId) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.getElementById(pageId).classList.add('active');
  document.querySelectorAll('.nav-item').forEach(n => {
    n.classList.toggle('active', n.dataset.page === pageId);
  });
}

let toastTimer;
function showToast(msg, type) {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.className = 'toast show ' + (type || '');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove('show'), 2500);
}

// Event bindings
document.addEventListener('click', e => {
  const amountBox = e.target.closest('.amount-box');
  if (amountBox) {
    document.querySelectorAll('.amount-box').forEach(b => b.classList.remove('selected'));
    amountBox.classList.add('selected');
    state.selectedAmount = parseInt(amountBox.dataset.amount);
  }
  const payOpt = e.target.closest('.pay-option');
  if (payOpt) {
    document.querySelectorAll('.pay-option').forEach(p => {
      p.classList.remove('selected');
      p.querySelector('.pay-circle')?.classList.remove('selected');
    });
    payOpt.classList.add('selected');
    payOpt.querySelector('.pay-circle')?.classList.add('selected');
    state.selectedMethod = payOpt.dataset.method;
  }
  const navItem = e.target.closest('.nav-item');
  if (navItem && navItem.dataset.page) {
    navigate(navItem.dataset.page);
  }
});
</script>
</body>
</html>
HTMLEOF
echo -e "${GREEN}✓${NC} frontend/index.html"

# ============ INSTALL DEPENDENCIES ============
echo ""
echo -e "${CYAN}📦 Installing npm dependencies...${NC}"
cd "$INSTALL_DIR"
npm install --silent

echo -e "${GREEN}✓${NC} Dependencies installed"

# ============ FIREWALL ============
if [[ "$OS" == "linux" ]] && command -v ufw &> /dev/null; then
  echo -e "${CYAN}🔥 Opening port $APP_PORT in firewall...${NC}"
  sudo ufw allow $APP_PORT/tcp 2>/dev/null || true
  echo -e "${GREEN}✓${NC} Port $APP_PORT opened"
fi

# ============ DONE ============
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✅  INSTALLATION COMPLETE             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Project:${NC} $INSTALL_DIR"
echo -e "${CYAN}🔌 Port:${NC} $APP_PORT"
echo -e "${CYAN}🌐 URL:${NC} http://localhost:$APP_PORT"
echo ""
echo -e "${YELLOW}⚠  Next steps:${NC}"
echo "   1. Edit backend/.env — add your BOT_TOKEN & OUTLINE_API_URL"
echo "   2. Run: cd $PROJECT_NAME && npm start"
echo "   3. Set Telegram Mini App URL to: https://your-domain:$APP_PORT"
echo ""

# ============ START? ============
read -p "$(echo -e ${CYAN}Start server now? [y/N]: ${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}🚀 Starting server on port $APP_PORT...${NC}"
  npm start
else
  echo -e "${YELLOW}Run manually:${NC} cd $PROJECT_NAME && npm start"
fi
