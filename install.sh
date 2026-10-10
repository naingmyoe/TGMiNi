#!/usr/bin/env bash
set -Eeuo pipefail

# VPN Pro Telegram Mini App installer/updater
# - Uses existing Nginx port 8082
# - Does not stop or replace unrelated services (including Node on 8081)
# - Updates /var/www/vpn-mini/index.html safely
# - This is a frontend demo; payment approval, wallet, and Outline API need a backend.

PORT=8082
WEB_ROOT="/var/www/vpn-mini"
INDEX_FILE="${WEB_ROOT}/index.html"
SITE_NAME="vpn-mini-8082"
SITE_AVAILABLE="/etc/nginx/sites-available/${SITE_NAME}"
SITE_ENABLED="/etc/nginx/sites-enabled/${SITE_NAME}"
BACKUP_DIR="/var/backups/vpn-mini"
TMP_DIR="$(mktemp -d)"
NEW_INDEX="${TMP_DIR}/index.html"
NEW_SITE="${TMP_DIR}/${SITE_NAME}"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run: sudo bash install.sh"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
if ! command -v nginx >/dev/null 2>&1; then
  apt-get update
  apt-get install -y nginx
fi

mkdir -p "$WEB_ROOT" "$BACKUP_DIR" /etc/nginx/sites-available /etc/nginx/sites-enabled

# Refuse to take over 8082 if a non-Nginx process owns it.
if command -v ss >/dev/null 2>&1; then
  PORT_INFO="$(ss -ltnp "sport = :${PORT}" 2>/dev/null || true)"
  if grep -q 'users:' <<<"$PORT_INFO" && ! grep -q 'nginx' <<<"$PORT_INFO"; then
    echo "ERROR: Port ${PORT} is occupied by a non-Nginx service."
    echo "$PORT_INFO"
    echo "Nothing was stopped. Resolve the port conflict, then run installer again."
    exit 1
  fi
fi

# Back up the current UI before replacing it.
if [[ -f "$INDEX_FILE" ]]; then
  cp -a "$INDEX_FILE" "${BACKUP_DIR}/index.html.$(date +%Y%m%d-%H%M%S).bak"
fi

