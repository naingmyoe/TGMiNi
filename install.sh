#!/bin/bash

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

echo "=== [3/5] Setting up App Directory and Full Files ==="
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

# Create server.js
cat << 'EOF' > server.js
const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname)));

app.listen(PORT, '127.0.0.1', () => {
    console.log(`Telegram Mini App running on internal port ${PORT}`);
});
EOF

# Create full index.html with all screens matching UI design
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
                <!-- Banner -->
                <div class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white p-5 rounded-2xl shadow-lg relative overflow-hidden">
                    <div class="relative z-10">
                        <h2 class="text-xl font-extrabold">VPN Pro</h2>
                        <p class="text-xs text-blue-100 mt-1">Fast • Secure • Global</p>
                        <p class="text-sm font-medium mt-3">Get your VPN key easily via Telegram</p>
                    </div>
                    <div class="absolute right-0 bottom-0 opacity-10 text-8xl mr-[-20px] mb-[-20px]">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                </div>

                <!-- Wallet Balance Card -->
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
                    <button onclick="showScreen('topup')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-full shadow hover:bg-blue-600 transition">
                        + Top Up
                    </button>
                </div>

                <!-- Menu List -->
                <div class="space-y-2">
                    <div onclick="showScreen('packages')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-bolt"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Buy VPN Key</h4>
                                <p class="text-xs text-gray-500">Choose a plan and get your key</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div onclick="showScreen('keys')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-key"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">My Keys</h4>
                                <p class="text-xs text-gray-500">View your purchased keys</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div onclick="showScreen('topup')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-wallet"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Top Up</h4>
                                <p class="text-xs text-gray-500">Add balance to your wallet</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div onclick="window.open('https://t.me/your_support', '_blank')" class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-brands fa-telegram"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Telegram Support</h4>
                                <p class="text-xs text-gray-500">Chat with our support team</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>

                    <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                        <div class="flex items-center space-x-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-phone"></i></div>
                            <div>
                                <h4 class="text-sm font-semibold text-gray-800">Call Support</h4>
                                <p class="text-xs text-gray-500">+95 9 123 456 789</p>
                            </div>
                        </div>
                        <i class="fa-solid fa-chevron-right text-gray-400 text-sm"></i>
                    </div>
                </div>

                <div class="text-center pt-2">
                    <p class="text-xs text-gray-400"><i class="fa-solid fa-shield-check text-blue-500"></i> Stay Connected Anytime, Anywhere</p>
                </div>
            </div>

            <!-- SCREEN 2: VPN PACKAGES -->
            <div id="screen-packages" class="screen hidden space-y-3">
                <div class="mb-2">
                    <h2 class="text-lg font-bold text-gray-800">VPN Packages</h2>
                    <p class="text-xs text-gray-500">Choose the best plan for your needs</p>
                </div>

                <!-- Package 1 -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-shield-halved"></i></div>
                        <div>
                            <h4 class="text-sm font-bold text-gray-800">1 Day</h4>
                            <p class="text-xs text-gray-400">24 hours</p>
                            <p class="text-sm font-extrabold text-blue-600 mt-1">2,000 Ks</p>
                        </div>
                    </div>
                    <button onclick="selectPackage('1 Day', '2,000 Ks')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-lg shadow">Buy Now</button>
                </div>

                <!-- Package 2 -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-shield-halved"></i></div>
                        <div>
                            <h4 class="text-sm font-bold text-gray-800">3 Days</h4>
                            <p class="text-xs text-gray-400">72 hours</p>
                            <p class="text-sm font-extrabold text-blue-600 mt-1">5,000 Ks</p>
                        </div>
                    </div>
                    <button onclick="selectPackage('3 Days', '5,000 Ks')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-lg shadow">Buy Now</button>
                </div>

                <!-- Package 3 (Popular) -->
                <div class="bg-white p-4 rounded-xl shadow-sm border-2 border-blue-500 relative flex items-center justify-between">
                    <span class="absolute -top-2.5 right-4 bg-blue-600 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">Popular</span>
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

                <!-- Package 4 -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-shield-halved"></i></div>
                        <div>
                            <h4 class="text-sm font-bold text-gray-800">30 Days</h4>
                            <p class="text-xs text-gray-400">1 month</p>
                            <p class="text-sm font-extrabold text-blue-600 mt-1">25,000 Ks</p>
                        </div>
                    </div>
                    <button onclick="selectPackage('30 Days', '25,000 Ks')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-lg shadow">Buy Now</button>
                </div>
            </div>

            <!-- SCREEN 3: DIRECT PAYMENT -->
            <div id="screen-payment" class="screen hidden space-y-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-800">Direct Payment</h2>
                    <p class="text-xs text-gray-500">Please make a payment and upload your screenshot for verification.</p>
                </div>

                <div class="bg-blue-50 border border-blue-100 p-3 rounded-xl text-xs text-blue-800 space-y-1">
                    <p class="font-semibold"><i class="fa-solid fa-circle-info"></i> We accept KBZPay and WavePay.</p>
                    <p>After payment, please send your screenshot and we will verify it manually.</p>
                </div>

                <!-- Payment Method -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-3">
                    <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider">Payment Method</h3>
                    <label class="flex items-center justify-between cursor-pointer border-b pb-2">
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded bg-blue-900 text-white flex items-center justify-center font-bold text-xs">K</div>
                            <span class="text-sm font-semibold text-gray-800">KBZPay</span>
                        </div>
                        <input type="radio" name="paymethod" checked class="text-blue-600 focus:ring-blue-500">
                    </label>
                    <label class="flex items-center justify-between cursor-pointer pt-1">
                        <div class="flex items-center space-x-3">
                            <div class="w-8 h-8 rounded bg-yellow-500 text-white flex items-center justify-center font-bold text-xs">W</div>
                            <span class="text-sm font-semibold text-gray-800">WavePay</span>
                        </div>
                        <input type="radio" name="paymethod" class="text-blue-600 focus:ring-blue-500">
                    </label>
                </div>

                <!-- Recipient Info -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-2 text-xs">
                    <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Recipient Information</h3>
                    <div class="flex justify-between py-1 border-b"><span class="text-gray-500">Name</span><span class="font-semibold text-gray-800">Thu Ya Aung</span></div>
                    <div class="flex justify-between py-1 border-b"><span class="text-gray-500">Phone Number</span><span class="font-semibold text-gray-800">09 777 555 666</span></div>
                    <div class="flex justify-between py-1"><span class="text-gray-500">Account Number</span><span class="font-semibold text-gray-800">KBZPay / WavePay (as shown)</span></div>
                </div>

                <!-- Order Summary -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-2 text-xs">
                    <div class="flex justify-between py-1"><span class="text-gray-500">Order ID</span><span class="font-semibold text-gray-800" id="lbl-orderid">PAY-00125</span></div>
                    <div class="flex justify-between py-1"><span class="text-gray-500">Package</span><span class="font-semibold text-gray-800" id="lbl-pkg">7 Days</span></div>
                    <div class="flex justify-between py-1"><span class="text-gray-500">Amount</span><span class="font-bold text-blue-600 text-sm" id="lbl-amt">10,000 Ks</span></div>
                </div>

                <!-- Screenshot Upload -->
                <div class="border-2 border-dashed border-gray-300 rounded-xl p-6 text-center bg-gray-50 cursor-pointer hover:bg-gray-100 transition">
                    <i class="fa-solid fa-camera text-2xl text-blue-500 mb-2"></i>
                    <p class="text-xs font-semibold text-gray-700">Upload Payment Screenshot</p>
                    <p class="text-[10px] text-gray-400 mt-0.5">Tap to select image</p>
                </div>

                <button onclick="submitPayment()" class="w-full tg-blue text-white py-3 rounded-xl font-bold text-sm shadow-lg hover:bg-blue-600 transition">
                    Submit Payment Proof
                </button>
            </div>

            <!-- SCREEN 4: PAYMENT SUBMITTED -->
            <div id="screen-submitted" class="screen hidden space-y-4 text-center">
                <div class="pt-4 flex flex-col items-center">
                    <div class="w-16 h-16 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-3xl mb-3 shadow-inner">
                        <i class="fa-regular fa-clock"></i>
                    </div>
                    <h2 class="text-lg font-bold text-gray-800">Payment Submitted</h2>
                    <p class="text-xs text-gray-500 mt-1 px-4">Your payment has been sent for review. Please wait for admin approval.</p>
                </div>

                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 text-left text-xs space-y-2">
                    <div class="flex justify-between py-1 border-b"><span class="text-gray-500">Order ID</span><span class="font-semibold text-gray-800">PAY-00125</span></div>
                    <div class="flex justify-between py-1 border-b"><span class="text-gray-500">Amount</span><span class="font-semibold text-gray-800">10,000 Ks</span></div>
                    <div class="flex justify-between py-1 border-b"><span class="text-gray-500">Payment Method</span><span class="font-semibold text-gray-800">KBZPay</span></div>
                    <div class="flex justify-between py-1"><span class="text-gray-500">Submitted At</span><span class="font-semibold text-gray-800">2026-10-07 14:32</span></div>
                </div>

                <!-- Timeline status -->
                <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 text-left space-y-3 text-xs">
                    <div class="flex items-center space-x-3">
                        <div class="w-5 h-5 rounded-full bg-green-500 text-white flex items-center justify-center text-[10px]"><i class="fa-solid fa-check"></i></div>
                        <div>
                            <p class="font-bold text-gray-800">Payment Info Received</p>
                            <p class="text-[10px] text-gray-400">10-07 14:32</p>
                        </div>
                    </div>
                    <div class="flex items-center space-x-3">
                        <div class="w-5 h-5 rounded-full bg-blue-500 text-white flex items-center justify-center text-[10px] animate-pulse"><i class="fa-solid fa-spinner"></i></div>
                        <div>
                            <p class="font-bold text-blue-600">Waiting for Admin Review</p>
                            <p class="text-[10px] text-gray-400">In progress...</p>
                        </div>
                    </div>
                </div>

                <div class="bg-gray-50 p-4 rounded-xl border border-gray-100 flex items-center justify-between">
                    <div class="flex items-center space-x-3 text-left">
                        <i class="fa-brands fa-telegram text-2xl text-blue-500"></i>
                        <div>
                            <h4 class="text-xs font-bold text-gray-800">Need help?</h4>
                            <p class="text-[10px] text-gray-500">Contact admin on Telegram</p>
                        </div>
                    </div>
                    <button onclick="window.open('https://t.me/your_support', '_blank')" class="tg-blue text-white text-xs font-semibold px-4 py-2 rounded-lg">Open Telegram</button>
                </div>
            </div>

            <!-- SCREEN 5: MY KEYS -->
            <div id="screen-keys" class="screen hidden space-y-4">
                <div>
                    <h2 class="text-lg font-bold text-gray-800">My VPN Keys</h2>
                    <p class="text-xs text-gray-500">Manage your VPN keys and renew when needed.</p>
                </div>

                <!-- Tabs -->
                <div class="flex bg-gray-200 p-1 rounded-xl text-xs font-semibold">
                    <button onclick="switchKeyTab('active')" id="tab-active" class="flex-1 py-2 bg-white text-blue-600 rounded-lg shadow-sm transition">Active (1)</button>
                    <button onclick="switchKeyTab('expired')" id="tab-expired" class="flex-1 py-2 text-gray-600 transition">Expired (1)</button>
                </div>

                <!-- Active Key List -->
                <div id="list-active" class="space-y-3">
                    <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-3">
                        <div class="flex items-center justify-between">
                            <span class="bg-green-100 text-green-700 text-[10px] font-bold px-2.5 py-1 rounded-full"><i class="fa-solid fa-circle text-[6px]"></i> Active</span>
                            <span class="text-xs font-bold text-gray-700">7 Days Plan</span>
                        </div>
                        <div class="flex items-center space-x-3 bg-gray-50 p-3 rounded-lg">
                            <div class="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-network-wired"></i></div>
                            <div>
                                <h4 class="text-xs font-bold text-gray-800">Outline VPN</h4>
                                <p class="text-[10px] text-gray-500">VLESS / 100 Mbps</p>
                            </div>
                        </div>
                        <div>
                            <span class="text-[10px] text-gray-400 font-semibold uppercase">Key</span>
                            <div class="flex items-center justify-between bg-gray-50 border rounded-lg px-3 py-2 text-xs font-mono text-gray-600 mt-0.5">
                                <span class="truncate pr-2">vpn-7d-8F3A98ZC-4kJ2...</span>
                                <button onclick="copyKey()" class="text-blue-600 hover:text-blue-800"><i class="fa-regular fa-copy"></i></button>
                            </div>
                        </div>
                        <div class="flex items-center justify-between text-xs pt-1">
                            <span class="text-gray-400">Expiry Date</span>
                            <span class="font-semibold text-gray-800">2026-10-14 14:32</span>
                        </div>
                        <div class="flex space-x-2 pt-2">
                            <button onclick="copyKey()" class="flex-1 border border-blue-500 text-blue-600 py-2 rounded-lg text-xs font-semibold hover:bg-blue-50">Copy Key</button>
                            <button onclick="showScreen('packages')" class="flex-1 tg-blue text-white py-2 rounded-lg text-xs font-semibold hover:bg-blue-600">Renew</button>
                        </div>
                    </div>
                </div>

                <!-- Expired Key List -->
                <div id="list-expired" class="space-y-3 hidden">
                    <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 space-y-3 opacity-80">
                        <div class="flex items-center justify-between">
                            <span class="bg-red-100 text-red-600 text-[10px] font-bold px-2.5 py-1 rounded-full">Expired</span>
                            <span class="text-xs font-bold text-gray-700">3 Days Plan</span>
                        </div>
                        <div class="flex items-center space-x-3 bg-gray-50 p-3 rounded-lg">
                            <div class="w-8 h-8 rounded-lg bg-gray-200 text-gray-600 flex items-center justify-center"><i class="fa-solid fa-network-wired"></i></div>
                            <div>
                                <h4 class="text-xs font-bold text-gray-800">Outline VPN</h4>
                                <p class="text-[10px] text-gray-500">VLESS / 100 Mbps</p>
                            </div>
                        </div>
                        <div class="flex items-center justify-between text-xs pt-1">
                            <span class="text-gray-400">Expired On</span>
                            <span class="font-semibold text-gray-800">2026-09-28 10:15</span>
                        </div>
                        <button onclick="showScreen('packages')" class="w-full tg-blue text-white py-2 rounded-lg text-xs font-semibold hover:bg-blue-600">Renew</button>
                    </div>
                </div>

                <div class="bg-blue-50 p-3 rounded-xl border border-blue-100 text-xs text-blue-900 flex items-center justify-between">
                    <div>
                        <p class="font-bold">Need a longer plan?</p>
                        <p class="text-[10px] text-blue-700">Check out our latest VPN packages and get the best price!</p>
                    </div>
                    <i class="fa-solid fa-shield-halved text-2xl text-blue-400 ml-2"></i>
                </div>
            </div>

        </div>

        <!-- Bottom Navigation Bar -->
        <div class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-200 py-2 px-6 flex justify-around items-center shadow-lg">
            <button onclick="showScreen('home')" id="nav-home" class="flex flex-col items-center text-blue-600 focus:outline-none">
                <i class="fa-solid fa-house text-lg"></i>
                <span class="text-[10px] mt-0.5 font-medium">Home</span>
            </button>
            <button onclick="showScreen('keys')" id="nav-keys" class="flex flex-col items-center text-gray-400 hover:text-blue-600 focus:outline-none">
                <i class="fa-solid fa-key text-lg"></i>
                <span class="text-[10px] mt-0.5 font-medium">Keys</span>
            </button>
            <button onclick="showScreen('packages')" id="nav-account" class="flex flex-col items-center text-gray-400 hover:text-blue-600 focus:outline-none">
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

        function switchKeyTab(tab) {
            if(tab === 'active') {
                document.getElementById('tab-active').className = "flex-1 py-2 bg-white text-blue-600 rounded-lg shadow-sm transition";
                document.getElementById('tab-expired').className = "flex-1 py-2 text-gray-600 transition";
                document.getElementById('list-active').classList.remove('hidden');
                document.getElementById('list-expired').classList.add('hidden');
            } else {
                document.getElementById('tab-expired').className = "flex-1 py-2 bg-white text-blue-600 rounded-lg shadow-sm transition";
                document.getElementById('tab-active').className = "flex-1 py-2 text-gray-600 transition";
                document.getElementById('list-expired').classList.remove('hidden');
                document.getElementById('list-active').classList.add('hidden');
            }
        }

        function copyKey() {
            navigator.clipboard.writeText("vpn-7d-8F3A98ZC-4kJ2");
            alert("VPN Key copied to clipboard!");
        }
    </script>
</body>
</html>
EOF

echo "=== [4/5] Installing NPM packages ==="
npm install

echo "=== [5/5] Configuring Nginx and starting app with PM2 ==="
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
