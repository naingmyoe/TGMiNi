#!/bin/bash

# Configuration Variablesssss
DOMAIN="tgmini.ownvpnnaing.store"
NGINX_PORT="8084"
NODE_PORT="3001"
APP_DIR="/var/www/telegram-vpn"

echo "====================================================="
echo "  Outline VPN Telegram Mini App - Automated Installer"
echo "====================================================="

# Interactive Prompts for Telegram Config
read -p "Telegram Bot Token ကို ထည့်ပါ: " BOT_TOKEN
read -p "Admin Telegram Chat ID ကို ထည့်ပါ: " ADMIN_CHAT_ID

if [ -z "$BOT_TOKEN" ] || [ -z "$ADMIN_CHAT_ID" ]; then
    echo "Error: Bot Token နှင့် Admin Chat ID သည် မဖြစ်မနေ ထည့်ရန် လိုအပ်ပါသည်။"
    exit 1
fi

echo "=== 1. System Update & Required Packages Installation ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl nginx certbot python3-certbot-nginx git ufw

# Open Ports on Firewall
sudo ufw allow 8084/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

echo "=== 2. Installing Node.js & PM2 ==="
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

echo "=== 3. Setting up Project Directory ==="
sudo mkdir -p $APP_DIR/public
sudo mkdir -p $APP_DIR/uploads
cd $APP_DIR

echo "=== 4. Creating package.json ==="
cat << 'EOF' > package.json
{
  "name": "telegram-vpn-mini-app",
  "version": "1.0.0",
  "description": "Outline VPN Telegram Mini App with Bot Approval",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "multer": "^1.4.5-lts.1",
    "telegraf": "^4.16.3"
  }
}
EOF

echo "=== 5. Installing Node Modules ==="
sudo npm install

echo "=== 6. Creating Backend server.js (Port $NODE_PORT) ==="
cat << EOF > server.js
const express = require('express');
const { Telegraf } = require('telegraf');
const multer = require('multer');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const upload = multer({ dest: 'uploads/' });

const BOT_TOKEN = process.env.BOT_TOKEN;
const ADMIN_CHAT_ID = process.env.ADMIN_CHAT_ID;
const bot = new Telegraf(BOT_TOKEN);

