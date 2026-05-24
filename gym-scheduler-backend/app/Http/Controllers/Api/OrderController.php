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

        $html = '<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>' . e($title) . '</title><style>body{font-family:Arial,sans-serif;background:#f6f7f8;margin:0;display:flex;align-items:center;justify-content:center;min-height:100vh}.card{background:#fff;border-radius:16px;padding:24px;max-width:420px;width:calc(100% - 32px);box-shadow:0 12px 30px rgba(0,0,0,.08);text-align:center}h1{font-size:20px;margin:0 0 12px}p{margin:0;color:#444;line-height:1.5}</style></head><body><div class="card"><h1>' . e($title) . '</h1><p>' . e($message) . '</p></div></body></html>';

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
