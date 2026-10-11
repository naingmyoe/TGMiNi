<!DOCTYPE html>
<html lang="my">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Outline VPN - Admin Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <!-- FontAwesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
    </style>
</head>
<body class="bg-gray-100 text-gray-800 flex h-screen overflow-hidden">

    <!-- Sidebar Navigation -->
    <aside class="w-64 bg-slate-900 text-white flex flex-col justify-between hidden md:flex">
        <div>
            <div class="p-5 flex items-center space-x-3 border-b border-slate-800">
                <div class="w-9 h-9 bg-blue-600 rounded-xl flex items-center justify-center text-white font-bold">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <h1 class="font-bold text-sm">Outline Admin</h1>
                    <span class="text-[10px] text-slate-400">Management Panel</span>
                </div>
            </div>
            <nav class="p-4 space-y-1.5 text-xs font-medium">
                <a href="#" onclick="switchAdminTab('dashboard')" id="nav-dashboard" class="flex items-center space-x-3 px-4 py-3 rounded-xl bg-blue-600 text-white transition">
                    <i class="fa-solid fa-chart-pie w-4"></i>
                    <span>Dashboard</span>
                </a>
                <a href="#" onclick="switchAdminTab('orders')" id="nav-orders" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-300 hover:bg-slate-800 transition">
                    <i class="fa-solid fa-list-check w-4"></i>
                    <span>Order Approvals</span>
                    <span id="pending-badge" class="ml-auto bg-amber-500 text-white px-2 py-0.5 rounded-full text-[10px]">1</span>
                </a>
                <a href="#" onclick="switchAdminTab('plans')" id="nav-plans" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-300 hover:bg-slate-800 transition">
                    <i class="fa-solid fa-boxes-stacked w-4"></i>
                    <span>Plans Management</span>
                </a>
                <a href="#" onclick="switchAdminTab('servers')" id="nav-servers" class="flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-300 hover:bg-slate-800 transition">
                    <i class="fa-solid fa-server w-4"></i>
                    <span>Server Management</span>
                </a>
            </nav>
        </div>
        <div class="p-4 border-t border-slate-800">
            <div class="flex items-center space-x-3 px-2 py-2">
                <div class="w-8 h-8 bg-slate-700 rounded-full flex items-center justify-center font-bold text-xs">AD</div>
                <div class="overflow-hidden">
                    <p class="text-xs font-bold truncate">Super Admin</p>
                    <p class="text-[10px] text-slate-400 truncate">admin@outline.vpn</p>
                </div>
            </div>
        </div>
    </aside>

    <!-- Main Content Wrapper -->
    <div class="flex-1 flex flex-col overflow-hidden">
        
        <!-- Top Header -->
        <header class="bg-white border-b border-gray-200 h-16 flex items-center justify-between px-6 z-10">
            <div class="flex items-center space-x-3">
                <h2 id="header-title" class="font-bold text-base text-gray-800">Dashboard Overview</h2>
            </div>
            <div class="flex items-center space-x-4">
                <span class="text-xs bg-emerald-50 text-emerald-600 font-semibold px-3 py-1.5 rounded-full border border-emerald-100">
                    <i class="fa-solid fa-circle text-[8px] mr-1"></i> System Online
                </span>
            </div>
        </header>

        <!-- Content Area -->
        <main class="flex-1 overflow-y-auto p-6 bg-gray-50 space-y-6">
            
            <!-- 1. DASHBOARD TAB -->
            <div id="tab-dashboard" class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm space-y-1">
                        <p class="text-xs text-gray-500 font-medium">စုစုပေါင်း ဝင်ငွေ (Total Revenue)</p>
                        <h3 class="text-xl font-extrabold text-gray-900">Ks 150,000</h3>
                        <span class="text-[10px] text-emerald-600 font-semibold"><i class="fa-solid fa-arrow-up"></i> +12% this week</span>
                    </div>
                    <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm space-y-1">
                        <p class="text-xs text-gray-500 font-medium">Pending Orders</p>
                        <h3 class="text-xl font-extrabold text-amber-600">1</h3>
                        <span class="text-[10px] text-amber-600 font-semibold">Action required</span>
                    </div>
                    <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm space-y-1">
                        <p class="text-xs text-gray-500 font-medium">Active Users / Keys</p>
                        <h3 class="text-xl font-extrabold text-blue-600">14</h3>
                        <span class="text-[10px] text-blue-600 font-semibold">All online</span>
                    </div>
                    <div class="bg-white p-5 rounded-2xl border border-gray-200 shadow-sm space-y-1">
                        <p class="text-xs text-gray-500 font-medium">Available Servers</p>
                        <h3 class="text-xl font-extrabold text-purple-600">4</h3>
                        <span class="text-[10px] text-purple-600 font-semibold">Fully operational</span>
                    </div>
                </div>
            </div>

            <!-- 2. ORDER APPROVALS TAB -->
            <div id="tab-orders" class="space-y-4 hidden">
                <div class="flex justify-between items-center">
                    <h3 class="font-bold text-sm text-gray-800">သုံးစွဲသူများ တင်ထားသော ငွေလွှဲ Order များ</h3>
                </div>

                <div class="bg-white border border-gray-200 rounded-2xl shadow-sm overflow-hidden">
                    <table class="w-full text-left text-xs">
                        <thead class="bg-gray-50 border-b border-gray-200 text-gray-500 uppercase font-semibold">
                            <tr>
                                <th class="p-4">Order ID & User</th>
                                <th class="p-4">Plan / Details</th>
                                <th class="p-4">Payment Method</th>
                                <th class="p-4">Screenshot</th>
                                <th class="p-4">Status</th>
                                <th class="p-4 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="admin-orders-table" class="divide-y divide-gray-100">
                            <!-- Dynamic Order Row -->
                            <tr class="hover:bg-gray-50">
                                <td class="p-4">
                                    <p class="font-bold text-gray-900">#REN-98421</p>
                                    <p class="text-[10px] text-gray-400">User ID: 84920192</p>
                                </td>
                                <td class="p-4">
                                    <p class="font-bold text-blue-600">Standard Renewal (100 GB)</p>
                                    <p class="text-[10px] text-gray-500">Ks 10,000 / 30 Days</p>
                                </td>
                                <td class="p-4">
                                    <span class="font-semibold text-gray-700">KBZPay</span>
                                    <p class="text-[10px] text-gray-400">2026-10-11 14:20</p>
                                </td>
                                <td class="p-4">
                                    <button onclick="viewScreenshot('sample_slip.jpg')" class="bg-gray-100 hover:bg-gray-200 text-blue-600 px-3 py-1.5 rounded-lg font-semibold text-[11px]">
                                        <i class="fa-solid fa-image mr-1"></i> ကြည့်မည်
                                    </button>
                                </td>
                                <td class="p-4">
                                    <span class="bg-amber-50 text-amber-600 px-2.5 py-1 rounded-full font-bold text-[10px]">Pending Review</span>
                                </td>
                                <td class="p-4 text-right space-x-1">
                                    <button onclick="approveOrder(this)" class="bg-emerald-600 hover:bg-emerald-700 text-white px-3 py-1.5 rounded-lg font-semibold text-[11px]">Approve</button>
                                    <button onclick="rejectOrder(this)" class="bg-red-50 hover:bg-red-100 text-red-600 px-3 py-1.5 rounded-lg font-semibold text-[11px]">Reject</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 3. PLANS MANAGEMENT TAB -->
            <div id="tab-plans" class="space-y-4 hidden">
                <div class="flex justify-between items-center">
                    <h3 class="font-bold text-sm text-gray-800">VPN Plans စီမံခန့်ခွဲရန်</h3>
                    <button onclick="openPlanModal()" class="bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold px-4 py-2 rounded-xl">
                        <i class="fa-solid fa-plus mr-1"></i> Plan အသစ်ထည့်ရန်
                    </button>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4" id="plans-grid">
                    <!-- Plan Card 1 -->
                    <div class="bg-white border border-gray-200 p-5 rounded-2xl shadow-sm space-y-3">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-bold text-sm text-gray-900">Basic Plan</h4>
                                <p class="text-xs text-gray-500">30 GB / 7 Days</p>
                            </div>
                            <span class="font-extrabold text-blue-600 text-sm">Ks 5,000</span>
                        </div>
                        <div class="flex justify-end space-x-2 pt-2 border-t border-gray-100">
                            <button onclick="editPlan(this)" class="text-gray-600 hover:text-blue-600 text-xs font-semibold px-2.5 py-1 bg-gray-50 rounded-lg">ပြင်ရန်</button>
                            <button onclick="deleteItem(this)" class="text-red-600 hover:text-red-700 text-xs font-semibold px-2.5 py-1 bg-red-50 rounded-lg">ဖျက်ရန်</button>
                        </div>
                    </div>
                    <!-- Plan Card 2 -->
                    <div class="bg-white border border-gray-200 p-5 rounded-2xl shadow-sm space-y-3">
                        <div class="flex justify-between items-start">
                            <div>
                                <h4 class="font-bold text-sm text-gray-900">Standard Plan</h4>
                                <p class="text-xs text-gray-500">100 GB / 30 Days</p>
                            </div>
                            <span class="font-extrabold text-blue-600 text-sm">Ks 10,000</span>
                        </div>
                        <div class="flex justify-end space-x-2 pt-2 border-t border-gray-100">
                            <button onclick="editPlan(this)" class="text-gray-600 hover:text-blue-600 text-xs font-semibold px-2.5 py-1 bg-gray-50 rounded-lg">ပြင်ရန်</button>
                            <button onclick="deleteItem(this)" class="text-red-600 hover:text-red-700 text-xs font-semibold px-2.5 py-1 bg-red-50 rounded-lg">ဖျက်ရန်</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 4. SERVER MANAGEMENT TAB -->
            <div id="tab-servers" class="space-y-4 hidden">
                <div class="flex justify-between items-center">
                    <h3 class="font-bold text-sm text-gray-800">ဆာဗာများ စီမံခန့်ခွဲရန်</h3>
                    <button onclick="openServerModal()" class="bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold px-4 py-2 rounded-xl">
                        <i class="fa-solid fa-plus mr-1"></i> ဆာဗာအသစ်ထည့်ရန်
                    </button>
                </div>

                <div class="bg-white border border-gray-200 rounded-2xl shadow-sm overflow-hidden">
                    <table class="w-full text-left text-xs">
                        <thead class="bg-gray-50 border-b border-gray-200 text-gray-500 uppercase font-semibold">
                            <tr>
                                <th class="p-4">Flag & Name</th>
                                <th class="p-4">Location / Speed</th>
                                <th class="p-4">Status</th>
                                <th class="p-4 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="servers-table-body" class="divide-y divide-gray-100">
                            <tr>
                                <td class="p-4 flex items-center space-x-3">
                                    <span class="text-2xl">🇸🇬</span>
                                    <span class="font-bold text-gray-900">Singapore (SG 01)</span>
                                </td>
                                <td class="p-4 text-gray-500">32 ms • High Speed</td>
                                <td class="p-4"><span class="bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded-full font-bold text-[10px]">Active</span></td>
                                <td class="p-4 text-right space-x-1">
                                    <button onclick="editServer(this)" class="text-gray-600 hover:text-blue-600 px-2.5 py-1 bg-gray-50 rounded-lg font-semibold">ပြင်ရန်</button>
                                    <button onclick="deleteItem(this)" class="text-red-600 hover:text-red-700 px-2.5 py-1 bg-red-50 rounded-lg font-semibold">ဖျက်ရန်</button>
                                </td>
                            </tr>
                            <tr>
                                <td class="p-4 flex items-center space-x-3">
                                    <span class="text-2xl">🇯🇵</span>
                                    <span class="font-bold text-gray-900">Japan (Tokyo)</span>
                                </td>
                                <td class="p-4 text-gray-500">45 ms • Gaming</td>
                                <td class="p-4"><span class="bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded-full font-bold text-[10px]">Active</span></td>
                                <td class="p-4 text-right space-x-1">
                                    <button onclick="editServer(this)" class="text-gray-600 hover:text-blue-600 px-2.5 py-1 bg-gray-50 rounded-lg font-semibold">ပြင်ရန်</button>
                                    <button onclick="deleteItem(this)" class="text-red-600 hover:text-red-700 px-2.5 py-1 bg-red-50 rounded-lg font-semibold">ဖျက်ရန်</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>

    <!-- JavaScript Logic -->
    <script>
        function switchAdminTab(tabName) {
            ['dashboard', 'orders', 'plans', 'servers'].forEach(t => {
                document.getElementById('tab-' + t).classList.add('hidden');
                document.getElementById('nav-' + t).className = "flex items-center space-x-3 px-4 py-3 rounded-xl text-slate-300 hover:bg-slate-800 transition";
            });

            document.getElementById('tab-' + tabName).classList.remove('hidden');
            document.getElementById('nav-' + tabName).className = "flex items-center space-x-3 px-4 py-3 rounded-xl bg-blue-600 text-white transition";

            const titles = {
                'dashboard': 'Dashboard Overview',
                'orders': 'Order Approvals & Payments',
                'plans': 'Plans Management',
                'servers': 'Server Management'
            };
            document.getElementById('header-title').innerText = titles[tabName];
        }

        function approveOrder(button) {
            const row = button.closest('tr');
            const statusCell = row.cells[4];
            statusCell.innerHTML = `<span class="bg-emerald-50 text-emerald-600 px-2.5 py-1 rounded-full font-bold text-[10px]">Approved</span>`;
            row.cells[5].innerHTML = `<span class="text-emerald-600 font-semibold text-xs">Completed</span>`;
            alert('Order အောင်မြင်စွာ Approved ဖြစ်သွားပြီး User ထံသို့ Key အလိုအလျောက် သက်တမ်းတိုးပေးလိုက်ပါပြီ။');
        }

        function rejectOrder(button) {
            const row = button.closest('tr');
            const statusCell = row.cells[4];
            statusCell.innerHTML = `<span class="bg-red-50 text-red-600 px-2.5 py-1 rounded-full font-bold text-[10px]">Rejected</span>`;
            row.cells[5].innerHTML = `<span class="text-red-600 font-semibold text-xs">Cancelled</span>`;
            alert('Order ငြင်းပယ်လိုက်ပါပြီ။');
        }

        function viewScreenshot(filename) {
            alert('ငွေလွှဲ Screenshot ပုံကို ဤနေရာတွင် ဖော်ပြပေးပါမည်။');
        }

        function deleteItem(button) {
            if (confirm('ဤအချက်အလက်ကို ဖျက်ရန် သေချာပါသလား?')) {
                button.closest('.bg-white, tr').remove();
                alert('အောင်မြင်စွာ ဖျက်ပြီးပါပြီ။');
            }
        }

        function openPlanModal() {
            const planName = prompt('Plan အမည် (ဥပမာ - Pro Plan):');
            const planPrice = prompt('ဈေးနှုန်း (ဥပမာ - 15000):');
            const planDetails = prompt('ပမာဏ/ရက် (ဥပမာ - 200 GB / 30 Days):');
            if(planName && planPrice) {
                alert('Plan အသစ် ထည့်သွင်းပြီးပါပြီ။');
            }
        }

        function openServerModal() {
            const sName = prompt('ဆာဗာအမည် (ဥပမာ - Germany SG 02):');
            const sSpeed = prompt('Speed / Ping (ဥပမာ - 120 ms):');
            if(sName) {
                alert('ဆာဗာအသစ် ထည့်သွင်းပြီးပါပြီ။');
            }
        }

        function editPlan(btn) {
            alert('Plan အချက်အလက်များကို ပြင်ဆင်ရန် modal သို့မဟုတ် prompt ဖွင့်ပါမည်။');
        }

        function editServer(btn) {
            alert('ဆာဗာအချက်အလက်များကို ပြင်ဆင်ရန် ဖွင့်ပါမည်။');
        }
    </script>
</body>
</html>