app.post('/api/order', upload.single('screenshot'), async (req, res) => {
    try {
        const { plan, price, method, userId, userName } = req.body;
        const file = req.file;
        const orderId = '#ORD-' + Math.floor(10000 + Math.random() * 90000);

        if (file) {
            await bot.telegram.sendPhoto(ADMIN_CHAT_ID, { source: file.path }, {
                caption: \`🛒 *Order အသစ်ရောက်ရှိပါပြီ!*\n\n\` +
                         \`📌 Order ID: \\\`\${orderId}\\\`\n\` +
                         \`👤 User: \${userName || 'Telegram User'} (ID: \\\`\${userId || 'N/A'}\\\`)\n\` +
                         \`📦 Plan: \${plan}\n\` +
                         \`💰 ကျသင့်ငွေ: \${price} Ks (\${method})\n\n\` +
                         \`ကျေးဇူးပြု၍ စစ်ဆေးပြီး အတည်ပြုပေးပါ။\`,
                parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [
                            { text: '✅ Approve', callback_data: \`approve_\${orderId}\` },
                            { text: '❌ Reject', callback_data: \`reject_\${orderId}\` }
                        ]
                    ]
                }
            });
        }

        res.json({ success: true, orderId: orderId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, error: error.message });
    }
});

bot.action(/approve_(.+)/, async (ctx) => {
    const orderId = ctx.match[1];
    await ctx.editMessageCaption(
        ctx.update.callback_query.message.caption + \`\n\n*Status: ✅ Approved by Admin*\`,
        { parse_mode: 'Markdown' }
    );
    await ctx.reply(\`Order \${orderId} ကို အောင်မြင်စွာ အတည်ပြုပြီးပါပြီ။\`);
});

bot.action(/reject_(.+)/, async (ctx) => {
    const orderId = ctx.match[1];
    await ctx.editMessageCaption(
        ctx.update.callback_query.message.caption + \`\n\n*Status: ❌ Rejected by Admin*\`,
        { parse_mode: 'Markdown' }
    );
    await ctx.reply(\`Order \${orderId} ကို ငြင်းပယ်လိုက်ပါပြီ။\`);
});

bot.launch().catch(err => console.log("Bot launch error:", err));

const PORT = process.env.PORT || $NODE_PORT;
app.listen(PORT, () => {
    console.log(\`Server running on port \${PORT}\`);
});
EOF

echo "=== 7. Creating .env configuration file ==="
cat << EOF > .env
PORT=$NODE_PORT
BOT_TOKEN=$BOT_TOKEN
ADMIN_CHAT_ID=$ADMIN_CHAT_ID
EOF

echo "=== 8. Creating public/index.html ==="
cat << 'EOF' > public/index.html
<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Outline VPN Mini App</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }</style>
</head>
<body class="bg-gray-50 text-gray-800 flex justify-center items-center min-h-screen">
    <div class="w-full max-w-md bg-white min-h-screen flex flex-col justify-between shadow-2xl relative overflow-hidden pb-16">
        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-white sticky top-0 z-50">
            <div class="flex items-center space-x-2">
                <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white">
                    <i class="fa-solid fa-paper-plane text-sm"></i>
                </div>
                <div>
                    <h1 class="font-bold text-sm leading-tight">Telegram</h1>
                    <span class="text-xs text-gray-400">Mini App</span>
                </div>
            </div>
            <div class="flex items-center space-x-4 text-gray-600">
                <i class="fa-solid fa-ellipsis-vertical cursor-pointer"></i>
                <i class="fa-solid fa-xmark cursor-pointer text-lg"></i>
            </div>
        </div>

        <div id="content-area" class="flex-1 overflow-y-auto p-4">
            <div id="view-home" class="space-y-4">
                <div class="bg-gradient-to-r from-blue-600 to-indigo-900 text-white p-5 rounded-2xl shadow-lg relative overflow-hidden">
                    <div class="absolute right-3 top-3 opacity-20 text-7xl"><i class="fa-solid fa-shield-halved"></i></div>
                    <h2 class="text-xl font-bold mb-1">Outline VPN</h2>
                    <p class="text-xs text-blue-100 mb-4">Fast • Secure • Global</p>
                    <div class="bg-white/10 backdrop-blur-md p-3 rounded-xl border border-white/20">
                        <p class="text-xs leading-relaxed">သင်၏ Telegram အကောင့်ဖြင့် Active Key (၁) ခုကို အလွယ်တကူ စီမံခန့်ခွဲပါ။</p>
                    </div>
                </div>

                <div class="space-y-3">
                    <div class="flex justify-between items-center">
                        <h3 class="font-bold text-sm">သင့်၏ Active Key</h3>
                        <span class="text-xs text-blue-600 font-semibold cursor-pointer" onclick="switchTab('orders')">မှာယူမှု မှတ်တမ်း &gt;</span>
                    </div>

                    <div class="bg-white border-2 border-blue-500 rounded-2xl p-4 shadow-sm space-y-3">
                        <div class="flex justify-between items-start">
                            <div class="flex items-center space-x-2">
                                <div class="w-8 h-8 bg-blue-50 rounded-lg flex items-center justify-center text-blue-600">
                                    <i class="fa-solid fa-key text-sm"></i>
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold" id="key-plan-title">Standard Plan (100 GB)</h4>
                                    <p class="text-[10px] text-gray-500 font-mono" id="current-key-string">ssconfig://Y2lwZXI6cGFzc3dvcmRA...#OutlineVPN</p>
                                </div>
                            </div>
                            <span class="bg-emerald-50 text-emerald-600 text-[10px] font-semibold px-2 py-0.5 rounded-full">Active</span>
                        </div>

                        <div class="flex justify-between items-center bg-gray-50 p-2.5 rounded-xl border border-gray-100 text-xs">
                            <span class="text-gray-500 flex items-center"><i class="fa-solid fa-location-dot text-blue-500 mr-1.5"></i> လက်ရှိဆာဗာ:</span>
                            <span id="active-server-name" class="font-bold text-blue-700">🇸🇬 Singapore (Default)</span>
                        </div>

                        <div class="space-y-1">
                            <div class="flex justify-between text-[10px] text-gray-600 font-medium">
                                <span id="usage-text">သုံးစွဲပြီး: 35.5 GB / 100 GB</span>
                                <span class="text-blue-600" id="remaining-text">64.5 GB ကျန်ရှိ</span>
                            </div>
                            <div class="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
                                <div id="usage-progress-bar" class="bg-blue-600 h-full w-[35.5%]"></div>
                            </div>
                            <div class="flex justify-between text-[10px] text-gray-400 pt-0.5">
                                <span id="expiry-date-text">သက်တမ်းကုန်ဆုံးရန်: 2026-11-10</span>
                                <span class="text-emerald-600 font-medium" id="days-left-text">24 days left</span>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-2 pt-1">
                            <a id="add-to-outline-btn" href="ssconfig://Y2lwZXI6cGFzc3dvcmRA...#OutlineVPN" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 rounded-xl text-xs transition flex items-center justify-center space-x-1.5 text-center">
                                <i class="fa-solid fa-arrow-up-right-from-square"></i>
                                <span>Add to Outline</span>
                            </a>
                            <button onclick="copyKeyText()" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold py-2.5 rounded-xl text-xs transition flex items-center justify-center space-x-1.5">
                                <i class="fa-solid fa-copy text-blue-600"></i>
                                <span>Copy Key</span>
                            </button>
                        </div>

                        <div class="grid grid-cols-2 gap-2 pt-2 border-t border-gray-100">
                            <button onclick="switchTab('server')" class="bg-gray-50 hover:bg-gray-100 text-gray-700 font-semibold py-2 rounded-xl text-xs transition flex items-center justify-center space-x-1.5 border border-gray-200">
                                <i class="fa-solid fa-server text-blue-600"></i>
                                <span>ဆာဗာပြောင်းရန်</span>
                            </button>
                            <button onclick="switchTab('plans')" class="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 rounded-xl text-xs transition flex items-center justify-center space-x-1.5">
                                <i class="fa-solid fa-rotate-right"></i>
                                <span>သက်တမ်းတိုးရန်</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div id="view-plans" class="space-y-4 hidden">
                <div class="flex items-center space-x-2">
                    <button onclick="switchTab('home')" class="text-gray-600 text-xs font-semibold"><i class="fa-solid fa-arrow-left mr-1"></i> နောက်သို့</button>
                    <h3 class="font-bold text-sm text-gray-800">သက်တမ်းတိုးရန် (Renew Plan)</h3>
                </div>

                <div class="bg-blue-50 border border-blue-100 p-3 rounded-xl text-xs text-blue-800">
                    <i class="fa-solid fa-circle-info mr-1"></i> အကောင့်တွင် Key တစ်ခုသာရှိသဖြင့် Plan ဝယ်ယူခြင်းသည် လက်ရှိ Key ကို သက်တမ်းတိုးခြင်း ဖြစ်ပါသည်။
                </div>

                <div class="bg-white border border-gray-200 rounded-2xl p-4 shadow-sm space-y-3">
                    <div class="flex justify-between items-center">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center"><i class="fa-solid fa-shield"></i></div>
                            <div>
                                <h4 class="text-xs font-bold">Basic Renewal (30 GB)</h4>
                                <p class="text-sm font-extrabold text-gray-900 mt-0.5">Ks 5,000 <span class="text-xs font-normal text-gray-500">/ 7 Days</span></p>
                            </div>
                        </div>
                    </div>
                    <button onclick="openCheckout('Basic Renewal (30 GB)', '5,000', '30 GB / 7 Days')" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl text-xs font-semibold mt-2">ဒီ Plan ဖြင့် သက်တမ်းတိုးမည်</button>
                </div>

                <div class="bg-white border-2 border-blue-600 rounded-2xl p-4 shadow-sm space-y-3">
                    <div class="flex justify-between items-center">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center"><i class="fa-solid fa-gem"></i></div>
                            <div>
                                <h4 class="text-xs font-bold">Standard Renewal (100 GB)</h4>
                                <p class="text-sm font-extrabold text-gray-900 mt-0.5">Ks 10,000 <span class="text-xs font-normal text-gray-500">/ 30 Days</span></p>
                            </div>
                        </div>
                    </div>
                    <button onclick="openCheckout('Standard Renewal (100 GB)', '10,000', '100 GB / 30 Days')" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl text-xs font-semibold mt-2">ဒီ Plan ဖြင့် သက်တမ်းတိုးမည်</button>
                </div>

                <div class="bg-white border border-gray-200 rounded-2xl p-4 shadow-sm space-y-3">
                    <div class="flex justify-between items-center">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-amber-50 text-amber-500 rounded-lg flex items-center justify-center"><i class="fa-solid fa-crown"></i></div>
                            <div>
                                <h4 class="text-xs font-bold">Premium Renewal (Unlimited)</h4>
                                <p class="text-sm font-extrabold text-gray-900 mt-0.5">Ks 18,000 <span class="text-xs font-normal text-gray-500">/ 30 Days</span></p>
                            </div>
                        </div>
                    </div>
                    <button onclick="openCheckout('Premium Renewal (Unlimited)', '18,000', 'Unlimited GB / 30 Days')" class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-xl text-xs font-semibold mt-2">ဒီ Plan ဖြင့် သက်တမ်းတိုးမည်</button>
                </div>
            </div>

            <div id="view-server" class="space-y-3 hidden">
                <div class="flex items-center space-x-2">
                    <button onclick="switchTab('home')" class="text-gray-600 text-xs font-semibold"><i class="fa-solid fa-arrow-left mr-1"></i> နောက်သို့</button>
                    <h3 class="font-bold text-sm text-gray-800">ဆာဗာပြောင်းလဲရန် (Auto-Switch)</h3>
                </div>

                <div class="bg-amber-50 border border-amber-200 p-3 rounded-xl text-[11px] text-amber-800">
                    <i class="fa-solid fa-bolt mr-1"></i> ဆာဗာပြောင်းလဲသည့်အခါ သင်၏ <b>ssconfig://</b> ကီးစာသား မပြောင်းလဲဘဲ Auto ချိတ်ဆက်ပေးပါမည်။
                </div>

                <div class="space-y-2">
                    <div onclick="changeActiveServer('Singapore (SG 01)')" class="bg-white border border-gray-200 p-3.5 rounded-xl flex items-center justify-between shadow-sm cursor-pointer hover:border-blue-500 transition">
                        <div class="flex items-center space-x-3">
                            <span class="text-xl">🇸🇬</span>
                            <div>
                                <h4 class="text-xs font-bold">Singapore (SG 01)</h4>
                                <p class="text-[10px] text-gray-400">32 ms • High Speed</p>
                            </div>
                        </div>
                        <span class="text-xs bg-blue-50 text-blue-600 font-semibold px-3 py-1 rounded-lg">ပြောင်းမည်</span>
                    </div>

                    <div onclick="changeActiveServer('Japan (JP 01)')" class="bg-white border border-gray-200 p-3.5 rounded-xl flex items-center justify-between shadow-sm cursor-pointer hover:border-blue-500 transition">
                        <div class="flex items-center space-x-3">
                            <span class="text-xl">🇯🇵</span>
                            <div>
                                <h4 class="text-xs font-bold">Japan (Tokyo)</h4>
                                <p class="text-[10px] text-gray-400">45 ms • Gaming</p>
                            </div>
                        </div>
                        <span class="text-xs bg-blue-50 text-blue-600 font-semibold px-3 py-1 rounded-lg">ပြောင်းမည်</span>
                    </div>

                    <div onclick="changeActiveServer('USA (US 01)')" class="bg-white border border-gray-200 p-3.5 rounded-xl flex items-center justify-between shadow-sm cursor-pointer hover:border-blue-500 transition">
                        <div class="flex items-center space-x-3">
                            <span class="text-xl">🇺🇸</span>
                            <div>
                                <h4 class="text-xs font-bold">USA (New York)</h4>
                                <p class="text-[10px] text-gray-400">120 ms • Global</p>
                            </div>
                        </div>
                        <span class="text-xs bg-blue-50 text-blue-600 font-semibold px-3 py-1 rounded-lg">ပြောင်းမည်</span>
                    </div>
                </div>
            </div>

            <div id="view-checkout" class="space-y-4 hidden">
                <div class="flex items-center space-x-2">
                    <button onclick="switchTab('plans')" class="text-gray-600 text-xs font-semibold"><i class="fa-solid fa-arrow-left mr-1"></i> နောက်သို့</button>
                    <h3 class="font-bold text-sm text-gray-800">ငွေပေးချေမှုအတည်ပြုရန်</h3>
                </div>

                <div class="bg-gray-50 border border-gray-200 p-4 rounded-2xl space-y-2">
                    <div class="flex justify-between text-xs">
                        <span class="text-gray-500">ရွေးချယ်ထားသော Plan:</span>
                        <span id="chk-plan-name" class="font-bold text-gray-800">-</span>
                    </div>
                    <div class="flex justify-between text-xs">
                        <span class="text-gray-500">ပမာဏ:</span>
                        <span id="chk-plan-gb" class="font-medium text-blue-600">-</span>
                    </div>
                    <div class="flex justify-between text-xs pt-2 border-t border-gray-200">
                        <span class="text-gray-500 font-bold">ကျသင့်ငွေ:</span>
                        <span id="chk-plan-price" class="font-extrabold text-blue-600 text-sm">-</span>
                    </div>
                </div>

                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-700">ငွေပေးချေမည့် နည်းလမ်း</label>
                    <div class="grid grid-cols-3 gap-2">
                        <div onclick="selectPayment('KBZPay')" id="pay-kbz" class="border-2 border-blue-600 bg-blue-50 p-3 rounded-xl text-center cursor-pointer">
                            <p class="text-xs font-bold text-blue-900">KBZPay</p>
                            <span class="text-[9px] text-gray-500">09-123456789</span>
                        </div>
                        <div onclick="selectPayment('WavePay')" id="pay-wave" class="border border-gray-200 p-3 rounded-xl text-center cursor-pointer">
                            <p class="text-xs font-bold text-gray-700">WavePay</p>
                            <span class="text-[9px] text-gray-500">09-987654321</span>
                        </div>
                        <div onclick="selectPayment('AYA Pay')" id="pay-aya" class="border border-gray-200 p-3 rounded-xl text-center cursor-pointer">
                            <p class="text-xs font-bold text-gray-700">AYA Pay</p>
                            <span class="text-[9px] text-gray-500">09-555666777</span>
                        </div>
                    </div>
                </div>

                <div class="space-y-2">
                    <label class="text-xs font-bold text-gray-700">ငွေလွှဲ Screenshot တင်ရန် <span class="text-red-500">*</span></label>
                    <div class="border-2 border-dashed border-gray-300 rounded-2xl p-4 text-center cursor-pointer hover:bg-gray-50 transition relative">
                        <input type="file" id="screenshot-file" accept="image/*" class="absolute inset-0 opacity-0 cursor-pointer" onchange="previewImage(event)">
                        <div id="upload-placeholder" class="space-y-1">
                            <i class="fa-solid fa-cloud-arrow-up text-blue-500 text-2xl"></i>
                            <p class="text-xs font-medium text-gray-600">ပုံတင်ရန် နှိပ်ပါ</p>
                        </div>
                        <div id="upload-success" class="hidden text-xs text-emerald-600 font-semibold flex items-center justify-center space-x-1">
                            <i class="fa-solid fa-circle-check"></i>
                            <span id="file-name-display">တင်ပြီးပါပြီ</span>
                        </div>
                    </div>
                </div>

                <button onclick="submitPaymentRequest()" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-xl shadow-md text-sm transition">
                    ငွေလွှဲပြီးကြောင်း အတည်ပြုရန် ပေးပို့မည်
                </button>
            </div>

            <div id="view-orders" class="space-y-4 hidden">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-2">
                        <button onclick="switchTab('home')" class="text-gray-600 text-xs font-semibold"><i class="fa-solid fa-arrow-left mr-1"></i> နောက်သို့</button>
                        <h3 class="font-bold text-sm text-gray-800">သက်တမ်းတိုးမှု မှတ်တမ်း</h3>
                    </div>
                </div>

                <div id="orders-list-container" class="space-y-3">
                    <div class="text-center text-xs text-gray-400 py-8">မှာယူမှု မှတ်တမ်းများ မရှိသေးပါ။</div>
                </div>
            </div>

            <div id="view-pending" class="space-y-5 text-center py-8 hidden">
                <div class="w-16 h-16 bg-amber-100 text-amber-600 rounded-full flex items-center justify-center mx-auto text-2xl animate-pulse">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
                <div class="space-y-2">
                    <h3 class="font-bold text-base text-gray-800">Admin အတည်ပြုချက်ကို စောင့်ဆိုင်းနေပါသည်</h3>
                    <p class="text-xs text-gray-500 leading-relaxed px-4">
                        သင်၏ငွေလွှဲစခရင်ရှ็อตကို အောင်မြင်စွာ ပေးပို့ပြီးပါပြီ။ Admin မှ Bot ဖြင့် အတည်ပြုသည်နှင့် သင့် Key သက်တမ်း တိုးမြှင့်သွားပါမည်။
                    </p>
                </div>
                
                <div class="space-y-2 pt-2">
                    <button onclick="switchTab('orders')" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 rounded-xl text-xs">
                        မှာယူမှုအခြေအနေ သို့သွားမည်
                    </button>
                    <button onclick="switchTab('home')" class="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold py-2.5 rounded-xl text-xs">
                        ပင်မစာမျက်နှာသို့ ပြန်ရန်
                    </button>
                </div>
            </div>

            <div id="view-profile" class="space-y-4 hidden">
                <h3 class="font-bold text-sm">Profile</h3>
                <div class="bg-white border border-gray-100 p-4 rounded-2xl flex items-center space-x-3 shadow-sm">
                    <div class="w-12 h-12 bg-blue-500 text-white rounded-full flex items-center justify-center font-bold text-lg" id="user-avatar-initial">U</div>
                    <div>
                        <h4 class="text-sm font-bold" id="user-profile-name">Telegram User</h4>
                        <p class="text-xs text-gray-500" id="user-profile-id">ID: -</p>
                        <span class="text-[10px] bg-emerald-50 text-emerald-600 font-semibold px-2 py-0.5 rounded-full inline-block mt-1">Single Key Account</span>
                    </div>
                </div>

                <div class="bg-white border border-gray-100 rounded-2xl overflow-hidden shadow-sm divide-y divide-gray-100 text-xs">
                    <div onclick="switchTab('orders')" class="p-3.5 flex justify-between items-center cursor-pointer hover:bg-gray-50">
                        <span class="flex items-center text-blue-600 font-bold"><i class="fa-solid fa-box-archive mr-3 w-4"></i> သက်တမ်းတိုး မှတ်တမ်း (History)</span>
                        <i class="fa-solid fa-chevron-right text-gray-300 text-[10px]"></i>
                    </div>
                </div>
            </div>
        </div>

        <div id="bottom-nav" class="absolute bottom-0 left-0 right-0 bg-white border-t border-gray-100 flex justify-around py-2.5 text-gray-400 text-[10px] z-50">
            <button onclick="switchTab('home')" id="nav-home" class="flex flex-col items-center text-blue-600"><i class="fa-solid fa-house text-base mb-0.5"></i><span>Home</span></button>
            <button onclick="switchTab('plans')" id="nav-plans" class="flex flex-col items-center hover:text-blue-600"><i class="fa-solid fa-rotate-right text-base mb-0.5"></i><span>Renew</span></button>
            <button onclick="switchTab('server')" id="nav-server" class="flex flex-col items-center hover:text-blue-600"><i class="fa-solid fa-server text-base mb-0.5"></i><span>Server</span></button>
            <button onclick="switchTab('profile')" id="nav-profile" class="flex flex-col items-center hover:text-blue-600"><i class="fa-solid fa-user text-base mb-0.5"></i><span>Profile</span></button>
        </div>
    </div>

    <script>
        let currentSelectedPlan = { name: '', price: '', gbLimit: '' };
        let selectedPaymentMethod = 'KBZPay';
        let isScreenshotUploaded = false;
        let userKeyString = "ssconfig://Y2lwZXI6cGFzc3dvcmRA...#OutlineVPN";
        let userOrders = [];

        window.addEventListener('DOMContentLoaded', (event) => {
            if (window.Telegram && window.Telegram.WebApp) {
                const tg = window.Telegram.WebApp;
                tg.expand();
                const user = tg.initDataUnsafe?.user;
                if (user) {
                    document.getElementById('user-profile-name').innerText = user.first_name + (user.last_name ? ' ' + user.last_name : '');
                    document.getElementById('user-profile-id').innerText = 'ID: ' + user.id;
                    document.getElementById('user-avatar-initial').innerText = user.first_name.charAt(0).toUpperCase();
                }
            }
        });

        function switchTab(tabName) {
            ['home', 'plans', 'server', 'checkout', 'pending', 'orders', 'profile'].forEach(t => {
                const el = document.getElementById('view-' + t);
                if(el) el.classList.add('hidden');
            });
            document.getElementById('bottom-nav').classList.remove('hidden');

            ['home', 'plans', 'server', 'profile'].forEach(t => {
                const el = document.getElementById('nav-' + t);
                if(el) el.className = "flex flex-col items-center text-gray-400 hover:text-blue-600";
            });

            const targetView = document.getElementById('view-' + tabName);
            if(targetView) targetView.classList.remove('hidden');

            const activeNav = document.getElementById('nav-' + tabName);
            if(activeNav) activeNav.className = "flex flex-col items-center text-blue-600";

            if (tabName === 'orders') {
                renderOrdersList();
            }
        }

        function copyKeyText() {
            navigator.clipboard.writeText(userKeyString).then(() => {
                alert('Key စာသား ကူးယူပြီးပါပြီ။');
            });
        }

        function openCheckout(planName, price, gbLimit) {
            currentSelectedPlan = { name: planName, price: price, gbLimit: gbLimit };
            document.getElementById('chk-plan-name').innerText = planName;
            document.getElementById('chk-plan-price').innerText = 'Ks ' + price;
            document.getElementById('chk-plan-gb').innerText = gbLimit;

            document.getElementById('upload-placeholder').classList.remove('hidden');
            document.getElementById('upload-success').classList.add('hidden');
            document.getElementById('screenshot-file').value = '';
            isScreenshotUploaded = false;

            ['home', 'plans', 'server', 'orders', 'pending', 'profile'].forEach(t => {
                document.getElementById('view-' + t).classList.add('hidden');
            });
            document.getElementById('view-checkout').classList.remove('hidden');
            document.getElementById('bottom-nav').classList.add('hidden');
        }

        function selectPayment(method) {
            selectedPaymentMethod = method;
            ['kbz', 'wave', 'aya'].forEach(m => {
                const el = document.getElementById('pay-' + m);
                el.className = "border border-gray-200 p-3 rounded-xl text-center cursor-pointer";
                el.querySelector('p').className = "text-xs font-bold text-gray-700";
            });
            const selected = document.getElementById('pay-' + method.toLowerCase().replace(' pay', ''));
            selected.className = "border-2 border-blue-600 bg-blue-50 p-3 rounded-xl text-center cursor-pointer";
            selected.querySelector('p').className = "text-xs font-bold text-blue-900";
        }

        function previewImage(event) {
            const file = event.target.files[0];
            if (file) {
                isScreenshotUploaded = true;
                document.getElementById('upload-placeholder').classList.add('hidden');
                document.getElementById('upload-success').classList.remove('hidden');
                document.getElementById('file-name-display').innerText = file.name + ' တင်ပြီးပါပြီ';
            }
        }

        async function submitPaymentRequest() {
            if (!isScreenshotUploaded) {
                alert('ကျေးဇူးပြု၍ ငွေလွှဲ Screenshot ပုံတင်ပေးပါရန်');
                return;
            }

            const formData = new FormData();
            formData.append('plan', currentSelectedPlan.name);
            formData.append('price', currentSelectedPlan.price);
            formData.append('method', selectedPaymentMethod);
            formData.append('screenshot', document.getElementById('screenshot-file').files[0]);

            let userId = 'N/A';
            let userName = 'Telegram User';
            if (window.Telegram && window.Telegram.WebApp) {
                const user = window.Telegram.WebApp.initDataUnsafe?.user;
                if (user) {
                    userId = user.id;
                    userName = user.first_name + (user.last_name ? ' ' + user.last_name : '');
                }
            }
            formData.append('userId', userId);
            formData.append('userName', userName);

            try {
                const response = await fetch('/api/order', {
                    method: 'POST',
                    body: formData
                });
                const result = await response.json();

                if (result.success) {
                    userOrders.unshift({
                        id: result.orderId,
                        plan: currentSelectedPlan.name,
                        price: currentSelectedPlan.price,
                        method: selectedPaymentMethod,
                        status: 'Pending',
                        date: new Date().toISOString().slice(0, 16).replace('T', ' ')
                    });

                    ['home', 'plans', 'server', 'checkout', 'orders', 'profile'].forEach(t => {
                        document.getElementById('view-' + t).classList.add('hidden');
                    });
                    document.getElementById('view-pending').classList.remove('hidden');
                } else {
                    alert('Order တင်ရာတွင် အမှားအယွင်းရှိပါသည်: ' + (result.error || 'Unknown error'));
                }
            } catch (err) {
                console.error(err);
                alert('ဆာဗာသို့ ချိတ်ဆက်၍ မရပါ။');
            }
        }

        function changeActiveServer(serverName) {
            document.getElementById('active-server-name').innerText = serverName;
            alert('ဆာဗာကို ' + serverName + ' သို့ အောင်မြင်စွာ ပြောင်းလဲပြီးပါပြီ။');
            switchTab('home');
        }

        function renderOrdersList() {
            const container = document.getElementById('orders-list-container');
            container.innerHTML = '';

            if (userOrders.length === 0) {
                container.innerHTML = `<div class="text-center text-xs text-gray-400 py-8">မှာယူမှု မှတ်တမ်းများ မရှိသေးပါ။</div>`;
                return;
            }

            userOrders.forEach(order => {
                const cardHTML = `
                    <div class="bg-white border border-gray-200 rounded-2xl p-4 shadow-sm space-y-3">
                        <div class="flex justify-between items-center">
                            <span class="text-xs font-bold text-gray-700">${order.id}</span>
                            <span class="bg-amber-50 text-amber-600 text-[10px] font-bold px-2.5 py-1 rounded-full">Pending Review</span>
                        </div>
                        <div class="text-xs space-y-1 text-gray-600 pt-1 border-t border-gray-100">
                            <div class="flex justify-between"><span>Plan:</span><span class="font-semibold text-gray-800">${order.plan}</span></div>
                            <div class="flex justify-between"><span>ကျသင့်ငွေ:</span><span class="font-semibold text-gray-800">Ks ${order.price}</span></div>
                            <div class="flex justify-between"><span>ငွေပေးချေမှု:</span><span>${order.method}</span></div>
                            <div class="flex justify-between text-[11px] text-gray-400 pt-1"><span>ရက်စွဲ:</span><span>${order.date}</span></div>
                        </div>
                    </div>
                `;
                container.innerHTML += cardHTML;
            });
        }
    </script>
</body>
</html>
EOF

echo "=== 9. Obtaining SSL Certificate via Certbot ==="
sudo systemctl stop nginx
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

echo "=== 10. Configuring Nginx for Port $NGINX_PORT with SSL ==="
sudo bash -c "cat << 'EOF' > /etc/nginx/sites-available/telegram-vpn
server {
    listen $NGINX_PORT ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:$NODE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF"

sudo ln -sf /etc/nginx/sites-available/telegram-vpn /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo "=== 11. Starting Application with PM2 ==="
sudo pm2 start server.js --name "telegram-vpn"
sudo pm2 startup
sudo pm2 save

echo "====================================================="
echo "  Installation Completed Successfully!"
echo "  Your Mini App URL: https://$DOMAIN:$NGINX_PORT"
echo "====================================================="
