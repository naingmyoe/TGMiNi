#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# VPN Pro - Telegram Mini Web + Admin Panel
# Port: 8082
# ============================================================

APP_DIR="/var/www/vpn-pro"
NGINX_SITE="/etc/nginx/sites-available/vpn-pro"
PORT="8082"

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run as root:"
    echo "sudo bash install.sh"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "=========================================="
echo " VPN Pro Telegram Mini Web Installer"
echo " Port: ${PORT}"
echo "=========================================="

apt-get update
apt-get install -y nginx

# ------------------------------------------------------------
# Check port 8082 before changing nginx
# ------------------------------------------------------------


mkdir -p "$APP_DIR"

# ============================================================
# index.html
# ============================================================
cat > "$APP_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport"
      content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<meta name="theme-color" content="#087ff5">
<title>VPN Pro - Telegram Mini Web</title>

<script src="https://telegram.org/js/telegram-web-app.js"></script>

<style>
:root{
    --blue:#087ff5;
    --blue2:#0569d8;
    --blue3:#eaf4ff;
    --dark:#11213b;
    --text:#15243b;
    --muted:#77859a;
    --line:#dce7f3;
    --bg:#f4f8fc;
    --white:#ffffff;
    --green:#20b978;
    --red:#ed5a62;
    --yellow:#f4b740;
    --shadow:0 8px 25px rgba(24,75,125,.10);
}

*{
    box-sizing:border-box;
    -webkit-tap-highlight-color:transparent;
}

html,body{
    margin:0;
    padding:0;
    background:var(--bg);
    color:var(--text);
    font-family:
        Arial,
        "Noto Sans Myanmar",
        "Myanmar Text",
        sans-serif;
}

body{
    min-height:100vh;
}

button,
input,
select{
    font:inherit;
}

button{
    cursor:pointer;
}

.hidden{
    display:none!important;
}

/* ============================================================
   MOBILE APP
   ============================================================ */

.mobile-app{
    width:100%;
    max-width:480px;
    min-height:100vh;
    margin:auto;
    background:#f7fbff;
    padding-bottom:78px;
}

.topbar{
    height:66px;
    padding:12px 16px;
    background:#fff;
    display:flex;
    align-items:center;
    justify-content:space-between;
    border-bottom:1px solid #e9f0f7;
    position:sticky;
    top:0;
    z-index:20;
}

.brand{
    display:flex;
    align-items:center;
    gap:9px;
}

.telegram-logo{
    width:39px;
    height:39px;
    border-radius:50%;
    background:#25a8e0;
    display:grid;
    place-items:center;
    color:white;
    font-size:22px;
    box-shadow:0 4px 10px rgba(37,168,224,.25);
}

.brand-title{
    font-size:14px;
    font-weight:800;
    line-height:1.2;
}

.brand-sub{
    font-size:9px;
    color:#7c8999;
    margin-top:3px;
}

.close-btn{
    border:0;
    background:transparent;
    color:#26384e;
    font-size:22px;
    width:35px;
    height:35px;
}

.mobile-content{
    padding:14px 13px 25px;
}

