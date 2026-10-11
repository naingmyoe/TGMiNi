#!/bin/bash

DOMAIN="tgmini.ownvpnnaing.store"
NGINX_PORT="8084"
NODE_PORT="3001"
APP_DIR="/var/www/telegram-vpn"

echo "====================================================="
echo "  Outline VPN Telegram Mini App - Automated Installer"
echo "====================================================="

read -p "Telegram Bot Token ကို ထည့်ပါ: " BOT_TOKEN
read -p "Admin Telegram Chat ID ကို ထည့်ပါ: " ADMIN_CHAT_ID

if [ -z "$BOT_TOKEN" ] \vert{}\vert{} [ -z "$ADMIN_CHAT_ID" ]; then
    echo "Error: Bot Token နှင့် Admin Chat ID သည် မဖြစ်မနေ ထည့်ရန် လိုအပ်ပါသည်။"
    exit 1
fi

echo "=== 1. System Update & Required Packages ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl nginx certbot python3-certbot-nginx git ufw

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

echo "=== 6. Creating Backend server.js ==="
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

echo "=== 7. Creating .env file ==="
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
        </div>
        <div class="flex-1 overflow-y-auto p-4 flex items-center justify-center">
            <div class="text-center space-y-2">
                <h2 class="font-bold text-lg text-blue-600">Outline VPN Mini App</h2>
                <p class="text-xs text-gray-500">ဆာဗာချိတ်ဆက်မှု အောင်မြင်ပါသည်။</p>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "=== 9. Configuring SSL & Nginx ==="
sudo systemctl stop nginx
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

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

echo "=== 10. Starting PM2 ==="
sudo pm2 start server.js --name "telegram-vpn"
sudo pm2 startup
sudo pm2 save

echo "====================================================="
echo "  Installation Completed Successfully!"
echo "  URL: https://$DOMAIN:$NGINX_PORT"
echo "====================================================="