cat > "$NEW_INDEX" <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="theme-color" content="#0867d9">
<title>VPN Pro — Telegram Mini Web</title>
<style>
:root{--blue:#0877f9;--deep:#0758c8;--ink:#102b52;--muted:#71829a;--line:#e2eaf4;--pale:#eef6ff;--green:#12a978;--red:#df5361}
*{box-sizing:border-box}body{margin:0;background:#f2f7fd;color:var(--ink);font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Arial,sans-serif;font-size:14px}
button,input,select{font:inherit}button{cursor:pointer}.app{max-width:520px;margin:0 auto;min-height:100vh;background:#f5f9fe;position:relative;padding-bottom:82px;box-shadow:0 0 35px #102b520b}
.topbar{height:58px;background:linear-gradient(115deg,#0877f9,#075bcf);color:white;display:flex;align-items:center;padding:0 17px;gap:12px;box-shadow:0 4px 14px #075bcf22;position:sticky;top:0;z-index:5}
.brandmark{width:34px;height:34px;border-radius:50%;display:grid;place-items:center;background:#ffffff24;font-size:20px}.top-title{font-size:16px;font-weight:800;letter-spacing:.2px}.top-sub{font-size:10px;opacity:.8;margin-top:2px}.grow{flex:1}.icon-btn{border:0;background:#ffffff20;color:white;border-radius:12px;padding:8px 10px}
.page{display:none;padding:15px}.page.active{display:block}.hero{border-radius:20px;overflow:hidden;padding:22px 18px 25px;background:linear-gradient(160deg,#0785ff,#0751c1);color:#fff;position:relative;box-shadow:0 10px 22px #0877f927}
.hero:after{content:"";position:absolute;left:-8%;right:-8%;bottom:-46px;height:95px;background:#ffffff16;border-radius:50% 50% 0 0;transform:rotate(-4deg)}.hero-row{display:flex;align-items:center;gap:12px;position:relative;z-index:1}.shield{width:54px;height:54px;display:grid;place-items:center;border-radius:18px;background:#ffffff20;font-size:28px}.hero h1{font-size:23px;margin:0 0 5px}.hero p{margin:0;color:#dbeeff;font-size:12px}.hero-foot{display:flex;gap:16px;margin-top:22px;font-size:11px;color:#e3f2ff;position:relative;z-index:1}
.wallet{background:white;border:1px solid #e4edf7;border-radius:16px;padding:15px;display:flex;align-items:center;gap:12px;margin-top:14px;box-shadow:0 4px 14px #12345b08}.tile-icon{width:40px;height:40px;border-radius:13px;background:#eaf4ff;color:#0877f9;display:grid;place-items:center;font-size:20px;flex-shrink:0}.wallet-label,.small-muted{color:var(--muted);font-size:11px}.wallet-value{font-weight:800;font-size:20px;margin-top:3px}.btn{border:0;border-radius:11px;background:var(--blue);color:#fff;padding:11px 15px;font-weight:750;box-shadow:0 4px 10px #0877f921}.btn:active{transform:scale(.98)}.btn.light{background:#edf5ff;color:#0877f9;box-shadow:none}.btn.outline{background:white;color:#0877f9;border:1px solid #b7d5fb;box-shadow:none}.btn.green{background:#e6faf2;color:#079a6b;box-shadow:none}.btn.block{width:100%;margin-top:12px}.menu-list{display:grid;gap:9px;margin-top:13px}.menu-item{display:flex;align-items:center;gap:12px;padding:12px;background:#fff;border:1px solid #e6edf6;border-radius:15px;text-align:left;width:100%;color:inherit;box-shadow:0 3px 10px #173b6306}.menu-item .mi-text{flex:1}.menu-item strong{display:block;font-size:13px}.menu-item small{display:block;color:var(--muted);font-size:11px;margin-top:4px}.chev{color:#8aa0b9;font-size:22px}.section-head{display:flex;align-items:center;justify-content:space-between;margin:4px 0 13px}.section-head h2{font-size:19px;margin:0}.section-head p{margin:5px 0 0;color:var(--muted);font-size:11px}.back{border:0;background:white;color:#24476f;border-radius:10px;padding:9px 12px;margin-bottom:13px}.plan{background:white;border:1px solid #e2eaf4;border-radius:17px;padding:15px;margin-bottom:11px;position:relative}.plan.popular{border:1.5px solid #6aa8ff;box-shadow:0 5px 18px #0877f914}.popular-tag{position:absolute;right:12px;top:-9px;background:#0877f9;color:white;border-radius:20px;padding:4px 9px;font-size:10px}.plan-row{display:flex;align-items:center;gap:12px}.plan-info{flex:1}.plan-info strong{font-size:14px}.plan-info small{display:block;color:var(--muted);font-size:11px;margin-top:4px}.price{font-weight:850;font-size:17px;margin-top:8px}.price small{font-size:10px;color:var(--muted);font-weight:500}.notice{border-radius:13px;background:#edf6ff;border:1px solid #d6e9ff;padding:12px;color:#42658d;font-size:11px;line-height:1.55;margin:12px 0}.panel{background:white;border:1px solid #e3ebf5;border-radius:15px;padding:14px;margin:12px 0}.panel h3{margin:0 0 12px;font-size:13px}.method{display:flex;align-items:center;gap:11px;border:1px solid #e0eaf5;border-radius:13px;padding:11px;margin-top:8px}.method.selected{border-color:#6eafff;background:#f2f8ff}.method .mi-text{flex:1;font-weight:700}.radio{width:17px;height:17px;border:2px solid #aac1db;border-radius:50%}.selected .radio{border:5px solid #0877f9}.field{width:100%;border:1px solid #dce7f3;border-radius:11px;padding:12px;background:#fff;color:var(--ink);outline:none}.field:focus{border-color:#66a8ff}.field-label{font-size:11px;color:#637b99;display:block;margin:12px 0 6px}.upload{border:1.5px dashed #8dbdf5;border-radius:14px;background:#f4f9ff;padding:20px 10px;text-align:center;color:#0877f9;display:block;width:100%;margin-top:12px}.upload input{display:none}.upload b{display:block;font-size:12px;margin-top:8px}.upload small{display:block;color:#7c91aa;font-size:10px;margin-top:5px}.details{display:grid;gap:12px}.detail{display:flex;justify-content:space-between;gap:10px;font-size:11px}.detail span{color:var(--muted)}.detail strong{text-align:right}.status-circle{width:72px;height:72px;border-radius:50%;background:#e7f3ff;color:#0877f9;display:grid;place-items:center;font-size:34px;margin:8px auto 14px}.center{text-align:center}.center h2{margin:0 0 7px}.center p{color:var(--muted);font-size:12px;line-height:1.6;margin:0}.steps{margin-top:16px}.step{display:flex;gap:12px;padding:10px 0;align-items:flex-start}.dot{width:24px;height:24px;border-radius:50%;display:grid;place-items:center;background:#e7eef7;color:#8aa0b9;flex-shrink:0;font-size:12px}.dot.done{background:#dff8ed;color:#0aa474}.dot.current{background:#0877f9;color:white}.step strong{font-size:12px;display:block}.step small{display:block;color:var(--muted);font-size:10px;margin-top:4px}.key-card{border:1px solid #a5e5cd;background:#f1fff8;border-radius:16px;padding:14px;margin-bottom:12px}.key-card.expired{border-color:#f1c6cb;background:#fff7f8}.key-top{display:flex;align-items:center;gap:7px;font-size:11px}.pill{border-radius:20px;padding:4px 8px;background:#d8f8e9;color:#07996b;font-weight:800}.expired .pill{background:#ffe0e3;color:#d74958}.key-name{font-weight:800;margin:12px 0 4px}.key-sub{color:var(--muted);font-size:10px}.key-value{display:flex;align-items:center;gap:5px;margin-top:12px}.key-value code{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;background:white;border:1px solid #e3eee9;border-radius:8px;padding:9px;font-size:10px}.copy{border:1px solid #d8e6f4;background:white;color:#0877f9;border-radius:8px;padding:8px}.key-actions{display:flex;gap:8px;margin-top:10px}.key-actions .btn{flex:1;padding:10px 8px;font-size:11px}.tabs{display:flex;background:#eaf1fa;padding:4px;border-radius:12px;margin:12px 0}.tabs button{flex:1;border:0;border-radius:9px;background:transparent;padding:9px;color:#637b99;font-size:11px;font-weight:750}.tabs button.active{background:#0877f9;color:#fff}.bottom-nav{position:fixed;bottom:0;left:50%;transform:translateX(-50%);width:min(520px,100%);height:68px;background:#ffffffed;backdrop-filter:blur(14px);border-top:1px solid #e5edf7;display:flex;justify-content:space-around;z-index:8;padding-bottom:env(safe-area-inset-bottom)}.nav-btn{border:0;background:none;color:#8799b0;font-size:10px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;min-width:75px}.nav-btn .nav-icon{font-size:20px}.nav-btn.active{color:#0877f9;font-weight:800}.toast{position:fixed;left:50%;bottom:85px;transform:translateX(-50%);background:#142e4e;color:#fff;padding:11px 15px;border-radius:12px;font-size:12px;z-index:20;box-shadow:0 6px 20px #0002;display:none;max-width:90%;text-align:center}.empty{padding:30px 15px;text-align:center;color:var(--muted);font-size:12px}
@media(min-width:600px){body{padding:20px 0}.app{border-radius:24px;overflow:hidden;min-height:calc(100vh - 40px)}.bottom-nav{bottom:20px;border-radius:0 0 24px 24px}.topbar{position:relative}}
</style>
</head>
<body>
<div class="app">
  <header class="topbar"><div class="brandmark">✈</div><div><div class="top-title">VPN Pro</div><div class="top-sub">Telegram Mini Web · Fast · Secure · Global</div></div><div class="grow"></div><button class="icon-btn" onclick="showPage('account')" aria-label="Account">♙</button></header>
  <main>
    <section id="home" class="page active">
      <div class="hero"><div class="hero-row"><div class="shield">🛡</div><div><h1>VPN Pro</h1><p>Fast · Secure · Global</p></div></div><div class="hero-foot"><span>✦ Secure Connection</span><span>ϟ High Speed</span><span>◎ Global Access</span></div></div>
      <div class="wallet"><div class="tile-icon">▣</div><div class="grow"><div class="wallet-label">Wallet Balance</div><div class="wallet-value" id="balance">0 Ks</div></div><button class="btn" onclick="showPage('topup')">＋ Top Up</button></div>
      <div class="menu-list">
        <button class="menu-item" onclick="showPage('packages')"><span class="tile-icon">ϟ</span><span class="mi-text"><strong>Buy VPN Key</strong><small>Choose a plan and get your key</small></span><span class="chev">›</span></button>
        <button class="menu-item" onclick="showPage('keys')"><span class="tile-icon">⚿</span><span class="mi-text"><strong>My Keys</strong><small>View your purchased keys</small></span><span class="chev">›</span></button>
        <button class="menu-item" onclick="showPage('topup')"><span class="tile-icon">▣</span><span class="mi-text"><strong>Top Up</strong><small>Add balance to your wallet</small></span><span class="chev">›</span></button>
        <button class="menu-item" onclick="support()"><span class="tile-icon">➤</span><span class="mi-text"><strong>Telegram Support</strong><small>Chat with our support team</small></span><span class="chev">›</span></button>
        <button class="menu-item" onclick="support()"><span class="tile-icon">☎</span><span class="mi-text"><strong>Call Support</strong><small>Contact customer service</small></span><span class="chev">›</span></button>
      </div>
      <div class="notice">🛡 Stay Connected<br>Secure access, anytime and anywhere.</div>
    </section>

    <section id="packages" class="page">
      <button class="back" onclick="showPage('home')">‹ Back</button>
      <div class="section-head"><div><h2>VPN Packages</h2><p>Choose the best plan for your needs</p></div></div>
      <div id="plans"></div>
      <div class="notice">⚡ Secure VPN access · Multi-device support depends on your plan.</div>
    </section>

    <section id="payment" class="page">
      <button class="back" onclick="showPage('packages')">‹ Back</button>
      <div class="section-head"><div><h2>Direct Payment</h2><p>Please make a payment and upload your screenshot for verification.</p></div></div>
      <div class="notice">ⓘ We accept KBZPay and WavePay. After payment, upload your screenshot. An admin must verify it before the order is approved.</div>
      <div class="panel"><h3>Payment Method</h3>
        <div class="method selected" onclick="selectMethod('KBZPay',this)"><div class="tile-icon">K</div><div class="mi-text">KBZPay</div><div class="radio"></div></div>
        <div class="method" onclick="selectMethod('WavePay',this)"><div class="tile-icon">W</div><div class="mi-text">WavePay</div><div class="radio"></div></div>
      </div>
      <div class="panel"><h3>Recipient Information</h3><div class="details"><div class="detail"><span>Account Name</span><strong id="recipientName">Configure in admin</strong></div><div class="detail"><span>Phone Number</span><strong id="recipientPhone">Configure in admin</strong></div><div class="detail"><span>Account</span><strong id="recipientMethod">KBZPay / WavePay</strong></div></div></div>
      <div class="panel"><h3>Order Summary</h3><div class="details"><div class="detail"><span>Package</span><strong id="orderPlan">7 Days</strong></div><div class="detail"><span>Amount</span><strong id="orderPrice" style="color:#0877f9;font-size:16px">10,000 Ks</strong></div></div></div>
      <label class="field-label" for="payerName">Your name</label><input id="payerName" class="field" placeholder="Enter payer name">
      <label class="field-label" for="payerPhone">Phone number</label><input id="payerPhone" class="field" type="tel" placeholder="09xxxxxxxxx">
      <label class="upload" for="proof"><span style="font-size:24px">▧</span><b id="uploadLabel">Upload Payment Screenshot</b><small>Tap to select image (JPG, PNG)</small><input id="proof" type="file" accept="image/*" onchange="fileSelected(this)"></label>
      <button class="btn block" onclick="submitPayment()">Submit Payment Proof</button>
      <p class="small-muted center" style="margin-top:10px">Demo UI only: submission is not sent to an admin until a backend is connected.</p>
    </section>

    <section id="submitted" class="page">
      <div class="status-circle">◷</div><div class="center"><h2>Payment Submitted</h2><p>Your payment details have been recorded in this demo.<br>Please wait for admin approval after backend integration.</p></div>
      <div class="panel" style="margin-top:20px"><div class="details"><div class="detail"><span>Order ID</span><strong id="submittedId">DEMO-0001</strong></div><div class="detail"><span>Amount</span><strong id="submittedAmount">10,000 Ks</strong></div><div class="detail"><span>Payment Method</span><strong id="submittedMethod">KBZPay</strong></div><div class="detail"><span>Submitted At</span><strong id="submittedAt">Just now</strong></div></div></div>
      <div class="panel steps"><div class="step"><div class="dot done">✓</div><div><strong>Payment Info Received</strong><small>Saved in this demo</small></div></div><div class="step"><div class="dot current">•</div><div><strong>Waiting for Admin Review</strong><small>Backend approval not connected</small></div></div><div class="step"><div class="dot">•</div><div><strong>Payment Approved</strong><small>Pending</small></div></div><div class="step"><div class="dot">•</div><div><strong>VPN Key Will Be Sent</strong><small>Outline API integration required</small></div></div></div>
      <button class="btn outline block" onclick="support()">➤ Open Telegram Support</button><button class="btn block" onclick="showPage('home')">Back to Home</button>
    </section>

    <section id="keys" class="page">
      <div class="section-head"><div><h2>My VPN Keys</h2><p>Manage your VPN keys and renew when needed.</p></div></div>
      <div class="tabs"><button class="active" onclick="keyTab('active',this)">Active (0)</button><button onclick="keyTab('expired',this)">Expired (0)</button></div>
      <div id="keyList" class="empty">No VPN keys yet. Buy a package to get started.</div>
      <button class="menu-item" onclick="showPage('packages')"><span class="tile-icon">🛡</span><span class="mi-text"><strong>Need a longer plan?</strong><small>Explore VPN packages and choose the best plan.</small></span><span class="chev">›</span></button>
    </section>

    <section id="topup" class="page">
      <button class="back" onclick="showPage('home')">‹ Back</button>
      <div class="section-head"><div><h2>Wallet Top Up</h2><p>Add balance to your wallet</p></div></div>
      <div class="wallet"><div class="tile-icon">▣</div><div><div class="wallet-label">Current Balance</div><div class="wallet-value" id="topupBalance">0 Ks</div></div></div>
      <div class="panel"><h3>Choose Amount</h3><div class="tabs"><button onclick="setTopup(5000,this)">5,000 Ks</button><button class="active" onclick="setTopup(10000,this)">10,000 Ks</button><button onclick="setTopup(25000,this)">25,000 Ks</button></div><label class="field-label" for="customTopup">Custom amount (Ks)</label><input id="customTopup" class="field" type="number" min="1000" value="10000" oninput="topupAmount=Number(this.value)||0"></div>
      <button class="btn block" onclick="startTopup()">Continue to Payment</button>
      <div class="notice">Wallet credits must only be added after a trusted backend confirms admin approval. This demo does not store or credit real funds.</div>
    </section>

    <section id="account" class="page">
      <div class="section-head"><div><h2>Account</h2><p>Your Telegram Mini App profile</p></div></div>
      <div class="panel"><div class="tile-icon">♙</div><h3 style="margin-top:12px">Telegram User</h3><div class="details"><div class="detail"><span>Telegram ID</span><strong id="telegramId">Not available</strong></div><div class="detail"><span>Account Status</span><strong>Demo mode</strong></div></div></div>
      <button class="menu-item" onclick="support()"><span class="tile-icon">➤</span><span class="mi-text"><strong>Contact Support</strong><small>Get help with your account</small></span><span class="chev">›</span></button>
      <div class="notice">For production, verify Telegram WebApp initData on your server. Never trust a Telegram ID supplied only by the browser.</div>
    </section>
  </main>
  <nav class="bottom-nav">
    <button class="nav-btn active" data-page="home" onclick="showPage('home')"><span class="nav-icon">⌂</span>Home</button>
    <button class="nav-btn" data-page="keys" onclick="showPage('keys')"><span class="nav-icon">⚿</span>Keys</button>
    <button class="nav-btn" data-page="account" onclick="showPage('account')"><span class="nav-icon">♙</span>Account</button>
  </nav>
</div>
<div class="toast" id="toast"></div>
<script>
const plans=[
 {days:1,label:"1 Day",sub:"24 hours",price:2000},
 {days:3,label:"3 Days",sub:"72 hours",price:5000},
 {days:7,label:"7 Days",sub:"1 week",price:10000,popular:true},
 {days:30,label:"30 Days",sub:"1 month",price:25000}
];
let selectedPlan=plans[2], paymentMethod="KBZPay", topupAmount=10000, selectedProof=null;
const money=n=>Number(n||0).toLocaleString("en-US")+" Ks";
function renderPlans(){document.getElementById("plans").innerHTML=plans.map((p,i)=>`<div class="plan ${p.popular?'popular':''}">${p.popular?'<span class="popular-tag">Popular</span>':''}<div class="plan-row"><div class="tile-icon">🛡</div><div class="plan-info"><strong>${p.label}</strong><small>${p.sub}</small><div class="price">${money(p.price)}</div></div><button class="btn" onclick="buyPlan(${i})">Buy Now</button></div></div>`).join("")}
function showPage(id){document.querySelectorAll(".page").forEach(p=>p.classList.toggle("active",p.id===id));document.querySelectorAll(".nav-btn").forEach(b=>b.classList.toggle("active",b.dataset.page===id));window.scrollTo({top:0,behavior:"smooth"});if(id==="account")loadTelegramProfile()}
function buyPlan(i){selectedPlan=plans[i];document.getElementById("orderPlan").textContent=selectedPlan.label;document.getElementById("orderPrice").textContent=money(selectedPlan.price);showPage("payment")}
function selectMethod(m,el){paymentMethod=m;document.querySelectorAll(".method").forEach(x=>x.classList.remove("selected"));el.classList.add("selected");document.getElementById("recipientMethod").textContent=m}
function fileSelected(input){selectedProof=input.files&&input.files[0];document.getElementById("uploadLabel").textContent=selectedProof?selectedProof.name:"Upload Payment Screenshot"}
function submitPayment(){const name=document.getElementById("payerName").value.trim(),phone=document.getElementById("payerPhone").value.trim();if(!name||!phone){toast("Please enter your name and phone number.");return}if(!selectedProof){toast("Please upload your payment screenshot.");return}document.getElementById("submittedId").textContent="DEMO-"+Date.now().toString().slice(-6);document.getElementById("submittedAmount").textContent=money(selectedPlan.price);document.getElementById("submittedMethod").textContent=paymentMethod;document.getElementById("submittedAt").textContent=new Date().toLocaleString();showPage("submitted")}
function keyTab(tab,el){document.querySelectorAll("#keys .tabs button").forEach(b=>b.classList.remove("active"));el.classList.add("active");document.getElementById("keyList").innerHTML=tab==="active"?'<div class="empty">No active VPN keys yet.</div>':'<div class="empty">No expired VPN keys.</div>'}
function setTopup(n,el){topupAmount=n;document.getElementById("customTopup").value=n;document.querySelectorAll("#topup .tabs button").forEach(b=>b.classList.remove("active"));el.classList.add("active")}
function startTopup(){topupAmount=Number(document.getElementById("customTopup").value)||0;if(topupAmount<1000){toast("Enter an amount of at least 1,000 Ks.");return}selectedPlan={label:"Wallet Top Up",price:topupAmount};document.getElementById("orderPlan").textContent="Wallet Top Up";document.getElementById("orderPrice").textContent=money(topupAmount);showPage("payment")}
function support(){toast("Set your Telegram support username in the app configuration.");}
function toast(s){const el=document.getElementById("toast");el.textContent=s;el.style.display="block";clearTimeout(window.toastTimer);window.toastTimer=setTimeout(()=>el.style.display="none",2800)}
function loadTelegramProfile(){try{const tg=window.Telegram&&window.Telegram.WebApp;if(tg){tg.ready();tg.expand();const u=tg.initDataUnsafe&&tg.initDataUnsafe.user;document.getElementById("telegramId").textContent=u?String(u.id):"Not available"}}catch(e){}}
renderPlans();loadTelegramProfile();
</script>
<script src="https://telegram.org/js/telegram-web-app.js"></script>
</body>
</html>
HTML

cat > "$NEW_SITE" <<'NGINX'
server {
    listen 8082;
    listen [::]:8082;
    server_name _;

    root /var/www/vpn-mini;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|png|jpg|jpeg|svg|ico|webp|woff2?)$ {
        expires 7d;
        access_log off;
        try_files $uri =404;
    }
}
NGINX

# Do not overwrite unrelated server blocks: only manage this named site.
if [[ -e "$SITE_AVAILABLE" && ! -L "$SITE_ENABLED" ]]; then
  cp -a "$SITE_AVAILABLE" "${BACKUP_DIR}/nginx-site.$(date +%Y%m%d-%H%M%S).bak"
fi

# Install the UI atomically so a partial write cannot leave a broken index.
install -m 0644 "$NEW_INDEX" "${INDEX_FILE}.new"
mv -f "${INDEX_FILE}.new" "$INDEX_FILE"

install -m 0644 "$NEW_SITE" "$SITE_AVAILABLE"
ln -sfn "$SITE_AVAILABLE" "$SITE_ENABLED"

if ! nginx -t; then
  echo "ERROR: nginx config test failed. Restoring previous UI if backup exists."
  latest_backup="$(ls -1t "${BACKUP_DIR}"/index.html.*.bak 2>/dev/null | head -n1 || true)"
  if [[ -n "$latest_backup" ]]; then cp -a "$latest_backup" "$INDEX_FILE"; fi
  exit 1
fi

if systemctl is-active --quiet nginx; then
  systemctl reload nginx
else
  systemctl start nginx
fi

echo
echo "VPN Pro Mini App UI installed/updated."
echo "Web root: ${WEB_ROOT}"
echo "Port: ${PORT}"
echo "Test: curl -I http://127.0.0.1:${PORT}/"
echo "Open: http://YOUR_SERVER_IP:${PORT}/"
echo
echo "NOTE: This is a frontend demo. Real payment approval, Telegram bot notifications,"
echo "wallet crediting, and Outline key creation require a backend/API."
echo "Telegram Mini Apps require HTTPS for production."