.hero-card{
    background:linear-gradient(145deg,#0b83f5,#0869da);
    border-radius:14px;
    padding:18px;
    color:white;
    box-shadow:0 9px 25px rgba(8,127,245,.22);
    position:relative;
    overflow:hidden;
}

.hero-card:after{
    content:"";
    position:absolute;
    width:160px;
    height:160px;
    border-radius:50%;
    border:22px solid rgba(255,255,255,.08);
    right:-70px;
    top:-70px;
}

.hero-row{
    display:flex;
    align-items:center;
    gap:12px;
}

.shield{
    width:47px;
    height:47px;
    border-radius:50%;
    background:white;
    color:#087ff5;
    display:grid;
    place-items:center;
    font-size:24px;
}

.hero-name{
    font-size:20px;
    font-weight:800;
}

.hero-small{
    font-size:11px;
    opacity:.8;
    margin-top:3px;
}

.wallet{
    margin-top:17px;
    padding:11px 12px;
    background:rgba(255,255,255,.13);
    border-radius:9px;
    display:flex;
    align-items:center;
    justify-content:space-between;
}

.wallet small{
    display:block;
    opacity:.78;
    font-size:10px;
}

.wallet strong{
    display:block;
    margin-top:3px;
    font-size:17px;
}

.wallet button{
    border:0;
    background:white;
    color:#0876e7;
    border-radius:7px;
    padding:7px 12px;
    font-size:10px;
    font-weight:800;
}

.menu-list{
    margin-top:12px;
    background:white;
    border-radius:12px;
    border:1px solid #e2ebf4;
    overflow:hidden;
}

.menu-item{
    width:100%;
    border:0;
    background:white;
    padding:13px 14px;
    display:flex;
    align-items:center;
    gap:11px;
    text-align:left;
    border-bottom:1px solid #edf2f7;
}

.menu-item:last-child{
    border-bottom:0;
}

.menu-icon{
    width:30px;
    height:30px;
    border-radius:8px;
    background:#eaf5ff;
    color:#087ff5;
    display:grid;
    place-items:center;
    flex:none;
}

.menu-title{
    font-size:12px;
    font-weight:700;
    color:#20324a;
    flex:1;
}

.menu-desc{
    display:block;
    font-size:9px;
    font-weight:400;
    color:#8b98a8;
    margin-top:2px;
}

.arrow{
    color:#a4afbc;
    font-size:17px;
}

.section-title{
    font-size:14px;
    font-weight:800;
    margin:18px 2px 10px;
}

.package-list{
    display:flex;
    flex-direction:column;
    gap:9px;
}

.package{
    background:white;
    border:1px solid #dce7f1;
    border-radius:12px;
    padding:13px;
    box-shadow:0 4px 12px rgba(25,80,130,.04);
}

.package-top{
    display:flex;
    align-items:center;
    gap:10px;
}

.package-icon{
    width:36px;
    height:36px;
    border-radius:9px;
    background:#eaf5ff;
    display:grid;
    place-items:center;
    color:#087ff5;
    font-weight:800;
}

.package-info{
    flex:1;
}

.package-name{
    font-size:12px;
    font-weight:800;
}

.package-time{
    color:#8795a6;
    font-size:9px;
    margin-top:3px;
}

.package-price{
    font-weight:800;
    font-size:13px;
}

.buy-btn{
    margin-top:10px;
    width:100%;
    border:0;
    background:#087ff5;
    color:white;
    border-radius:7px;
    padding:9px;
    font-size:10px;
    font-weight:800;
}

.payment-method{
    background:white;
    border:1px solid #dce7f1;
    border-radius:12px;
    padding:13px;
}

.payment-head{
    font-size:12px;
    font-weight:800;
    margin-bottom:10px;
}

.method{
    display:flex;
    align-items:center;
    gap:10px;
    padding:10px;
    border:1px solid #e3ebf3;
    border-radius:9px;
    margin-bottom:7px;
    background:#fff;
}

.method.active{
    border-color:#087ff5;
    background:#f1f8ff;
}

.method-logo{
    width:30px;
    height:30px;
    border-radius:7px;
    display:grid;
    place-items:center;
    background:#edf4fb;
    font-size:12px;
    font-weight:800;
}

.method-name{
    flex:1;
    font-size:11px;
    font-weight:700;
}

.radio{
    width:15px;
    height:15px;
    border:2px solid #b8c6d5;
    border-radius:50%;
}

.method.active .radio{
    border-color:#087ff5;
    box-shadow:inset 0 0 0 3px white;
    background:#087ff5;
}

.info-box{
    background:#f0f7ff;
    border:1px solid #d9ebff;
    border-radius:10px;
    padding:11px;
    font-size:10px;
    color:#66798f;
    line-height:1.7;
    margin:10px 0;
}

.form-card{
    background:white;
    border:1px solid #dce7f1;
    border-radius:12px;
    padding:14px;
}

.form-label{
    display:block;
    font-size:10px;
    color:#728196;
    margin:11px 0 6px;
    font-weight:700;
}

.form-input,
.form-select{
    width:100%;
    border:1px solid #dce6ef;
    background:#fbfdff;
    color:#26374e;
    border-radius:8px;
    padding:11px;
    outline:none;
    font-size:11px;
}

.upload{
    border:1px dashed #b8cbe0;
    background:#f7fbff;
    border-radius:9px;
    padding:17px;
    text-align:center;
    font-size:10px;
    color:#71839a;
}

.upload input{
    display:none;
}

.success-card{
    background:white;
    border:1px solid #dbe9e2;
    border-radius:13px;
    padding:20px 15px;
    text-align:center;
}

.success-icon{
    width:55px;
    height:55px;
    border-radius:50%;
    background:#e2f8ef;
    color:#18ae72;
    display:grid;
    place-items:center;
    margin:0 auto 12px;
    font-size:29px;
}

.key-card{
    background:#f2fbf7;
    border:1px solid #bcebd8;
    border-radius:11px;
    padding:13px;
    text-align:left;
    margin-top:13px;
}

.key-title{
    font-size:11px;
    font-weight:800;
}

.key-value{
    background:white;
    border:1px solid #dce9e4;
    padding:9px;
    border-radius:7px;
    font-size:10px;
    margin-top:7px;
    word-break:break-all;
}

.status-active{
    color:#16aa70;
    background:#e8f9f1;
    padding:4px 7px;
    border-radius:6px;
    font-size:8px;
    font-weight:800;
}

.status-expired{
    color:#e74f59;
    background:#fff0f1;
    padding:4px 7px;
    border-radius:6px;
    font-size:8px;
    font-weight:800;
}

.bottom-nav{
    position:fixed;
    left:50%;
    bottom:0;
    transform:translateX(-50%);
    width:100%;
    max-width:480px;
    height:65px;
    background:rgba(255,255,255,.96);
    border-top:1px solid #e1e9f1;
    display:flex;
    z-index:50;
    padding-bottom:env(safe-area-inset-bottom);
}

.bottom-nav button{
    flex:1;
    border:0;
    background:transparent;
    color:#8290a0;
    font-size:9px;
}

.bottom-nav button.active{
    color:#087ff5;
}

.bottom-icon{
    display:block;
    font-size:19px;
    margin-bottom:3px;
}

/* ============================================================
   DESKTOP ADMIN
   ============================================================ */

.admin-app{
    min-height:100vh;
    background:#f5f8fc;
    display:none;
}

.admin-sidebar{
    position:fixed;
    left:0;
    top:0;
    bottom:0;
    width:215px;
    background:#0c2d55;
    color:white;
    padding:17px 12px;
}

.admin-brand{
    display:flex;
    align-items:center;
    gap:9px;
    padding:8px 9px 22px;
    border-bottom:1px solid rgba(255,255,255,.1);
}

.admin-brand-icon{
    width:36px;
    height:36px;
    border-radius:50%;
    background:#1da5e3;
    display:grid;
    place-items:center;
}

.admin-brand strong{
    font-size:13px;
}

.admin-brand small{
    display:block;
    opacity:.6;
    font-size:8px;
    margin-top:2px;
}

.admin-nav{
    margin-top:17px;
}

.admin-nav button{
    width:100%;
    border:0;
    background:transparent;
    color:#b7c9dd;
    text-align:left;
    padding:10px 11px;
    border-radius:7px;
    margin-bottom:3px;
    font-size:11px;
}

.admin-nav button.active,
.admin-nav button:hover{
    color:white;
    background:#14518e;
}

.admin-main{
    margin-left:215px;
    min-height:100vh;
}

.admin-topbar{
    height:58px;
    background:white;
    border-bottom:1px solid #e3eaf2;
    display:flex;
    align-items:center;
    justify-content:space-between;
    padding:0 22px;
}

.admin-title{
    font-size:14px;
    font-weight:800;
}

.admin-user{
    display:flex;
    align-items:center;
    gap:8px;
    font-size:10px;
}

.admin-avatar{
    width:30px;
    height:30px;
    border-radius:50%;
    background:#e8f2fc;
    display:grid;
    place-items:center;
}

.admin-content{
    padding:20px;
}

.stat-grid{
    display:grid;
    grid-template-columns:repeat(4,1fr);
    gap:12px;
}

.stat-card{
    background:white;
    border:1px solid #e1e9f2;
    border-radius:10px;
    padding:14px;
}

.stat-top{
    display:flex;
    justify-content:space-between;
    align-items:center;
}

.stat-icon{
    width:31px;
    height:31px;
    border-radius:8px;
    background:#eaf5ff;
    color:#087ff5;
    display:grid;
    place-items:center;
}

.stat-label{
    color:#8996a7;
    font-size:9px;
}

.stat-value{
    font-size:17px;
    font-weight:800;
    margin-top:7px;
}

.stat-change{
    color:#20ae76;
    font-size:8px;
    margin-top:5px;
}

.admin-grid{
    display:grid;
    grid-template-columns:1.25fr 1fr;
    gap:13px;
    margin-top:13px;
}

.admin-card{
    background:white;
    border:1px solid #e1e9f2;
    border-radius:10px;
    padding:14px;
}

.admin-card-title{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:13px;
}

.admin-card-title strong{
    font-size:11px;
}

.admin-card-title span{
    color:#087ff5;
    font-size:8px;
}

.chart{
    height:180px;
    display:flex;
    align-items:flex-end;
    gap:10px;
    padding:10px 6px 0;
    border-bottom:1px solid #e7edf4;
}

.bar{
    flex:1;
    background:linear-gradient(#2293fa,#b9dcff);
    border-radius:5px 5px 0 0;
    min-height:20px;
}

.table{
    width:100%;
    border-collapse:collapse;
}

.table th{
    color:#8a97a7;
    font-size:8px;
    text-align:left;
    padding:8px 6px;
    border-bottom:1px solid #e9eef4;
}

.table td{
    font-size:9px;
    padding:9px 6px;
    border-bottom:1px solid #edf1f5;
}

.badge{
    display:inline-block;
    padding:4px 7px;
    border-radius:5px;
    font-size:7px;
    font-weight:800;
}

.badge.green{
    color:#13a76c;
    background:#e5f8f0;
}

.badge.red{
    color:#df515a;
    background:#ffedef;
}

.badge.blue{
    color:#087ff5;
    background:#eaf5ff;
}

.admin-page{
    display:none;
}

.admin-page.active{
    display:block;
}

@media(min-width:900px){
    .mobile-app{
        display:none;
    }

    .admin-app{
        display:block;
    }
}

@media(max-width:899px){
    .admin-app{
        display:none!important;
    }
}
</style>
</head>

<body>

<!-- ==========================================================
     MOBILE TELEGRAM MINI APP
     ========================================================== -->

<div class="mobile-app">

    <header class="topbar">
        <div class="brand">
            <div class="telegram-logo">➤</div>
            <div>
                <div class="brand-title">VPN Pro</div>
                <div class="brand-sub">Telegram Mini Web</div>
            </div>
        </div>

        <button class="close-btn" onclick="tgClose()">×</button>
    </header>

    <!-- HOME -->
    <section id="mobileHome" class="mobile-page">
        <div class="mobile-content">

            <div class="hero-card">

                <div class="hero-row">
                    <div class="shield">🛡</div>
                    <div>
                        <div class="hero-name">VPN Pro</div>
                        <div class="hero-small">
                            Fast · Secure · Global
                        </div>
                    </div>
                </div>

                <div class="wallet">
                    <div>
                        <small>Your Balance</small>
                        <strong id="walletBalance">0 Ks</strong>
                    </div>

                    <button onclick="openMobilePage('wallet')">
                        + Top Up
                    </button>
                </div>

            </div>

            <div class="menu-list">

                <button class="menu-item"
                        onclick="openMobilePage('packages')">
                    <div class="menu-icon">⚡</div>
                    <div class="menu-title">
                        Buy VPN Key
                        <span class="menu-desc">
                            Get secure internet access
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

                <button class="menu-item"
                        onclick="openMobilePage('keys')">
                    <div class="menu-icon">🔑</div>
                    <div class="menu-title">
                        My Keys
                        <span class="menu-desc">
                            View your purchased keys
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

                <button class="menu-item"
                        onclick="openMobilePage('account')">
                    <div class="menu-icon">👤</div>
                    <div class="menu-title">
                        Account
                        <span class="menu-desc">
                            Profile & settings
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

                <button class="menu-item"
                        onclick="supportTelegram()">
                    <div class="menu-icon">?</div>
                    <div class="menu-title">
                        Help
                        <span class="menu-desc">
                            FAQ & support
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

            </div>

            <div class="section-title">
                VPN Packages
            </div>

            <div class="package-list">

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">⚡</div>
                        <div class="package-info">
                            <div class="package-name">
                                1 Day
                            </div>
                            <div class="package-time">
                                24 hours
                            </div>
                        </div>
                        <div class="package-price">
                            2,000 Ks
                        </div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('1 Day',2000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">⚡</div>
                        <div class="package-info">
                            <div class="package-name">
                                3 Days
                            </div>
                            <div class="package-time">
                                72 hours
                            </div>
                        </div>
                        <div class="package-price">
                            5,000 Ks
                        </div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('3 Days',5000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">🛡</div>
                        <div class="package-info">
                            <div class="package-name">
                                7 Days
                            </div>
                            <div class="package-time">
                                1 week
                            </div>
                        </div>
                        <div class="package-price">
                            10,000 Ks
                        </div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('7 Days',10000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">🌐</div>
                        <div class="package-info">
                            <div class="package-name">
                                30 Days
                            </div>
                            <div class="package-time">
                                1 month
                            </div>
                        </div>
                        <div class="package-price">
                            25,000 Ks
                        </div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('30 Days',25000)">
                        Buy Now
                    </button>
                </div>

            </div>

        </div>
    </section>

    <!-- PACKAGES -->
    <section id="mobilePackages" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="section-title">
                Choose your Package
            </div>

            <div class="package-list">

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">⚡</div>
                        <div class="package-info">
                            <div class="package-name">1 Day</div>
                            <div class="package-time">24 hours</div>
                        </div>
                        <div class="package-price">2,000 Ks</div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('1 Day',2000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">⚡</div>
                        <div class="package-info">
                            <div class="package-name">3 Days</div>
                            <div class="package-time">72 hours</div>
                        </div>
                        <div class="package-price">5,000 Ks</div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('3 Days',5000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">🛡</div>
                        <div class="package-info">
                            <div class="package-name">7 Days</div>
                            <div class="package-time">1 week</div>
                        </div>
                        <div class="package-price">10,000 Ks</div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('7 Days',10000)">
                        Buy Now
                    </button>
                </div>

                <div class="package">
                    <div class="package-top">
                        <div class="package-icon">🌐</div>
                        <div class="package-info">
                            <div class="package-name">30 Days</div>
                            <div class="package-time">1 month</div>
                        </div>
                        <div class="package-price">25,000 Ks</div>
                    </div>
                    <button class="buy-btn"
                            onclick="selectPackage('30 Days',25000)">
                        Buy Now
                    </button>
                </div>

            </div>

            <div class="info-box">
                ⚡ High Speed &nbsp;&nbsp;
                🌐 Global Servers &nbsp;&nbsp;
                🛡 No Logs
            </div>

        </div>
    </section>

    <!-- PAYMENT -->
    <section id="mobilePayment" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="section-title">
                Payment
            </div>

            <div class="package">
                <div class="package-top">
                    <div class="package-icon">🛡</div>
                    <div class="package-info">
                        <div class="package-name"
                             id="selectedPackage">
                            7 Days Plan
                        </div>
                        <div class="package-time">
                            VPN Pro
                        </div>
                    </div>
                    <div class="package-price"
                         id="selectedPrice">
                        10,000 Ks
                    </div>
                </div>
            </div>

            <div class="payment-method"
                 style="margin-top:10px">

                <div class="payment-head">
                    Select Payment Method
                </div>

                <div class="method active"
                     onclick="choosePayment(this)">
                    <div class="method-logo">K</div>
                    <div class="method-name">KBZPay</div>
                    <div class="radio"></div>
                </div>

                <div class="method"
                     onclick="choosePayment(this)">
                    <div class="method-logo">W</div>
                    <div class="method-name">WavePay</div>
                    <div class="radio"></div>
                </div>

                <div class="method"
                     onclick="choosePayment(this)">
                    <div class="method-logo">A</div>
                    <div class="method-name">AYA Pay</div>
                    <div class="radio"></div>
                </div>

                <div class="method"
                     onclick="choosePayment(this)">
                    <div class="method-logo">$</div>
                    <div class="method-name">USDT (Crypto)</div>
                    <div class="radio"></div>
                </div>

            </div>

            <div class="form-card"
                 style="margin-top:10px">

                <label class="form-label">
                    Name
                </label>
                <input class="form-input"
                       id="payerName"
                       placeholder="Your Name">

                <label class="form-label">
                    Phone Number
                </label>
                <input class="form-input"
                       id="payerPhone"
                       placeholder="09xxxxxxxxx">

                <label class="form-label">
                    Account Number / Wallet
                </label>
                <input class="form-input"
                       id="payerAccount"
                       placeholder="Payment account">

                <label class="form-label">
                    Transaction ID
                </label>
                <input class="form-input"
                       id="transactionId"
                       placeholder="Transaction ID">

                <label class="form-label">
                    Payment Screenshot
                </label>

                <label class="upload">
                    📷 Upload Payment Screenshot
                    <input type="file"
                           id="paymentScreenshot"
                           accept="image/*">
                    <div id="paymentFileName"
                         style="margin-top:7px">
                        No file selected
                    </div>
                </label>

                <div class="info-box">
                    After payment, upload your screenshot and
                    Transaction ID. Admin will verify the payment
                    and generate your VPN Key.
                </div>

                <button class="buy-btn"
                        onclick="submitPayment()">
                    Submit Payment Proof
                </button>

            </div>

        </div>
    </section>

    <!-- PAYMENT SUCCESS -->
    <section id="mobileSuccess" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="success-card">

                <div class="success-icon">
                    ✓
                </div>

                <h3 style="margin:0 0 6px">
                    Payment Submitted!
                </h3>

                <p style="
                    margin:0;
                    color:#7d8b9b;
                    font-size:10px;
                    line-height:1.7">
                    Your payment has been sent for review.
                    Please wait for admin approval.
                </p>

                <div class="key-card">

                    <div class="key-title">
                        Payment Information
                    </div>

                    <div style="
                        margin-top:8px;
                        display:flex;
                        justify-content:space-between;
                        font-size:9px">
                        <span>Order ID</span>
                        <strong id="orderId">PAY-00125</strong>
                    </div>

                    <div style="
                        margin-top:8px;
                        display:flex;
                        justify-content:space-between;
                        font-size:9px">
                        <span>Package</span>
                        <strong id="successPackage">
                            7 Days
                        </strong>
                    </div>

                    <div style="
                        margin-top:8px;
                        display:flex;
                        justify-content:space-between;
                        font-size:9px">
                        <span>Amount</span>
                        <strong id="successAmount">
                            10,000 Ks
                        </strong>
                    </div>

                </div>

                <button class="buy-btn"
                        style="margin-top:12px"
                        onclick="openMobilePage('keys')">
                    View My Keys
                </button>

            </div>

        </div>
    </section>

    <!-- MY KEYS -->
    <section id="mobileKeys" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="section-title">
                My VPN Keys
            </div>

            <div class="package">

                <div style="
                    display:flex;
                    justify-content:space-between;
                    align-items:center">

                    <span class="status-active">
                        ● Active
                    </span>

                    <span style="
                        color:#7c8999;
                        font-size:8px">
                        7 Days
                    </span>

                </div>

                <div style="
                    font-size:11px;
                    font-weight:800;
                    margin-top:10px">
                    VPN-7D-5F3A9B2C
                </div>

                <div style="
                    font-size:9px;
                    color:#8390a0;
                    margin-top:5px">
                    Valid Until:
                    2026-10-17 14:32
                </div>

                <button class="buy-btn"
                        onclick="copyKey('VPN-7D-5F3A9B2C')">
                    Copy Key
                </button>

            </div>

            <div class="package">

                <div style="
                    display:flex;
                    justify-content:space-between;
                    align-items:center">

                    <span class="status-active">
                        ● Active
                    </span>

                    <span style="
                        color:#7c8999;
                        font-size:8px">
                        3 Days
                    </span>

                </div>

                <div style="
                    font-size:11px;
                    font-weight:800;
                    margin-top:10px">
                    VPN-3D-A18B2C3D
                </div>

                <div style="
                    font-size:9px;
                    color:#8390a0;
                    margin-top:5px">
                    Valid Until:
                    2026-10-13 09:15
                </div>

                <button class="buy-btn"
                        onclick="copyKey('VPN-3D-A18B2C3D')">
                    Copy Key
                </button>

            </div>

            <div class="package">

                <div style="
                    display:flex;
                    justify-content:space-between;
                    align-items:center">

                    <span class="status-expired">
                        ● Expired
                    </span>

                    <span style="
                        color:#7c8999;
                        font-size:8px">
                        1 Day
                    </span>

                </div>

                <div style="
                    font-size:11px;
                    font-weight:800;
                    margin-top:10px">
                    VPN-1D-92K7X8YW
                </div>

                <div style="
                    font-size:9px;
                    color:#8390a0;
                    margin-top:5px">
                    Expired:
                    2026-09-28 18:20
                </div>

                <button class="buy-btn"
                        onclick="selectPackage('1 Day',2000)">
                    Renew
                </button>

            </div>

        </div>
    </section>

    <!-- WALLET -->
    <section id="mobileWallet" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="section-title">
                Top Up Wallet
            </div>

            <div class="hero-card">

                <div class="hero-small">
                    Wallet Balance
                </div>

                <div style="
                    font-size:24px;
                    font-weight:800;
                    margin-top:5px">
                    <span id="walletBalance2">
                        0 Ks
                    </span>
                </div>

            </div>

            <div class="form-card"
                 style="margin-top:10px">

                <label class="form-label">
                    Amount
                </label>

                <input class="form-input"
                       type="number"
                       id="topupAmount"
                       placeholder="10,000">

                <label class="form-label">
                    Payment Method
                </label>

                <select class="form-select"
                        id="topupMethod">
                    <option>KBZPay</option>
                    <option>WavePay</option>
                    <option>AYA Pay</option>
                    <option>USDT</option>
                </select>

                <label class="form-label">
                    Transaction ID
                </label>

                <input class="form-input"
                       id="topupTransaction"
                       placeholder="Transaction ID">

                <label class="form-label">
                    Payment Screenshot
                </label>

                <label class="upload">
                    📷 Upload Screenshot
                    <input type="file"
                           id="topupScreenshot"
                           accept="image/*">
                    <div id="topupFileName"
                         style="margin-top:7px">
                        No file selected
                    </div>
                </label>

                <button class="buy-btn"
                        style="margin-top:10px"
                        onclick="submitTopup()">
                    Submit Top Up
                </button>

            </div>

        </div>
    </section>

    <!-- ACCOUNT -->
    <section id="mobileAccount" class="mobile-page hidden">
        <div class="mobile-content">

            <div class="section-title">
                Account
            </div>

            <div class="form-card">

                <div style="
                    display:flex;
                    align-items:center;
                    gap:12px">

                    <div class="telegram-logo">
                        👤
                    </div>

                    <div>
                        <div style="
                            font-size:13px;
                            font-weight:800">
                            Telegram User
                        </div>

                        <div style="
                            font-size:9px;
                            color:#8492a2;
                            margin-top:3px">
                            Telegram Mini App
                        </div>
                    </div>

                </div>

                <hr style="
                    border:0;
                    border-top:1px solid #edf1f5;
                    margin:15px 0">

                <button class="menu-item"
                        onclick="supportTelegram()">
                    <div class="menu-icon">✈</div>
                    <div class="menu-title">
                        Telegram Support
                        <span class="menu-desc">
                            Chat with our support team
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

                <button class="menu-item"
                        onclick="showToast('Settings will be available soon.')">
                    <div class="menu-icon">⚙</div>
                    <div class="menu-title">
                        Settings
                        <span class="menu-desc">
                            App settings
                        </span>
                    </div>
                    <div class="arrow">›</div>
                </button>

            </div>

        </div>
    </section>

    <!-- MOBILE NAV -->
    <nav class="bottom-nav">

        <button id="navHome"
                class="active"
                onclick="openMobilePage('home')">
            <span class="bottom-icon">⌂</span>
            Home
        </button>

        <button id="navKeys"
                onclick="openMobilePage('keys')">
            <span class="bottom-icon">🔑</span>
            Keys
        </button>

        <button id="navAccount"
                onclick="openMobilePage('account')">
            <span class="bottom-icon">♙</span>
            Account
        </button>

    </nav>

</div>


<!-- ==========================================================
     ADMIN PANEL
     ========================================================== -->

<div class="admin-app">

    <aside class="admin-sidebar">

        <div class="admin-brand">

            <div class="admin-brand-icon">
                ➤
            </div>

            <div>
                <strong>VPN Pro Admin</strong>
                <small>Administration Panel</small>
            </div>

        </div>

        <div class="admin-nav">

            <button class="active"
                    onclick="adminPage('dashboard',this)">
                ▣ &nbsp; Dashboard
            </button>

            <button onclick="adminPage('users',this)">
                ♙ &nbsp; Users
            </button>

            <button onclick="adminPage('keys',this)">
                🔑 &nbsp; VPN Keys
            </button>

            <button onclick="adminPage('packages',this)">
                ▤ &nbsp; Packages
            </button>

            <button onclick="adminPage('transactions',this)">
                ◉ &nbsp; Transactions
            </button>

            <button onclick="adminPage('deposits',this)">
                ⇩ &nbsp; Deposit / Withdraw
            </button>

            <button onclick="adminPage('servers',this)">
                ◈ &nbsp; Servers
            </button>

            <button onclick="adminPage('settings',this)">
                ⚙ &nbsp; Settings
            </button>

            <button onclick="showToast('Logout is ready for backend connection.')">
                ⇥ &nbsp; Log Out
            </button>

        </div>

    </aside>

    <main class="admin-main">

        <header class="admin-topbar">

            <div class="admin-title">
                Admin Panel
            </div>

            <div class="admin-user">

                <div class="admin-avatar">
                    👤
                </div>

                <div>
                    <strong>admin</strong><br>
                    <span style="color:#8a97a7">
                        Administrator
                    </span>
                </div>

            </div>

        </header>

        <div class="admin-content">

            <!-- DASHBOARD -->
            <section id="adminDashboard"
                     class="admin-page active">

                <div class="stat-grid">

                    <div class="stat-card">

                        <div class="stat-top">
                            <span class="stat-label">
                                Total Users
                            </span>
                            <span class="stat-icon">
                                ♙
                            </span>
                        </div>

                        <div class="stat-value">
                            248
                        </div>

                        <div class="stat-change">
                            +12 today
                        </div>

                    </div>

                    <div class="stat-card">

                        <div class="stat-top">
                            <span class="stat-label">
                                Total Sales
                            </span>
                            <span class="stat-icon">
                                ◉
                            </span>
                        </div>

                        <div class="stat-value">
                            1,248,000 Ks
                        </div>

                        <div class="stat-change">
                            +18% this week
                        </div>

                    </div>

                    <div class="stat-card">

                        <div class="stat-top">
                            <span class="stat-label">
                                Active Keys
                            </span>
                            <span class="stat-icon">
                                🔑
                            </span>
                        </div>

                        <div class="stat-value">
                            186
                        </div>

                        <div class="stat-change">
                            +5 today
                        </div>

                    </div>

                    <div class="stat-card">

                        <div class="stat-top">
                            <span class="stat-label">
                                Revenue
                            </span>
                            <span class="stat-icon">
                                💰
                            </span>
                        </div>

                        <div class="stat-value">
                            1,248,000 Ks
                        </div>

                        <div class="stat-change">
                            +18% this week
                        </div>

                    </div>

                </div>

                <div class="admin-grid">

                    <div class="admin-card">

                        <div class="admin-card-title">
                            <strong>
                                Sales Overview (Last 7 Days)
                            </strong>

                            <span>
                                Sales &nbsp; Users
                            </span>
                        </div>

                        <div class="chart">

                            <div class="bar" style="height:55%"></div>
                            <div class="bar" style="height:72%"></div>
                            <div class="bar" style="height:60%"></div>
                            <div class="bar" style="height:82%"></div>
                            <div class="bar" style="height:70%"></div>
                            <div class="bar" style="height:91%"></div>
                            <div class="bar" style="height:77%"></div>

                        </div>

                        <div style="
                            display:flex;
                            justify-content:space-between;
                            color:#8c98a8;
                            font-size:8px;
                            margin-top:7px">
                            <span>Mon</span>
                            <span>Tue</span>
                            <span>Wed</span>
                            <span>Thu</span>
                            <span>Fri</span>
                            <span>Sat</span>
                            <span>Sun</span>
                        </div>

                    </div>

                    <div class="admin-card">

                        <div class="admin-card-title">
                            <strong>
                                Recent Transactions
                            </strong>
                            <span>View All</span>
                        </div>

                        <table class="table">

                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Package</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>

                                <tr>
                                    <td>user123</td>
                                    <td>7 Days</td>
                                    <td>10,000</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>naing99</td>
                                    <td>3 Days</td>
                                    <td>5,000</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>ko123</td>
                                    <td>30 Days</td>
                                    <td>25,000</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>mgthar</td>
                                    <td>1 Day</td>
                                    <td>2,000</td>
                                    <td>
                                        <span class="badge blue">
                                            Review
                                        </span>
                                    </td>
                                </tr>

                            </tbody>

                        </table>

                    </div>

                </div>

                <div class="admin-grid">

                    <div class="admin-card">

                        <div class="admin-card-title">
                            <strong>
                                Latest Users
                            </strong>
                            <span>View All</span>
                        </div>

                        <table class="table">

                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Telegram ID</th>
                                    <th>Package</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>

                                <tr>
                                    <td>user123</td>
                                    <td>945672310</td>
                                    <td>7 Days</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>naing99</td>
                                    <td>945672311</td>
                                    <td>3 Days</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>ko123</td>
                                    <td>945672312</td>
                                    <td>30 Days</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>mgthar</td>
                                    <td>945672313</td>
                                    <td>1 Day</td>
                                    <td>
                                        <span class="badge red">
                                            Expired
                                        </span>
                                    </td>
                                </tr>

                            </tbody>

                        </table>

                    </div>

                    <div class="admin-card">

                        <div class="admin-card-title">
                            <strong>
                                VPN Keys Management
                            </strong>
                            <span>View All</span>
                        </div>

                        <table class="table">

                            <thead>
                                <tr>
                                    <th>VPN Key</th>
                                    <th>Package</th>
                                    <th>User</th>
                                    <th>Status</th>
                                </tr>
                            </thead>

                            <tbody>

                                <tr>
                                    <td>VPN-7D-5F3A</td>
                                    <td>7 Days</td>
                                    <td>user123</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>VPN-3D-A18B</td>
                                    <td>3 Days</td>
                                    <td>naing99</td>
                                    <td>
                                        <span class="badge green">
                                            Active
                                        </span>
                                    </td>
                                </tr>

                                <tr>
                                    <td>VPN-1D-92K7</td>
                                    <td>1 Day</td>
                                    <td>mgthar</td>
                                    <td>
                                        <span class="badge red">
                                            Expired
                                        </span>
                                    </td>
                                </tr>

                            </tbody>

                        </table>

                    </div>

                </div>

            </section>


            <!-- USERS -->
            <section id="adminUsers"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>Users</strong>
                        <button class="buy-btn"
                                style="width:auto;padding:7px 13px">
                            + Add User
                        </button>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Telegram ID</th>
                                <th>Package</th>
                                <th>Joined</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>
                            <tr>
                                <td>user123</td>
                                <td>945672310</td>
                                <td>7 Days</td>
                                <td>2026-10-07</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>naing99</td>
                                <td>945672311</td>
                                <td>30 Days</td>
                                <td>2026-10-05</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>mgthar</td>
                                <td>945672313</td>
                                <td>1 Day</td>
                                <td>2026-09-28</td>
                                <td>
                                    <span class="badge red">
                                        Expired
                                    </span>
                                </td>
                            </tr>
                        </tbody>

                    </table>

                </div>

            </section>


            <!-- KEYS -->
            <section id="adminKeys"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>VPN Keys Management</strong>
                        <button class="buy-btn"
                                style="width:auto;padding:7px 13px">
                            + Generate Key
                        </button>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>VPN Key</th>
                                <th>User</th>
                                <th>Package</th>
                                <th>Expire</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                            <tr>
                                <td>VPN-7D-5F3A9B2C</td>
                                <td>user123</td>
                                <td>7 Days</td>
                                <td>2026-10-17</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>VPN-3D-A18B2C3D</td>
                                <td>naing99</td>
                                <td>3 Days</td>
                                <td>2026-10-13</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- PACKAGES -->
            <section id="adminPackages"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>VPN Packages</strong>
                        <button class="buy-btn"
                                style="width:auto;padding:7px 13px">
                            + Add Package
                        </button>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>Package</th>
                                <th>Duration</th>
                                <th>Price</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                            <tr>
                                <td>1 Day</td>
                                <td>24 Hours</td>
                                <td>2,000 Ks</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>3 Days</td>
                                <td>72 Hours</td>
                                <td>5,000 Ks</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>7 Days</td>
                                <td>1 Week</td>
                                <td>10,000 Ks</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>30 Days</td>
                                <td>1 Month</td>
                                <td>25,000 Ks</td>
                                <td>
                                    <span class="badge green">
                                        Active
                                    </span>
                                </td>
                            </tr>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- TRANSACTIONS -->
            <section id="adminTransactions"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>Transactions</strong>
                        <span>Payment History</span>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>User</th>
                                <th>Package</th>
                                <th>Amount</th>
                                <th>Method</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                            <tr>
                                <td>PAY-00125</td>
                                <td>user123</td>
                                <td>7 Days</td>
                                <td>10,000 Ks</td>
                                <td>KBZPay</td>
                                <td>
                                    <span class="badge green">
                                        Approved
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>PAY-00124</td>
                                <td>naing99</td>
                                <td>30 Days</td>
                                <td>25,000 Ks</td>
                                <td>WavePay</td>
                                <td>
                                    <span class="badge blue">
                                        Review
                                    </span>
                                </td>
                            </tr>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- DEPOSITS -->
            <section id="adminDeposits"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>
                            Deposit / Withdraw
                        </strong>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Type</th>
                                <th>Amount</th>
                                <th>Method</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                            <tr>
                                <td>user123</td>
                                <td>Deposit</td>
                                <td>20,000 Ks</td>
                                <td>KBZPay</td>
                                <td>
                                    <span class="badge green">
                                        Approved
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>naing99</td>
                                <td>Deposit</td>
                                <td>10,000 Ks</td>
                                <td>WavePay</td>
                                <td>
                                    <span class="badge blue">
                                        Review
                                    </span>
                                </td>
                            </tr>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- SERVERS -->
            <section id="adminServers"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>VPN Servers</strong>
                        <button class="buy-btn"
                                style="width:auto;padding:7px 13px">
                            + Add Server
                        </button>
                    </div>

                    <table class="table">

                        <thead>
                            <tr>
                                <th>Server</th>
                                <th>Location</th>
                                <th>Users</th>
                                <th>Load</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                            <tr>
                                <td>TH-01</td>
                                <td>Thailand</td>
                                <td>86</td>
                                <td>38%</td>
                                <td>
                                    <span class="badge green">
                                        Online
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>SG-01</td>
                                <td>Singapore</td>
                                <td>64</td>
                                <td>42%</td>
                                <td>
                                    <span class="badge green">
                                        Online
                                    </span>
                                </td>
                            </tr>

                            <tr>
                                <td>JP-01</td>
                                <td>Japan</td>
                                <td>36</td>
                                <td>29%</td>
                                <td>
                                    <span class="badge green">
                                        Online
                                    </span>
                                </td>
                            </tr>

                        </tbody>

                    </table>

                </div>

            </section>


            <!-- SETTINGS -->
            <section id="adminSettings"
                     class="admin-page">

                <div class="admin-card">

                    <div class="admin-card-title">
                        <strong>Settings</strong>
                    </div>

                    <label class="form-label">
                        Telegram Bot Username
                    </label>

                    <input class="form-input"
                           value="@VPNProBot">

                    <label class="form-label">
                        Telegram Support
                    </label>

                    <input class="form-input"
                           value="@VPNProSupport">

                    <label class="form-label">
                        Default Currency
                    </label>

                    <select class="form-select">
                        <option>MMK - Myanmar Kyat</option>
                        <option>USD - US Dollar</option>
                    </select>

                    <button class="buy-btn"
                            style="margin-top:15px">
                        Save Settings
                    </button>

                </div>

            </section>

        </div>

    </main>

</div>


<!-- ==========================================================
     JAVASCRIPT
     ========================================================== -->

<script>

const tg = window.Telegram && window.Telegram.WebApp
    ? window.Telegram.WebApp
    : null;

if(tg){
    tg.ready();
    tg.expand();

    try{
        tg.setHeaderColor("#087ff5");
        tg.setBackgroundColor("#f7fbff");
    }catch(e){}
}

let selectedPackage = "7 Days";
let selectedPrice = 10000;

function tgClose(){

    if(tg && tg.close){
        tg.close();
    }
}

function openMobilePage(page){

    const pages = {
        home:"mobileHome",
        packages:"mobilePackages",
        payment:"mobilePayment",
        success:"mobileSuccess",
        keys:"mobileKeys",
        wallet:"mobileWallet",
        account:"mobileAccount"
    };

    document.querySelectorAll(".mobile-page")
        .forEach(function(el){
            el.classList.add("hidden");
        });

    const target = document.getElementById(pages[page]);

    if(target){
        target.classList.remove("hidden");
    }

    document.querySelectorAll(".bottom-nav button")
        .forEach(function(btn){
            btn.classList.remove("active");
        });

    if(page === "home"){
        document.getElementById("navHome").classList.add("active");
    }

    if(page === "keys"){
        document.getElementById("navKeys").classList.add("active");
    }

    if(page === "account"){
        document.getElementById("navAccount").classList.add("active");
    }

    window.scrollTo({
        top:0,
        behavior:"smooth"
    });
}

function selectPackage(name,price){

    selectedPackage = name;
    selectedPrice = price;

    document.getElementById("selectedPackage")
        .textContent = name + " Plan";

    document.getElementById("selectedPrice")
        .textContent = price.toLocaleString() + " Ks";

    document.getElementById("successPackage")
        .textContent = name;

    document.getElementById("successAmount")
        .textContent = price.toLocaleString() + " Ks";

    openMobilePage("payment");
}

function choosePayment(element){

    document.querySelectorAll(".method")
        .forEach(function(el){
            el.classList.remove("active");
        });

    element.classList.add("active");
}

function submitPayment(){

    const phone =
        document.getElementById("payerPhone").value.trim();

    const transaction =
        document.getElementById("transactionId").value.trim();

    const screenshot =
        document.getElementById("paymentScreenshot").files.length;

    if(!phone){
        showToast("Phone Number ထည့်ပါ။");
        return;
    }

    if(!transaction){
        showToast("Transaction ID ထည့်ပါ။");
        return;
    }

    if(!screenshot){
        showToast("Payment Screenshot တင်ပါ။");
        return;
    }

    document.getElementById("orderId").textContent =
        "PAY-" + Math.floor(10000 + Math.random()*89999);

    openMobilePage("success");
}

function submitTopup(){

    const amount =
        Number(document.getElementById("topupAmount").value);

    const transaction =
        document.getElementById("topupTransaction").value.trim();

    const screenshot =
        document.getElementById("topupScreenshot").files.length;

    if(!amount || amount < 1000){
        showToast("အနည်းဆုံး 1,000 Ks ထည့်ပါ။");
        return;
    }

    if(!transaction){
        showToast("Transaction ID ထည့်ပါ။");
        return;
    }

    if(!screenshot){
        showToast("Payment Screenshot တင်ပါ။");
        return;
    }

    showToast(
        "Top Up request submitted. Admin approval pending."
    );
}

function copyKey(key){

    if(navigator.clipboard){

        navigator.clipboard.writeText(key)
            .then(function(){
                showToast("VPN Key copied.");
            })
            .catch(function(){
                showToast(key);
            });

    }else{
        showToast(key);
    }
}

function supportTelegram(){

    const username = "VPNProSupport";

    if(tg && tg.openTelegramLink){
        tg.openTelegramLink(
            "https://t.me/" + username
        );
    }else{
        window.open(
            "https://t.me/" + username,
            "_blank"
        );
    }
}

function showToast(message){

    let toast = document.getElementById("globalToast");

    if(!toast){

        toast = document.createElement("div");

        toast.id = "globalToast";

        toast.style.position = "fixed";
        toast.style.left = "15px";
        toast.style.right = "15px";
        toast.style.bottom = "80px";
        toast.style.zIndex = "9999";
        toast.style.padding = "13px";
        toast.style.background = "#14243c";
        toast.style.color = "#fff";
        toast.style.borderRadius = "10px";
        toast.style.fontSize = "11px";
        toast.style.textAlign = "center";
        toast.style.boxShadow =
            "0 8px 25px rgba(0,0,0,.18)";

        document.body.appendChild(toast);
    }

    toast.textContent = message;
    toast.style.display = "block";

    clearTimeout(window.__toastTimer);

    window.__toastTimer =
        setTimeout(function(){
            toast.style.display = "none";
        },3000);
}

function adminPage(page,button){

    document.querySelectorAll(".admin-page")
        .forEach(function(el){
            el.classList.remove("active");
        });

    document.querySelectorAll(".admin-nav button")
        .forEach(function(el){
            el.classList.remove("active");
        });

    const target =
        document.getElementById("admin" +
            page.charAt(0).toUpperCase() +
            page.slice(1));

    if(target){
        target.classList.add("active");
    }

    if(button){
        button.classList.add("active");
    }
}

document.getElementById("paymentScreenshot")
    .addEventListener("change",function(){

        const name =
            this.files[0]
                ? this.files[0].name
                : "No file selected";

        document.getElementById("paymentFileName")
            .textContent = name;
    });

document.getElementById("topupScreenshot")
    .addEventListener("change",function(){

        const name =
            this.files[0]
                ? this.files[0].name
                : "No file selected";

        document.getElementById("topupFileName")
            .textContent = name;
    });

</script>

</body>
</html>
HTML


# ============================================================
# NGINX CONFIG - PORT 8082
# ============================================================

cat > "$NGINX_SITE" <<NGINX
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

    location ~* \.(css|js|png|jpg|jpeg|gif|svg|ico|webp)$ {
        expires 7d;
        add_header Cache-Control "public";
        try_files \$uri =404;
    }

    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

}
NGINX


# ============================================================
# PERMISSIONS
# ============================================================

chown -R www-data:www-data "$APP_DIR"

find "$APP_DIR" -type d \
    -exec chmod 755 {} \;

find "$APP_DIR" -type f \
    -exec chmod 644 {} \;


# ============================================================
# ENABLE NGINX SITE
# ============================================================

ln -sfn \
    "$NGINX_SITE" \
    "/etc/nginx/sites-enabled/vpn-pro"


# Remove default site if it exists
rm -f /etc/nginx/sites-enabled/default


# ============================================================
# NGINX TEST
# ============================================================

echo
echo "Testing Nginx configuration..."

if ! nginx -t; then
    echo
    echo "ERROR: Nginx configuration test failed."
    exit 1
fi


# ============================================================
# START NGINX
# ============================================================

systemctl enable nginx
systemctl restart nginx


# ============================================================
# FIREWALL
# ============================================================

if command -v ufw >/dev/null 2>&1; then

    if ufw status 2>/dev/null |
        grep -q "Status: active"; then

        ufw allow "${PORT}/tcp"

    fi

fi


# ============================================================
# SERVER IP
# ============================================================

SERVER_IP="$(
    hostname -I |
    awk '{print $1}'
)"


# ============================================================
# FINISH
# ============================================================

echo
echo "=============================================="
echo " VPN PRO MINI WEB INSTALLED SUCCESSFULLY"
echo "=============================================="
echo
echo "UI Directory : ${APP_DIR}"
echo "Nginx Port   : ${PORT}"
echo
echo "Open:"
echo "http://${SERVER_IP}:${PORT}"
echo
echo "Mobile UI:"
echo "VPN Pro"
echo "Home"
echo "Buy VPN Key"
echo "My Keys"
echo "Account"
echo "Top Up"
echo "Payment"
echo "Payment Submitted"
echo
echo "Desktop:"
echo "VPN Pro Admin Panel"
echo "Dashboard"
echo "Users"
echo "VPN Keys"
echo "Packages"
echo "Transactions"
echo "Deposit / Withdraw"
echo "Servers"
echo "Settings"
echo
echo "=============================================="
echo "NOTE:"
echo "This version contains the UI."
echo "Payment approval, wallet processing,"
echo "VPN key generation and server management"
echo "require the backend/API connection."
echo "=============================================="
