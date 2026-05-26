<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\VnpayService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class OrderController extends Controller
{
    public function checkout(Request $request, VnpayService $vnpayService)
    {
        $request->validate([
            'cart' => 'required|array',
            'payment_method' => 'required|string|in:bank_transfer,vnpay_sandbox,vnpay',
            'total' => 'required|numeric',
        ]);

        $user = Auth::user();
        $cart = $request->input('cart', []);
        $paymentMethod = $request->input('payment_method');
        $totalAmount = (float) $request->input('total');
        $isVnpay = in_array($paymentMethod, ['vnpay_sandbox', 'vnpay'], true);

        if (empty($cart)) {
            return response()->json(['message' => 'Giỏ hàng trống'], 400);
        }

        DB::beginTransaction();

        try {
            $orderId = DB::table('orders')->insertGetId([
                'user_id' => $user->id,
                'total_amount' => $totalAmount,
                'payment_method' => $paymentMethod,
                'status' => $isVnpay ? 'pending' : 'completed',
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            foreach ($cart as $item) {
                $orderItemData = [
                    'order_id' => $orderId,
                    'item_id' => $item['id'],
                    'item_name' => $item['name'],
                    'item_type' => $item['type'],
                    'price' => $item['price'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                if (Schema::hasColumn('order_items', 'meta')) {
                    $orderItemData['meta'] = json_encode($item, JSON_UNESCAPED_UNICODE);
                }

                DB::table('order_items')->insert($orderItemData);
            }

            if (!$isVnpay) {
                $this->processCartItems($cart, $user);

                DB::table('orders')->where('id', $orderId)->update([
                    'status' => 'completed',
                    'updated_at' => now(),
                ]);

                DB::commit();

                return response()->json([
                    'message' => 'Thanh toán thành công!',
                    'order_id' => $orderId,
                    'payment_method' => $paymentMethod,
                    'status' => 'completed',
                ], 200);
            }

            DB::commit();

            $paymentUrl = $vnpayService->createPaymentUrl($orderId, $totalAmount, (string) $request->ip());

            return response()->json([
                'message' => 'Đã tạo liên kết thanh toán VNPay',
                'order_id' => $orderId,
                'payment_method' => $paymentMethod,
                'status' => 'pending',
                'payment_url' => $paymentUrl,
            ], 200);
        } catch (\Throwable $e) {
            DB::rollBack();

            Log::error('Checkout Error: ' . $e->getMessage());

            return response()->json([
                'message' => 'Lỗi xử lý thanh toán: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function vnpayReturn(Request $request, VnpayService $vnpayService)
    {
        $result = $this->handleVnpayCallback($request, $vnpayService);

        $title = $result['success'] ? 'Thanh toán thành công' : 'Thanh toán thất bại';
        $message = $result['message'] ?? $title;

        $orderId = (string) ($result['order_id'] ?? ($request->query('vnp_TxnRef') ?? ''));
        $status = $result['success'] ? 'success' : 'failed';
        $appUrl = 'fitzone://vnpay-return?' . http_build_query([
            'status' => $status,
            'order_id' => $orderId,
            'message' => $message,
        ], '', '&', PHP_QUERY_RFC3986);
        $appUrlJs = json_encode($appUrl, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $fallbackUrlJs = json_encode(config('app.url'), JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);

        $cardColor = $result['success'] ? '#12b76a' : '#f04438';
        $accent = $result['success'] ? '#d1fadf' : '#fee4e2';
        $icon = $result['success'] ? '✓' : '!';

        $html = <<<HTML
<!doctype html>
<html lang="vi">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#0f172a">
    <title>{$title}</title>
    <style>
        :root {
            --bg1: #0f172a;
            --bg2: #111827;
            --card: rgba(255,255,255,0.96);
            --text: #0f172a;
            --muted: #475467;
            --primary: {$cardColor};
            --accent: {$accent};
            --shadow: 0 24px 80px rgba(15, 23, 42, 0.22);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background:
                radial-gradient(circle at top, rgba(56, 189, 248, 0.26), transparent 34%),
                radial-gradient(circle at bottom right, rgba(34, 197, 94, 0.18), transparent 28%),
                linear-gradient(135deg, var(--bg1), var(--bg2));
            display: grid;
            place-items: center;
            padding: 24px;
            color: var(--text);
        }
        .shell {
            width: min(100%, 520px);
            position: relative;
        }
        .card {
            background: var(--card);
            border-radius: 28px;
            padding: 28px;
            box-shadow: var(--shadow);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255,255,255,0.4);
            overflow: hidden;
        }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border-radius: 999px;
            background: var(--accent);
            color: var(--primary);
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 18px;
        }
        .icon {
            width: 72px;
            height: 72px;
            border-radius: 999px;
            display: grid;
            place-items: center;
            font-size: 36px;
            color: #fff;
            background: var(--primary);
            margin-bottom: 16px;
            box-shadow: 0 14px 30px color-mix(in srgb, var(--primary) 30%, transparent);
        }
        h1 {
            margin: 0;
            font-size: clamp(28px, 4vw, 38px);
            line-height: 1.15;
            letter-spacing: -0.03em;
        }
        .message {
            margin-top: 10px;
            color: var(--muted);
            font-size: 16px;
            line-height: 1.65;
        }
        .meta {
            margin-top: 22px;
            display: grid;
            gap: 10px;
            padding: 16px;
            border-radius: 20px;
            background: rgba(15, 23, 42, 0.04);
        }
        .meta-row {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            font-size: 14px;
        }
        .meta-row span:first-child {
            color: #667085;
        }
        .meta-row strong {
            text-align: right;
            color: var(--text);
        }
        .actions {
            display: grid;
            gap: 12px;
            margin-top: 22px;
        }
        .button {
            appearance: none;
            border: 0;
            border-radius: 16px;
            padding: 15px 18px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            transition: transform .18s ease, box-shadow .18s ease, opacity .18s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .button:hover { transform: translateY(-1px); }
        .button.primary {
            background: linear-gradient(135deg, var(--primary), color-mix(in srgb, var(--primary) 80%, #000));
            color: #fff;
            box-shadow: 0 16px 30px color-mix(in srgb, var(--primary) 28%, transparent);
        }
        .button.secondary {
            background: #fff;
            color: var(--text);
            border: 1px solid rgba(15, 23, 42, 0.1);
        }
        .countdown {
            text-align: center;
            color: #98a2b3;
            font-size: 13px;
            margin-top: 8px;
        }
        .footer {
            text-align: center;
            color: rgba(255,255,255,0.72);
            margin-top: 16px;
            font-size: 12px;
        }
        @media (max-width: 420px) {
            .card { padding: 22px; border-radius: 24px; }
            .meta-row { flex-direction: column; gap: 4px; }
            .meta-row strong { text-align: left; }
        }
    </style>
</head>
<body>
    <div class="shell">
        <div class="card">
            <div class="badge">VNPay · Kết quả giao dịch</div>
            <div class="icon">{$icon}</div>
            <h1>{$title}</h1>
            <div class="message">{$message}</div>

            <div class="meta">
                <div class="meta-row"><span>Mã đơn hàng</span><strong>{$orderId}</strong></div>
                <div class="meta-row"><span>Trạng thái</span><strong>{$status}</strong></div>
            </div>

            <div class="actions">
                <a id="openAppButton" class="button primary" href="{$appUrl}">Quay lại app</a>
                <a class="button secondary" href="{$fallbackUrlJs}" target="_blank" rel="noopener">Về trang chủ</a>
            </div>

            <div class="countdown">Tự động quay lại app sau <span id="countdown">10</span> giây</div>
        </div>
        <div class="footer">Nếu app không tự mở, hãy bấm nút Quay lại app ở trên.</div>
    </div>

    <script>
        const appUrl = {$appUrlJs};
        const fallbackUrl = {$fallbackUrlJs};
        const countdownEl = document.getElementById('countdown');

        function openApp() {
            window.location.href = appUrl;
            setTimeout(() => {
                if (document.hidden === false) {
                    window.location.href = fallbackUrl;
                }
            }, 1800);
        }

        document.getElementById('openAppButton').addEventListener('click', (event) => {
            event.preventDefault();
            openApp();
        });

        let seconds = 10;
        const timer = setInterval(() => {
            seconds -= 1;
            countdownEl.textContent = seconds;
            if (seconds <= 0) {
                clearInterval(timer);
                openApp();
            }
        }, 1000);
    </script>
</body>
</html>
HTML;

        return response($html, 200)->header('Content-Type', 'text/html; charset=UTF-8');
    }

    public function vnpayIpn(Request $request, VnpayService $vnpayService)
    {
        return response()->json($this->handleVnpayCallback($request, $vnpayService));
    }

    public function checkoutStatus(Request $request, int $orderId)
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $order = DB::table('orders')->where('id', $orderId)->first();
        if (!$order || (int) $order->user_id !== (int) $user->id) {
            return response()->json(['message' => 'Không tìm thấy đơn hàng'], 404);
        }

        return response()->json([
            'order_id' => $orderId,
            'status' => $order->status,
            'payment_method' => $order->payment_method,
            'message' => $order->status === 'completed' ? 'Thanh toán đã hoàn tất' : 'Thanh toán đang chờ xử lý',
        ]);
    }

    private function handleVnpayCallback(Request $request, VnpayService $vnpayService): array
    {
        $payload = $request->all();

        if (!$vnpayService->verifyCallback($payload)) {
            return ['success' => false, 'message' => 'Chữ ký VNPay không hợp lệ'];
        }

        $orderId = (int) ($payload['vnp_TxnRef'] ?? 0);
        $responseCode = (string) ($payload['vnp_ResponseCode'] ?? '');
        $transactionStatus = (string) ($payload['vnp_TransactionStatus'] ?? '');
        $amount = (int) round(((float) ($payload['vnp_Amount'] ?? 0)) / 100);

        DB::beginTransaction();

        try {
            $order = DB::table('orders')->where('id', $orderId)->lockForUpdate()->first();
            if (!$order) {
                DB::rollBack();
                return ['success' => false, 'message' => 'Không tìm thấy đơn hàng'];
            }

            if ((int) $order->total_amount !== $amount) {
                DB::table('orders')->where('id', $orderId)->update([
                    'status' => 'cancelled',
                    'updated_at' => now(),
                ]);
                DB::commit();
                return ['success' => false, 'message' => 'Số tiền VNPay không khớp'];
            }

            if ($order->status === 'completed') {
                DB::commit();
                return ['success' => true, 'message' => 'Đơn hàng đã được xử lý'];
            }

            if ($responseCode === '00' && $transactionStatus === '00') {
                $items = DB::table('order_items')->where('order_id', $orderId)->get();
                $user = DB::table('users')->where('id', $order->user_id)->first();

                if (!$user) {
                    throw new \Exception('Không tìm thấy người dùng');
                }

                $cart = $items->map(function ($item) {
                    $meta = [];
                    if (!empty($item->meta)) {
                        $decoded = json_decode($item->meta, true);
                        if (is_array($decoded)) {
                            $meta = $decoded;
                        }
                    }

                    $meta['id'] = $item->item_id;
                    $meta['name'] = $item->item_name;
                    $meta['price'] = $item->price;
                    $meta['type'] = $item->item_type;

                    return $meta;
                })->toArray();

                $this->processCartItems($cart, $user);

                DB::table('orders')->where('id', $orderId)->update([
                    'status' => 'completed',
                    'updated_at' => now(),
                ]);

                DB::commit();

                return [
                    'success' => true,
                    'message' => 'Thanh toán VNPay thành công',
                    'order_id' => $orderId,
                ];
            }

            DB::table('orders')->where('id', $orderId)->update([
                'status' => 'cancelled',
                'updated_at' => now(),
            ]);

            DB::commit();

            return [
                'success' => false,
                'message' => 'Thanh toán VNPay thất bại',
                'order_id' => $orderId,
            ];
        } catch (\Throwable $e) {
            DB::rollBack();
            Log::error('VNPay callback error: ' . $e->getMessage());

            return [
                'success' => false,
                'message' => 'Lỗi xử lý VNPay: ' . $e->getMessage(),
            ];
        }
    }

    private function processCartItems(array $cart, $user): void
    {
        foreach ($cart as $item) {
            switch ($item['type']) {
                case 'membership':
                    $months = (int) filter_var($item['schedule'] ?? '', FILTER_SANITIZE_NUMBER_INT);
                    if ($months <= 0) {
                        $months = 1;
                    }

                    $hasUserMembershipColumns = Schema::hasColumn('users', 'membership_package')
                        && Schema::hasColumn('users', 'membership_expiry');

                    $currentExpiry = null;
                    if ($hasUserMembershipColumns && !empty($user->membership_expiry)) {
                        $currentExpiry = Carbon::parse($user->membership_expiry);
                    } elseif (Schema::hasTable('members')) {
                        $latestMember = DB::table('members')
                            ->where('email', $user->email)
                            ->orderBy('created_at', 'desc')
                            ->first();

                        if ($latestMember && !empty($latestMember->end)) {
                            try {
                                $currentExpiry = Carbon::parse($latestMember->end);
                            } catch (\Throwable $th) {
                                $currentExpiry = null;
                            }
                        }
                    }

                    if ($currentExpiry && $currentExpiry->isFuture()) {
                        $newExpiry = $currentExpiry->addMonths($months);
                    } else {
                        $newExpiry = Carbon::now()->addMonths($months);
                    }

                    if ($hasUserMembershipColumns) {
                        DB::table('users')->where('id', $user->id)->update([
                            'membership_package' => $item['name'],
                            'membership_expiry' => $newExpiry,
                            'updated_at' => now(),
                        ]);
                    } elseif (Schema::hasTable('members')) {
                        DB::table('members')->insert([
                            'name' => $user->name,
                            'email' => $user->email,
                            'phone' => $user->phone ?? 'Chưa cập nhật',
                            'pack' => $item['name'],
                            'duration' => $item['schedule'] ?? ($months . ' tháng'),
                            'start' => Carbon::now()->format('Y-m-d'),
                            'end' => $newExpiry->format('Y-m-d'),
                            'price' => $item['price'] ?? 0,
                            'status' => 'active',
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                    break;

                case 'class':
                    $bookedForMember = $item['bookedForMember'] ?? false;
                    $memberId = $item['memberId'] ?? null;
                    $bookingUserId = ($bookedForMember && $memberId) ? $memberId : $user->id;

                    $schedules = [];
                    if (!empty($item['schedules']) && is_array($item['schedules'])) {
                        $schedules = $item['schedules'];
                    } elseif (!empty($item['schedule'])) {
                        $schedules = [$item['schedule']];
                    } else {
                        $schedules = [now()->format('d/m/Y') . ' | ' . ($item['time'] ?? '')];
                    }

                    foreach ($schedules as $scheduleStr) {
                        $existingBooking = DB::table('booking_classes')
                            ->where('user_id', $bookingUserId)
                            ->where('class_id', $item['id'])
                            ->where('schedule', $scheduleStr)
                            ->whereIn('status', ['pending', 'confirmed'])
                            ->first();

                        if ($existingBooking) {
                            throw new \Exception('Khách hàng đã có lịch lớp này: ' . $scheduleStr);
                        }

                        DB::table('booking_classes')->insert([
                            'user_id' => $bookingUserId,
                            'class_id' => $item['id'],
                            'schedule' => $scheduleStr,
                            'status' => 'confirmed',
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);

                        DB::table('gym_classes')->where('id', $item['id'])->increment('registered');

                        DB::table('notifications')->insert([
                            'user_id' => $bookingUserId,
                            'title' => 'Đặt lớp thành công',
                            'message' => $item['name'] . ' • ' . $scheduleStr,
                            'type' => 'success',
                            'related_type' => 'class',
                            'related_id' => $item['id'],
                            'is_read' => 0,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);
                    }
                    break;

                case 'trainer':
                    $bookedForMember = $item['bookedForMember'] ?? false;
                    $memberId = $item['memberId'] ?? null;
                    $bookingUserId = ($bookedForMember && $memberId) ? $memberId : $user->id;
                    $scheduleInfo = $item['schedule'] ?? null;

                    $existingTrainerBooking = DB::table('booking_trainers')
                        ->where('user_id', $bookingUserId)
                        ->where('trainer_id', $item['id'])
                        ->when($scheduleInfo, function ($q) use ($scheduleInfo) {
                            return $q->where('schedule_info', $scheduleInfo);
                        })
                        ->whereIn('status', ['pending', 'confirmed'])
                        ->first();

                    if ($existingTrainerBooking) {
                        throw new \Exception('Khách hàng đã có lịch với HLV này trong cùng thời gian.');
                    }

                    DB::table('booking_trainers')->insert([
                        'user_id' => $bookingUserId,
                        'trainer_id' => $item['id'],
                        'schedule_info' => $scheduleInfo ?? 'Chưa chọn lịch',
                        'status' => 'pending',
                        'created_at' => now(),
                    ]);

                    DB::table('notifications')->insert([
                        'user_id' => $bookingUserId,
                        'title' => 'Yêu cầu thuê HLV đã tạo',
                        'message' => ($item['name'] ?? 'HLV') . ' • ' . ($scheduleInfo ?? 'Chưa chọn lịch'),
                        'type' => 'booking',
                        'related_type' => 'trainer',
                        'related_id' => $item['id'],
                        'is_read' => 0,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    break;
            }
        }
    }
}
