#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# Telegram VPN Mini App Installer
# Ports: 8081 or 8082 only
# ==========================================

APP_DIR="/var/www/vpn-mini"
PORT="${PORT:-8081}"

if [[ "$PORT" != "8081" && "$PORT" != "8082" ]]; then
    echo "ERROR: PORT must be 8081 or 8082"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo bash install.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx

mkdir -p "$APP_DIR"

cat > "$APP_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="my">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="theme-color" content="#101827">
<title>UN VPN</title>

<script src="https://telegram.org/js/telegram-web-app.js"></script>

<style>
:root {
  --bg:#0b1220;
  --panel:#131e30;
  --panel2:#19263a;
  --text:#f4f7ff;
  --muted:#91a0b8;
  --accent:#6c7cff;
  --green:#35d49a;
  --border:#26344a;
}
* { box-sizing:border-box; }
body {
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:Arial,"Noto Sans Myanmar",sans-serif;
}
button,input,select { font:inherit; }
button { cursor:pointer; }
.app {
  width:100%;
  max-width:520px;
  margin:auto;
  padding:18px 16px 100px;
}
.header {
  display:flex;
  align-items:center;
  justify-content:space-between;
  margin-bottom:22px;
}
.brand { display:flex; align-items:center; gap:11px; }
.logo {
  width:46px;height:46px;border-radius:15px;
  background:linear-gradient(135deg,#7284ff,#4552d8);
  display:grid;place-items:center;font-size:24px;
  box-shadow:0 8px 25px #5265ff30;
}
.brand h1 { margin:0;font-size:20px; }
.brand p { margin:5px 0 0;color:var(--muted);font-size:12px; }
.avatar {
  width:40px;height:40px;border-radius:50%;
  background:var(--panel2);display:grid;place-items:center;
  border:1px solid var(--border);font-size:19px;
}
.hero {
  padding:22px;border-radius:24px;
  background:linear-gradient(135deg,#273c85,#20295b 60%,#18233b);
  position:relative;overflow:hidden;margin-bottom:22px;
}
.hero:after {
  content:"";position:absolute;width:160px;height:160px;
  right:-55px;top:-65px;border-radius:50%;
  border:28px solid #ffffff0d;
}
.eyebrow { font-size:12px;color:#c2ceff;margin-bottom:10px; }
.hero h2 { font-size:25px;line-height:1.5;margin:0 0 9px; }
.hero p { font-size:13px;color:#d0d9ff;line-height:1.8;margin:0 0 18px; }
.primary {
  border:0;background:var(--accent);color:white;
  padding:13px 16px;border-radius:13px;font-weight:bold;
  width:100%;
}
.hero .primary { background:white;color:#273575;width:auto; }
.section-head {
  display:flex;align-items:center;justify-content:space-between;
  margin:24px 0 13px;
}
.section-head h3 { margin:0;font-size:16px; }
.section-head span { color:var(--muted);font-size:12px; }
.balance {
  display:flex;justify-content:space-between;align-items:center;
  background:var(--panel);border:1px solid var(--border);
  border-radius:18px;padding:17px;margin-bottom:18px;
}
.balance small { color:var(--muted);font-size:12px; }
.balance strong { display:block;font-size:22px;margin-top:8px; }
.balance .coin { font-size:27px; }
.grid {
  display:grid;grid-template-columns:1fr 1fr;gap:12px;
}
.plan {
  background:var(--panel);border:1px solid var(--border);
  padding:16px;border-radius:18px;min-width:0;
}
.plan.featured { border-color:#6878ff; }
.plan .plan-icon { font-size:24px;margin-bottom:13px; }
.plan h4 { margin:0 0 7px;font-size:15px; }
.plan .desc { color:var(--muted);font-size:12px;line-height:1.7;min-height:38px; }
.price { font-size:19px;font-weight:bold;margin:14px 0; }
.price small { color:var(--muted);font-size:11px;font-weight:normal; }
.plan button { font-size:12px;padding:11px 7px; }
.panel {
  background:var(--panel);border:1px solid var(--border);
  border-radius:18px;padding:17px;margin-top:13px;
}
.field { margin:14px 0; }
.field label { display:block;color:var(--muted);font-size:12px;margin-bottom:8px; }
.field input,.field select {
  width:100%;padding:13px;background:#0d1727;color:white;
  border:1px solid var(--border);border-radius:12px;outline:none;
}
.upload {
  display:block;text-align:center;padding:18px;
  border:1px dashed #4a5b7b;border-radius:14px;
  background:#0d1727;color:#b8c5dc;font-size:13px;
}
.upload input { display:none; }
.notice {
  padding:12px;border-radius:12px;background:#202b42;
  color:#b8c7e6;font-size:12px;line-height:1.8;margin:13px 0;
}
.hidden { display:none !important; }
.nav {
  position:fixed;bottom:0;left:0;right:0;
  background:#101a2bed;backdrop-filter:blur(16px);
  border-top:1px solid var(--border);
  display:flex;justify-content:center;z-index:5;
  padding:9px 8px calc(9px + env(safe-area-inset-bottom));
}
.nav-inner { display:flex;width:100%;max-width:520px; }
.nav button {
  flex:1;border:0;background:transparent;color:var(--muted);
  padding:7px 3px;font-size:11px;line-height:1.7;
}
.nav button.active { color:#8d9aff; }
.nav .ico { display:block;font-size:20px; }
.status {
  display:inline-block;padding:5px 9px;border-radius:8px;
  background:#153c36;color:var(--green);font-size:11px;
}
.row {
  display:flex;align-items:center;justify-content:space-between;gap:12px;
}
.muted { color:var(--muted);font-size:12px;line-height:1.8; }
hr { border:0;border-top:1px solid var(--border);margin:16px 0; }
.toast {
  position:fixed;left:16px;right:16px;bottom:90px;
  max-width:488px;margin:auto;background:#263550;
  color:white;padding:14px;border-radius:12px;
  z-index:10;font-size:13px;display:none;
}
@media(min-width:600px) {
  body { background:#080e18; }
  .app { padding-top:28px; }
}
</style>
</head>

<body>
<div class="app">

  <header class="header">
    <div class="brand">
      <div class="logo">🛡️</div>
      <div>
        <h1>UN VPN</h1>
        <p>Secure · Fast · Private</p>
      </div>
    </div>
    <div class="avatar">👤</div>
  </header>

  <section id="homePage">
    <div class="hero">
      <div class="eyebrow">✦ PREMIUM VPN SERVICE</div>
      <h2>အင်တာနက်ကို<br>လုံခြုံမြန်ဆန်စွာ အသုံးပြုပါ</h2>
      <p>သင့်အတွက် VPN Key ဝယ်ယူပြီး<br>သက်တမ်းနှင့် အသုံးပြုမှုကို စီမံနိုင်ပါသည်။</p>
      <button class="primary" onclick="showPage('buyPage')">VPN Key ဝယ်ယူမည် →</button>
    </div>

    <div class="balance">
      <div>
        <small>သင့် Wallet လက်ကျန်</small>
        <strong id="walletBalance">0 Ks</strong>
      </div>
      <div class="coin">💳</div>
    </div>

    <div class="section-head">
      <h3>VPN Package များ</h3>
      <span>Package ရွေးချယ်ပါ</span>
    </div>

    <div class="grid">
      <div class="plan">
        <div class="plan-icon">🚀</div>
        <h4>Basic</h4>
        <div class="desc">VPN Key တစ်ခု<br>ရက် ၃၀ သက်တမ်း</div>
        <div class="price">ဈေးနှုန်း <small>Admin သတ်မှတ်မည်</small></div>
        <button class="primary" onclick="choosePlan('Basic')">ရွေးချယ်မည်</button>
      </div>

      <div class="plan featured">
        <div class="plan-icon">⚡</div>
        <h4>Standard</h4>
        <div class="desc">VPN Key တစ်ခု<br>ရက် ၉၀ သက်တမ်း</div>
        <div class="price">ဈေးနှုန်း <small>Admin သတ်မှတ်မည်</small></div>
        <button class="primary" onclick="choosePlan('Standard')">ရွေးချယ်မည်</button>
      </div>

      <div class="plan">
        <div class="plan-icon">💎</div>
        <h4>Premium</h4>
        <div class="desc">VPN Key တစ်ခု<br>ရက် ၁၈၀ သက်တမ်း</div>
        <div class="price">ဈေးနှုန်း <small>Admin သတ်မှတ်မည်</small></div>
        <button class="primary" onclick="choosePlan('Premium')">ရွေးချယ်မည်</button>
      </div>

      <div class="plan">
        <div class="plan-icon">🌟</div>
        <h4>Custom</h4>
        <div class="desc">အထူး Package<br>Admin နှင့် ဆက်သွယ်ရန်</div>
        <div class="price">စုံစမ်းရန်</div>
        <button class="primary" onclick="showPage('contactPage')">ဆက်သွယ်မည်</button>
      </div>
    </div>
  </section>

  <section id="buyPage" class="hidden">
    <div class="section-head">
      <h3>VPN Key ဝယ်ယူရန်</h3>
      <span onclick="showPage('homePage')">← နောက်သို့</span>
    </div>
    <div class="panel">
      <div class="field">
        <label>VPN Package</label>
        <select id="package">
          <option>Basic</option>
          <option>Standard</option>
          <option>Premium</option>
        </select>
      </div>
      <div class="field">
        <label>အရေအတွက်</label>
        <select id="quantity">
          <option value="1">1 Key</option>
          <option value="2">2 Keys</option>
          <option value="3">3 Keys</option>
          <option value="5">5 Keys</option>
        </select>
      </div>
      <div class="field">
        <label>ငွေပေးချေမှု နည်းလမ်း</label>
        <select id="paymentMethod">
          <option>KBZPay</option>
          <option>WavePay</option>
          <option>AYA Pay</option>
          <option>Bank Transfer</option>
        </select>
      </div>
      <div class="field">
        <label>ငွေလွှဲသူ ဖုန်းနံပါတ်</label>
        <input id="phone" type="tel" placeholder="09xxxxxxxxx">
      </div>
      <div class="field">
        <label>ငွေလွှဲ Transaction ID</label>
        <input id="transactionId" placeholder="Transaction ID ထည့်ပါ">
      </div>
      <div class="field">
        <label>ငွေလွှဲ Screenshot</label>
        <label class="upload">
          📷 Screenshot ရွေးချယ်ရန်
          <input id="paymentImage" type="file" accept="image/*">
          <div id="fileName" style="margin-top:8px">ပုံမရွေးရသေးပါ</div>
        </label>
      </div>
      <div class="notice">
        ⚠️ ငွေလွှဲပြီးနောက် Screenshot နှင့် Transaction ID ကို စစ်ဆေးရန် တင်ပြရပါမည်။
        Admin အတည်ပြုပြီးမှ VPN Key ထုတ်ပေးမည်ဖြစ်သည်။
      </div>
      <button class="primary" onclick="submitDemo('buy')">ငွေပေးချေမှု တင်ပြမည်</button>
    </div>
  </section>

  <section id="walletPage" class="hidden">
    <div class="section-head">
      <h3>Wallet ငွေဖြည့်ရန်</h3>
    </div>
    <div class="balance">
      <div><small>လက်ရှိ လက်ကျန်</small><strong id="walletBalance2">0 Ks</strong></div>
      <div class="coin">💰</div>
    </div>
    <div class="panel">
      <div class="field">
        <label>ငွေဖြည့်မည့် ပမာဏ (ကျပ်)</label>
        <input id="topupAmount" type="number" min="1000" placeholder="ဥပမာ - 10000">
      </div>
      <div class="field">
        <label>ငွေပေးချေမှု နည်းလမ်း</label>
        <select id="topupMethod">
          <option>KBZPay</option>
          <option>WavePay</option>
          <option>AYA Pay</option>
          <option>Bank Transfer</option>
        </select>
      </div>
      <div class="field">
        <label>ငွေလွှဲ Transaction ID</label>
        <input id="topupTransaction" placeholder="Transaction ID">
      </div>
      <div class="field">
        <label>ငွေလွှဲ Screenshot</label>
        <label class="upload">
          📷 Screenshot ရွေးချယ်ရန်
          <input id="topupImage" type="file" accept="image/*">
          <div id="topupFileName" style="margin-top:8px">ပုံမရွေးရသေးပါ</div>
        </label>
      </div>
      <div class="notice">
        Admin က ငွေလွှဲမှုကို စစ်ဆေးအတည်ပြုပြီးမှ Wallet လက်ကျန် တိုးပေးမည်။
      </div>
      <button class="primary" onclick="submitDemo('topup')">ငွေဖြည့်ရန် တင်ပြမည်</button>
    </div>
  </section>

  <section id="keysPage" class="hidden">
    <div class="section-head"><h3>ကျွန်ုပ်၏ VPN Keys</h3></div>
    <div class="panel">
      <div style="font-size:30px;margin-bottom:12px">🔐</div>
      <h3 style="margin:0 0 8px">VPN Key မရှိသေးပါ</h3>
      <p class="muted">ငွေပေးချေမှုကို Admin အတည်ပြုပြီးနောက် သင့် VPN Key ကို ဒီနေရာမှာ ပြသပေးပါမည်။</p>
      <button class="primary" onclick="showPage('buyPage')">VPN Key ဝယ်ယူမည်</button>
    </div>
    <div class="section-head"><h3>အော်ဒါမှတ်တမ်း</h3></div>
    <div id="ordersList" class="panel">
      <p class="muted">အော်ဒါမှတ်တမ်း မရှိသေးပါ။</p>
    </div>
  </section>

  <section id="contactPage" class="hidden">
    <div class="section-head"><h3>အကူအညီနှင့် ဆက်သွယ်ရန်</h3></div>
    <div class="panel">
      <p>VPN Key၊ ငွေပေးချေမှုနှင့် ပတ်သက်ပြီး အကူအညီလိုအပ်ပါက Admin ကို ဆက်သွယ်ပါ။</p>
      <div class="field">
        <label>Telegram Username</label>
        <input id="adminUsername" placeholder="@YourAdminUsername">
      </div>
      <button class="primary" onclick="contactAdmin()">Telegram မှ ဆက်သွယ်မည်</button>
      <hr>
      <p class="muted">သင့် Telegram User ID ကို Mini App ဖွင့်ချိန်တွင် ရယူနိုင်ရန် Telegram အတွင်းမှ ဖွင့်ပါ။</p>
    </div>
  </section>

</div>

<nav class="nav">
  <div class="nav-inner">
    <button class="active" data-page="homePage" onclick="showPage('homePage')">
      <span class="ico">⌂</span>ပင်မ
    </button>
    <button data-page="buyPage" onclick="showPage('buyPage')">
      <span class="ico">🛒</span>ဝယ်ယူရန်
    </button>
    <button data-page="walletPage" onclick="showPage('walletPage')">
      <span class="ico">💳</span>Wallet
    </button>
    <button data-page="keysPage" onclick="showPage('keysPage')">
      <span class="ico">🔐</span>My Keys
    </button>
    <button data-page="contactPage" onclick="showPage('contactPage')">
      <span class="ico">☰</span>အကောင့်
    </button>
  </div>
</nav>

<div id="toast" class="toast"></div>

<script>
const tg = window.Telegram?.WebApp;
if (tg) {
  tg.ready();
  tg.expand();
  try { tg.setHeaderColor('#101827'); } catch(e) {}
}

const telegramUser = tg?.initDataUnsafe?.user || null;

function showPage(pageId) {
  document.querySelectorAll('.app > section').forEach(el => el.classList.add('hidden'));
  const page = document.getElementById(pageId);
  if (page) page.classList.remove('hidden');

  document.querySelectorAll('.nav button').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.page === pageId);
  });
  window.scrollTo({top:0,behavior:'smooth'});
}

function choosePlan(name) {
  document.getElementById('package').value = name;
  showPage('buyPage');
}

function toast(message) {
  const el = document.getElementById('toast');
  el.textContent = message;
  el.style.display = 'block';
  setTimeout(() => el.style.display = 'none', 3500);
}

document.getElementById('paymentImage').addEventListener('change', function() {
  document.getElementById('fileName').textContent =
    this.files[0]?.name || 'ပုံမရွေးရသေးပါ';
});

document.getElementById('topupImage').addEventListener('change', function() {
  document.getElementById('topupFileName').textContent =
    this.files[0]?.name || 'ပုံမရွေးရသေးပါ';
});

function submitDemo(type) {
  if (!telegramUser && tg) {
    toast('Telegram မှ Mini App ကို ပြန်ဖွင့်ပါ။');
    return;
  }

  const fileInput = document.getElementById(
    type === 'buy' ? 'paymentImage' : 'topupImage'
  );

  const phone = document.getElementById('phone');
  const txn = document.getElementById(
    type === 'buy' ? 'transactionId' : 'topupTransaction'
  );

  if (type === 'buy' && !phone.value.trim()) {
    toast('ဖုန်းနံပါတ် ထည့်ပါ။');
    return;
  }
  if (type === 'topup') {
    const amount = Number(document.getElementById('topupAmount').value);
    if (!amount || amount < 1000) {
      toast('ငွေဖြည့်ပမာဏ အနည်းဆုံး ၁,၀၀၀ ကျပ် ထည့်ပါ။');
      return;
    }
  }
  if (!txn.value.trim() || !fileInput.files.length) {
    toast('Transaction ID နှင့် Screenshot ထည့်ပါ။');
    return;
  }

  toast('UI စမ်းသပ်မှုသာ ဖြစ်ပါသည်။ Backend API ချိတ်ဆက်ပြီးမှ တင်ပြမှု အမှန်တကယ် အလုပ်လုပ်ပါမည်။');
}

function contactAdmin() {
  let username = document.getElementById('adminUsername').value.trim();
  username = username.replace(/^@/, '');
  if (!username) {
    toast('Admin Telegram Username ထည့်ပါ။');
    return;
  }
  if (!/^[a-zA-Z0-9_]{5,32}$/.test(username)) {
    toast('Telegram Username ကို စစ်ဆေးပါ။');
    return;
  }
  const url = 'https://t.me/' + username;
  if (tg?.openTelegramLink) tg.openTelegramLink(url);
  else window.open(url, '_blank');
}
</script>
</body>
</html>
HTML

cat > /etc/nginx/sites-available/vpn-mini <<NGINX
server {
    listen ${PORT};
    listen [::]:${PORT};
    server_name _;

    root ${APP_DIR};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ /\. {
        deny all;
    }

    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;
}
NGINX

ln -sfn /etc/nginx/sites-available/vpn-mini /etc/nginx/sites-enabled/vpn-mini

nginx -t
systemctl enable nginx
systemctl restart nginx

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
    ufw allow "${PORT}/tcp"
fi

SERVER_IP="$(hostname -I | awk '{print $1}')"

echo
echo "======================================"
echo " Telegram VPN Mini App UI Installed"
echo "======================================"
echo "Directory : ${APP_DIR}"
echo "Port      : ${PORT}"
echo "URL       : http://${SERVER_IP}:${PORT}"
echo
echo "IMPORTANT:"
echo "1. This installer creates the frontend UI only."
echo "2. Payment submission, screenshot upload, wallet,"
echo "   admin approval and Outline key generation need a backend."
echo "3. Telegram Mini Apps require HTTPS for production."
echo "   Configure HTTPS on port ${PORT} before adding it to your bot."
echo "======================================"
