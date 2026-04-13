<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class OrderController extends Controller
{
    public function checkout(Request $request)
    {
        
        $request->validate([
            'cart' => 'required|array',
            'payment_method' => 'required|string',
            'total' => 'required|numeric',
        ]);

        $user = Auth::user(); 
        $cart = $request->input('cart');
        $paymentMethod = $request->input('payment_method');
        $totalAmount = $request->input('total');

        if (empty($cart)) {
            return response()->json(['message' => 'Giỏ hàng trống'], 400);
        }

        
        DB::beginTransaction();

        try {
            
            $orderId = DB::table('orders')->insertGetId([
                'user_id' => $user->id,
                'total_amount' => $totalAmount,
                'payment_method' => $paymentMethod,
                'status' => 'completed', 
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            
            foreach ($cart as $item) {
                
                DB::table('order_items')->insert([
                    'order_id' => $orderId,
                    'item_id' => $item['id'],
                    'item_name' => $item['name'],
                    'item_type' => $item['type'], 
                    'price' => $item['price'],
                ]);

                
                switch ($item['type']) {
                    
                    case 'membership':
                        
                        $months = (int) filter_var($item['schedule'], FILTER_SANITIZE_NUMBER_INT);
                        if ($months <= 0) $months = 1; 

                        
                        $currentExpiry = $user->membership_expiry ? Carbon::parse($user->membership_expiry) : null;
                        
                        if ($currentExpiry && $currentExpiry->isFuture()) {
                            
                            $newExpiry = $currentExpiry->addMonths($months);
                        } else {
                            
                            $newExpiry = Carbon::now()->addMonths($months);
                        }

                        
                        DB::table('users')->where('id', $user->id)->update([
                            'membership_package' => $item['name'],
                            'membership_expiry' => $newExpiry,
                            'updated_at' => now()
                        ]);
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

            DB::commit(); 
            
            return response()->json([
                'message' => 'Thanh toán thành công!', 
                'order_id' => $orderId
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack(); 
            
            \Illuminate\Support\Facades\Log::error("Checkout Error: " . $e->getMessage());
            
            return response()->json([
                'message' => 'Lỗi xử lý thanh toán: ' . $e->getMessage()
            ], 500);
        }
    }
}
