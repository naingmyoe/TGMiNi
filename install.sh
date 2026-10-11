#!/bin/bashd

DOMAIN="tgmini.ownvpnnaing.store"
PORT="8083"
APP_DIR="/var/www/tgmini"

echo "=== [1/5] Updating system and installing dependencies ==="
apt update && apt upgrade -y
apt install -y curl nginx certbot git build-essential

echo "=== [2/5] Installing Node.js & PM2 ==="
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs
npm install -g pm2

echo "=== [3/5] Setting up App Directory and Files ==="
mkdir -p $APP_DIR
cd $APP_DIR

# Create package.json
cat << 'EOF' > package.json
{
  "name": "tgmini-vpn",
  "version": "1.0.0",
  "description": "Telegram Mini App for VPN Pro",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Create server.js (Fixed Cannot GET / error)
cat << 'EOF' > server.js
const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname)));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, '127.0.0.1', () => {
    console.log(`Telegram Mini App running on internal port ${PORT}`);
});
EOF

# Create index.html (UI)
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VPN Pro - Telegram Mini Web</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f6f9; color: #333; }
        .tg-blue { background-color: #2481cc; }
        .tg-blue-text { color: #2481cc; }
    </style>
</head>
<body class="bg-gray-100 flex justify-center items-center min-h-screen">

    <div class="w-full max-w-md bg-white min-h-screen shadow-2xl flex flex-col relative pb-20">
        
        <!-- Header -->
        <div class="tg-blue text-white p-4 flex items-center justify-between shadow-md">
            <div class="flex items-center space-x-3">
                <i class="fa-solid fa-paper-plane text-xl"></i>
                <div>
                    <h1 class="font-bold text-lg leading-tight">VPN Pro</h1>
                    <p class="text-xs text-blue-100 opacity-90">mini app</p>
                </div>
            </div>
            <button onclick="showScreen('home')" class="text-white text-lg focus:outline-none">
                <i class="fa-solid fa-ellipsis-vertical"></i>
            </button>
        </div>

        <!-- MAIN CONTAINER / SCREENS -->
        <div id="app-container" class="flex-1 overflow-y-auto p-4 space-y-4">

            <!-- SCREEN 1: HOME -->
            <div id="screen-home" class="screen space-y-4">
                <div class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white p-5 rounded-2xl shadow-lg relative overflow-hidden">
                    <div class="relative z-10">
                        <h2 class="text-xl font-extrabold">VPN Pro</h2>
                        <p class="text-xs text-blue-100 mt-1">Fast • Secure • Global</p>
                        <p class="text-sm font-medium mt-3">Get your VPN key easily via Telegram</p>
                    </div>
                </div>

                <div class="bg-white border border-gray-100 rounded-xl p-4 shadow-sm flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-lg">
                            <i class="fa-solid fa-wallet"></i>
                        </div>
                        <div>
                            <p class="text-xs text-gray-500">Wallet Balance</p>
                            <h3 class="text-lg font-bold text-gray-800">0 Ks</h3>
                        </div>
                    </div>
                    <button onclick="showScreen('topup')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-full shadow">
                        + Top Up
                    </button>
                </div>

                <div class="space-y-2">
                    <div onclick="showScreen('packages')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-bolt"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Buy VPN Key</h4>
                                <p class="text-xs text-gray-500">Choose a plan and get your key</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div onclick="showScreen('keys')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-key"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">My Keys</h4>
                                <p class="text-xs text-gray-500">View your purchased keys</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div onclick="showScreen('topup')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-wallet"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Top Up</h4>
                                <p class="text-xs text-gray-500">Add balance to your wallet</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>
                </div>
            </div>

            <!-- SCREEN 2: PACKAGES -->
            <div id="screen-packages" class="screen hidden space-y-3">
                <div class="mb-2">
                    <h2 class="text-lg font-bold text-gray-800">VPN Packages</h2>
                    <p class="text-xs text-gray-500">Choose the best plan for your needs</p>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-shield-halved"></i></div>
                        <div>
                            <h4 class="text-sm font-bold text-gray-800">7 Days</h4>
                            <p class="text-xs text-gray-400">1 week</p>
                            <p class="text-sm font-extrabold text-blue-600 mt-1">10,000 Ks</p>
                        </div>
                    </div>
                    <button onclick="selectPackage('7 Days', '10,000 Ks')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-lg shadow">Buy Now</button>
                </div>
            </div>

            <!-- SCREEN 3: PAYMENT -->
            <div id="screen-payment" class="screen hidden space-y-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-800">Direct Payment</h2>
                    <p class="text-xs text-gray-500">Please make payment and submit proof.</p>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-2 text-xs">
                    <div class="flex justify-between py-1"><span class="text-gray-500">Package</span><span class="font-semibold text-gray-800" id="lbl-pkg">7 Days</span></div>
                    <div class="flex justify-between py-1"><span class="text-gray-500">Amount</span><span class="font-bold text-blue-600 text-sm" id="lbl-amt">10,000 Ks</span></div>
                </div>
                <button onclick="submitPayment()" class="w-full tg-blue text-white py-3 rounded-xl font-bold text-sm shadow-lg">Submit Payment Proof</button>
            </div>

            <!-- SCREEN 4: SUBMITTED -->
            <div id="screen-submitted" class="screen hidden space-y-4 text-center">
                <div class="pt-4 flex flex-col items-center">
                    <div class="w-16 h-16 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-3xl mb-3"><i class="fa-regular fa-clock"></i></div>
                    <h2 class="text-lg font-bold text-gray-800">Payment Submitted</h2>
                    <p class="text-xs text-gray-500 mt-1">Waiting for admin review.</p>
                </div>
            </div>

            <!-- SCREEN 5: KEYS -->
            <div id="screen-keys" class="screen hidden space-y-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-800">My VPN Keys</h2>
                    <p class="text-xs text-gray-500">Manage your keys.</p>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-3">
                    <span class="bg-green-100 text-green-700 text-[10px] font-bold px-2.5 py-1 rounded-full">Active</span>
                    <h4 class="text-xs font-bold text-gray-800">Outline VPN (VLESS / 100 Mbps)</h4>
                    <p class="text-xs font-mono text-gray-600 bg-gray-50 p-2 rounded">vpn-7d-8F3A98ZC-4kJ2</p>
                </div>
            </div>

            <!-- SCREEN 6: TOPUP -->
            <div id="screen-topup" class="screen hidden space-y-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-800">Top Up Wallet</h2>
                    <p class="text-xs text-gray-500">Add balance to your account.</p>
                </div>
            </div>

        </div>

        <!-- Bottom Navigation Bar -->
        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-200 py-2 px-6 flex justify-around items-center shadow-lg">
            <button onclick="showScreen('home')" id="nav-home" class="flex flex-col items-center text-blue-600 focus:outline-none">
                <i class="fa-solid fa-house text-lg"></i>
                <span class="text-[10px] mt-0.5 font-medium">Home</span>
            </button>
            <button onclick="showScreen('keys')" id="nav-keys" class="flex flex-col items-center text-gray-400 focus:outline-none">
                <i class="fa-solid fa-key text-lg"></i>
                <span class="text-[10px] mt-0.5 font-medium">Keys</span>
            </button>
            <button onclick="showScreen('packages')" id="nav-account" class="flex flex-col items-center text-gray-400 focus:outline-none">
                <i class="fa-solid fa-user text-lg"></i>
                <span class="text-[10px] mt-0.5 font-medium">Account</span>
            </button>
        </div>

    </div>

    <script>
        function showScreen(screenId) {
            document.querySelectorAll('.screen').forEach(el => el.classList.add('hidden'));
            const target = document.getElementById('screen-' + screenId);
            if(target) target.classList.remove('hidden');

            document.querySelectorAll('.absolute.bottom-0 button').forEach(el => el.classList.replace('text-blue-600', 'text-gray-400'));
            if(screenId === 'home') document.getElementById('nav-home').classList.replace('text-gray-400', 'text-blue-600');
            if(screenId === 'keys') document.getElementById('nav-keys').classList.replace('text-gray-400', 'text-blue-600');
            if(screenId === 'packages' || screenId === 'topup' || screenId === 'payment' || screenId === 'submitted') document.getElementById('nav-account').classList.replace('text-gray-400', 'text-blue-600');
        }
        function selectPackage(pkgName, pkgPrice) {
            document.getElementById('lbl-pkg').innerText = pkgName;
            document.getElementById('lbl-amt').innerText = pkgPrice;
            showScreen('payment');
        }
        function submitPayment() {
            showScreen('submitted');
        }
    </script>
</body>
</html>
EOF

echo "=== [4/5] Installing NPM packages ==="
npm install

echo "=== [5/5] Configuring Nginx with SSL & Starting App with PM2 ==="
pm2 delete tgmini 2>/dev/null || true
pm2 start server.js --name "tgmini"
pm2 save

systemctl stop nginx
certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

cat > /etc/nginx/sites-available/tgmini <<EOF
server {
    listen ${PORT} ssl;
    server_name ${DOMAIN};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/tgmini /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

systemctl restart nginx
systemctl enable nginx

echo "=== Installation Completed Successfully! ==="
echo "Access your Telegram Mini Web at: https://${DOMAIN}:${PORT}"
