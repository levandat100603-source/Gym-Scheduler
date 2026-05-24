<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AdminController extends Controller
{
    private function filterColumnsForTable(string $table, array $data): array
    {
        $filtered = [];
        foreach ($data as $column => $value) {
            if (Schema::hasColumn($table, $column)) {
                $filtered[$column] = $value;
            }
        }
        return $filtered;
    }

    private function parseDateFlexible($value)
    {
        if (!$value) {
            return null;
        }

        $value = trim((string) $value);
        if ($value === '') {
            return null;
        }

        $formats = ['Y-m-d', 'd-m-Y', 'd/m/Y'];
        foreach ($formats as $format) {
            try {
                return Carbon::createFromFormat($format, $value)->format('Y-m-d');
            } catch (\Exception $e) {
                // thử định dạng tiếp theo
            }
        }

        try {
            return Carbon::parse($value)->format('Y-m-d');
        } catch (\Exception $e) {
            return null;
        }
    }
    private function toPublicRelativePath($url)
    {
        if (!$url) return null;
        $pos = strpos($url, '/storage/');
        if ($pos === false) return null;
        return substr($url, $pos + strlen('/storage/'));
    }

    private function extractScheduleDate(string $scheduleInfo): ?Carbon
    {
        if (preg_match('/(\d{2}\/\d{2}\/\d{4})/', $scheduleInfo, $matches)) {
            try {
                return Carbon::createFromFormat('d/m/Y', $matches[1]);
            } catch (\Exception $e) {
                return null;
            }
        }

        return null;
    }
    
    public function getData()
    {
        
        $classes = [];
        try {
            $classes = DB::table('gym_classes')->orderBy('id', 'desc')->get();
        } catch (\Exception $e) {}

        
        $trainers = [];
        try {
            $trainers = DB::table('trainers')->orderBy('id', 'desc')->get()->map(function ($t) {
                $user = null;
                if (!empty($t->email)) {
                    $user = DB::table('users')
                        ->where('email', $t->email)
                        ->where('role', 'trainer')
                        ->first();
                }
                if (!$user) {
                    $user = DB::table('users')
                        ->where('role', 'trainer')
                        ->where('name', $t->name)
                        ->first();
                }

                if ($user) {
                    $t->user_id = $user->id;
                    $t->email = $t->email ?? $user->email;
                    $t->phone = $t->phone ?? $user->phone ?? null;
                }

                if (!empty($t->email)) {
                    // Đảm bảo image_url tồn tại để frontend hiển thị
                    if (empty($t->image_url) && !empty($t->image)) {
                        $t->image_url = $t->image;
                    }
                    return $t;
                }
                // Đảm bảo image_url tồn tại để frontend hiển thị
                if (empty($t->image_url) && !empty($t->image)) {
                    $t->image_url = $t->image;
                }
                return $t;
            });
        } catch (\Exception $e) {}

        $workingHoursByTrainer = [];
        try {
            $workingHours = DB::table('working_hours')
                ->orderBy('trainer_id')
                ->orderBy('day_of_week')
                ->get();

            foreach ($workingHours as $hour) {
                $trainerId = (int) $hour->trainer_id;
                if (!isset($workingHoursByTrainer[$trainerId])) {
                    $workingHoursByTrainer[$trainerId] = [];
                }
                $workingHoursByTrainer[$trainerId][] = $hour;
            }

            $trainers = $trainers->map(function ($trainer) use ($workingHoursByTrainer) {
                $trainerId = (int) ($trainer->user_id ?? 0);
                if ($trainerId <= 0) {
                    $trainerId = (int) ($trainer->id ?? 0);
                }
                $trainer->working_hours = $workingHoursByTrainer[$trainerId] ?? [];
                return $trainer;
            });
        } catch (\Exception $e) {}

        
        $packages = [];
        try {
            $packages = DB::table('packages')->orderBy('id', 'desc')->get();
        } catch (\Exception $e) {}

        
        $members = [];
        try {
            $memberUsers = DB::table('users')
                ->where('role', 'member')
                ->orderBy('id', 'desc')
                ->get();

            $memberEmails = $memberUsers->pluck('email')->filter()->values()->all();
            $memberRecords = [];
            if (!empty($memberEmails)) {
                $memberRecords = DB::table('members')
                    ->whereIn('email', $memberEmails)
                    ->get()
                    ->keyBy('email');
            }

            $members = $memberUsers->map(function ($user) use ($memberRecords) {
                $record = (!empty($user->email) && isset($memberRecords[$user->email])) ? $memberRecords[$user->email] : null;
                $member = (object) array_merge((array) $user, $record ? (array) $record : []);
                $member->id = $user->id;
                $member->name = $member->name ?? $user->name;
                $member->email = $member->email ?? $user->email;
                $member->phone = $member->phone ?? $user->phone ?? null;
                if (empty($member->pack) && !empty($member->membership_package)) {
                    $member->pack = $member->membership_package;
                }
                if (empty($member->start) && !empty($member->created_at)) {
                    $member->start = Carbon::parse($member->created_at)->format('Y-m-d');
                }
                if (empty($member->end) && !empty($member->membership_expiry)) {
                    $member->end = Carbon::parse($member->membership_expiry)->format('Y-m-d');
                }

                $months = (int) filter_var($member->duration ?? '', FILTER_SANITIZE_NUMBER_INT);
                if ($months === 0 && !empty($member->pack)) {
                    $pkg = DB::table('packages')->where('name', $member->pack)->first();
                    if ($pkg && !empty($pkg->duration)) {
                        $months = (int) filter_var($pkg->duration, FILTER_SANITIZE_NUMBER_INT);
                        $member->duration = $pkg->duration;
                    }
                }

                if (empty($member->end) && !empty($member->start) && $months > 0) {
                    $member->end = Carbon::parse($member->start)->addMonths($months)->format('Y-m-d');
                }

                if (empty($member->status)) {
                    if (!empty($member->membership_expiry)) {
                        $member->status = Carbon::parse($member->membership_expiry)->isPast() ? 'inactive' : 'active';
                    } else {
                        $member->status = 'active';
                    }
                }

                return $member;
            });
        } catch (\Exception $e) {}

        // Danh sách user chưa là member (dùng cho chọn nhanh khi tạo member)
        $availableUsers = [];
        try {
            $availableUsers = DB::table('users')
                ->where('role', 'user')
                ->orderBy('id', 'desc')
                ->get(['id', 'name', 'email', 'phone']);
        } catch (\Exception $e) {}

        return response()->json([
            'classes' => $classes,
            'trainers' => $trainers,
            'packages' => $packages,
            'members' => $members,
            'available_users' => $availableUsers,
            'working_hours' => $workingHoursByTrainer,
        ]);
    }

    
    public function store(Request $request)
    {
        $type = $request->type;
        $id = $request->id;
        $data = $request->except(['type', 'id', 'image', 'remove_image']); 

        // Loại bỏ các field không cần thiết
        unset($data['id']);

        $tableMap = [
            'classes' => 'gym_classes',
            'trainers' => 'trainers',
            'packages' => 'packages',
            'members' => 'members'
        ];

        if (!isset($tableMap[$type])) return response()->json(['message' => 'Loại không hợp lệ'], 400);
        $table = $tableMap[$type];

        $existingTrainer = null;
        if ($type === 'trainers' && $id) {
            $existingTrainer = DB::table('trainers')->where('id', $id)->first();
        }

        
        
        
        if ($type === 'trainers') {
            $removeImage = $request->boolean('remove_image');

            if ($removeImage && $existingTrainer) {
                $old = $existingTrainer->image_url ?? $existingTrainer->image ?? null;
                if ($old) {
                    $rel = $this->toPublicRelativePath($old);
                    if ($rel) Storage::disk('public')->delete($rel);
                }
                $data['image'] = null;
                if (Schema::hasColumn('trainers', 'image_url')) {
                    $data['image_url'] = null;
                }
            }

            if ($request->hasFile('image')) {
                try {
                    $file = $request->file('image');
                    $filename = 'trainer_' . time() . '.' . $file->getClientOriginalExtension();
                    $path = $file->storeAs('trainers', $filename, 'public');
                   $relativePath = '/storage/' . $path;
                    $data['image'] = $relativePath;
                    if (Schema::hasColumn('trainers', 'image_url')) {
                        $data['image_url'] = $relativePath;
                    }

                    if ($existingTrainer) {
                        $old = $existingTrainer->image_url ?? $existingTrainer->image ?? null;
                        if ($old) {
                            $rel = $this->toPublicRelativePath($old);
                            if ($rel) Storage::disk('public')->delete($rel);
                        }
                    }
                } catch (\Exception $e) {
                    return response()->json(['message' => 'Lỗi khi upload hình ảnh: ' . $e->getMessage()], 400);
                }
            }
        }

        
        
        
        if ($type === 'members') {
            $packageInfo = DB::table('packages')->where('name', $request->pack)->first();
            $price = $packageInfo ? $packageInfo->price : 0;
            $startDate = $this->parseDateFlexible($request->start) ?? now()->format('Y-m-d');
            $durationStr = $request->duration ?? ($packageInfo->duration ?? '0');
            $durationMonths = is_numeric($durationStr) ? (int) $durationStr : (int) filter_var($durationStr, FILTER_SANITIZE_NUMBER_INT);

            $memberData = [
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'pack' => $request->pack,
                'duration' => $durationStr,
                'start' => $startDate,
                'end' => $this->parseDateFlexible($request->end),
                'price' => $price,
                'status' => $request->status ?? 'active',
            ];

            if (!$memberData['end'] && $durationMonths > 0) {
                $memberData['end'] = Carbon::parse($startDate)->addMonths($durationMonths)->format('Y-m-d');
            }

            $memberUser = $id ? DB::table('users')->where('id', $id)->first() : null;
            if (!$memberUser && $request->email) {
                $memberUser = DB::table('users')->where('email', $request->email)->first();
            }

            $originalEmail = $memberUser->email ?? $request->email;
            $memberEmail = $request->email ?? $originalEmail;

            $userPayload = $this->filterColumnsForTable('users', [
                'name' => $request->name,
                'email' => $memberEmail,
                'phone' => $request->phone,
                'role' => 'member',
                'membership_package' => $request->pack,
                'membership_expiry' => $memberData['end'] ? Carbon::parse($memberData['end'])->format('Y-m-d H:i:s') : null,
                'updated_at' => now(),
            ]);

            if ($memberUser) {
                if (!empty($userPayload)) {
                    DB::table('users')->where('id', $memberUser->id)->update($userPayload);
                }
            } else {
                $userPayload = array_merge(
                    $userPayload,
                    $this->filterColumnsForTable('users', [
                        'password' => bcrypt(Str::random(16)),
                        'created_at' => now(),
                    ])
                );
                if (!empty($userPayload)) {
                    DB::table('users')->insert($userPayload);
                }
            }

            $memberPayload = array_merge($memberData, [
                'updated_at' => now(),
            ]);

            $existingMember = $originalEmail ? DB::table('members')->where('email', $originalEmail)->first() : null;
            if ($existingMember) {
                DB::table('members')->where('id', $existingMember->id)->update($memberPayload);
                $msg = 'Cập nhật thành viên thành công';
            } else {
                DB::table('members')->insert(array_merge($memberPayload, [
                    'created_at' => now(),
                ]));
                $msg = 'Đã thêm hội viên mới thành công!';
            }

            return response()->json(['success' => true, 'message' => $msg]);
        }

        
        
        
        if ($type === 'trainers') {
            
            if (!$id && $request->email) {
                $exists = DB::table('users')->where('email', $request->email)->exists();
                if ($exists) {
                    return response()->json(['message' => 'Email này đã có người sử dụng!'], 400);
                }
            }
            
            $trainerEmail = $request->email;
            
            // Lọc bỏ các field không cần
            unset($data['email']);
            unset($data['remove_image']);
            unset($data['icon']); // Nếu form vẫn gửi icon, bỏ đi

            if ($id) {
                // Update existing trainer - chỉ update những field có giá trị
                $updateData = array_filter($data, function ($v, $key) {
                    if (in_array($key, ['image', 'image_url'])) {
                        return true; // Cho phép set null để xóa ảnh
                    }
                    return !is_null($v) && $v !== '';
                }, ARRAY_FILTER_USE_BOTH);
                if (count($updateData) > 0) {
                    DB::table($table)->where('id', $id)->update($updateData);
                }
                $msg = 'Cập nhật huấn luyện viên thành công';
            } else {
                // Insert new trainer - đảm bảo đủ field bắt buộc
                $data = array_filter($data, fn($v) => !is_null($v) && $v !== '');
                
                if (!isset($data['rating']) || $data['rating'] === '') {
                    $data['rating'] = 5.0;
                }
                if (!isset($data['name']) || $data['name'] === '') {
                    $data['name'] = 'Trainer';
                }
                if (!isset($data['spec']) || $data['spec'] === '') {
                    $data['spec'] = 'Training';
                }
                if (!isset($data['exp']) || $data['exp'] === '') {
                    $data['exp'] = '0 năm';
                }
                if (!isset($data['availability']) || $data['availability'] === '') {
                    $data['availability'] = 'Flexible';
                }
                if (!isset($data['price']) || $data['price'] === '') {
                    $data['price'] = 0;
                }
                
                if ($trainerEmail) {
                    DB::table('users')->insertGetId([
                        'name' => $request->name ?? 'Trainer',
                        'email' => $trainerEmail,
                        'password' => bcrypt(Str::random(16)),
                        'role' => 'trainer',
                        'phone' => $request->phone ?? '',
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }

                $data['created_at'] = now();
                DB::table($table)->insert($data);
                
                $msg = 'Thêm huấn luyện viên thành công! Mật khẩu tạm thời đã được tạo ngẫu nhiên để đảm bảo an toàn.';
            }
            
            return response()->json(['success' => true, 'message' => $msg]);
        }

        
        
        
        if ($id) {
            DB::table($table)->where('id', $id)->update($data);
            $msg = 'Cập nhật thành công';
        } else {
            $data['created_at'] = now();
            DB::table($table)->insert($data);
            $msg = 'Thêm mới thành công';
        }

        return response()->json(['success' => true, 'message' => $msg]);
    }

    
    public function delete(Request $request)
    {
        try {
            $type = $request->type;
            $id = $request->id;

            $tableMap = [
                'classes' => 'gym_classes',
                'trainers' => 'trainers',
                'packages' => 'packages',
                'members' => 'members'
            ];

            if (!isset($tableMap[$type])) return response()->json(['message' => 'Loại dữ liệu không hợp lệ'], 400);

            if (!$id) return response()->json(['message' => 'Thiếu id'], 400);

            // Nếu xóa trainer: dọn phụ thuộc và file ảnh
            if ($type === 'trainers') {
                $trainer = DB::table('trainers')->where('id', $id)->first();
                if ($trainer) {
                    // Xóa booking liên quan để tránh lỗi khóa ngoại
                    try {
                        DB::table('booking_trainers')->where('trainer_id', $id)->delete();
                    } catch (\Exception $e) {}

                    // Xóa user trùng email (nếu có) để không còn tài khoản ghost
                    if (!empty($trainer->email)) {
                        try {
                            DB::table('users')->where('email', $trainer->email)->delete();
                        } catch (\Exception $e) {}
                    } else {
                        // Nếu bảng trainers không có email, thử khớp theo name + role trainer
                        try {
                            DB::table('users')
                                ->where('role', 'trainer')
                                ->where('name', $trainer->name)
                                ->delete();
                        } catch (\Exception $e) {}
                    }

                    // Dọn file ảnh
                    $imagePath = $trainer->image_url ?? $trainer->image ?? null;
                    if ($imagePath) {
                        $rel = $this->toPublicRelativePath($imagePath);
                        if ($rel) Storage::disk('public')->delete($rel);
                    }
                }
            }

            if ($type === 'members') {
                $memberUser = DB::table('users')->where('id', $id)->first();
                if (!$memberUser && $request->email) {
                    $memberUser = DB::table('users')->where('email', $request->email)->where('role', 'member')->first();
                }

                if (!$memberUser) {
                    return response()->json(['message' => 'Không tìm thấy bản ghi để xóa'], 404);
                }

                try {
                    DB::table('members')->where('email', $memberUser->email)->delete();
                } catch (\Exception $e) {}

                try {
                    $userUpdatePayload = $this->filterColumnsForTable('users', [
                        'role' => 'user',
                        'membership_package' => null,
                        'membership_expiry' => null,
                        'updated_at' => now()
                    ]);
                    if (!empty($userUpdatePayload)) {
                        DB::table('users')->where('id', $memberUser->id)->update($userUpdatePayload);
                    }
                } catch (\Exception $e) {}

                return response()->json(['success' => true]);
            }

            // Xóa bản ghi chính
            $deleted = DB::table($tableMap[$type])->where('id', $id)->delete();
            if ($deleted === 0) {
                return response()->json(['message' => 'Không tìm thấy bản ghi để xóa'], 404);
            }

            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Không thể xóa mục này', 'error' => $e->getMessage()], 500);
        }
    }

    
    public function getTrainers()
    {
        try {
            // trainers table không còn user_id; bổ sung email/phone từ bảng users (role=trainer)
            $trainers = DB::table('trainers')
                ->orderBy('id', 'desc')
                ->get()
                ->map(function ($t) {
                    $user = null;
                    if (!empty($t->email)) {
                        $user = DB::table('users')
                            ->where('email', $t->email)
                            ->where('role', 'trainer')
                            ->first();
                    }
                    if (!$user) {
                        $user = DB::table('users')
                            ->where('role', 'trainer')
                            ->where('name', $t->name)
                            ->first();
                    }

                    if ($user) {
                        $t->user_id = $user->id;
                        $t->email = $t->email ?? $user->email;
                        $t->phone = $t->phone ?? $user->phone ?? null;
                    }

                    // Ưu tiên ảnh từ bảng trainers, fallback sang avatar của user trainer.
                    if (empty($t->image_url)) {
                        if (!empty($t->image)) {
                            $t->image_url = $t->image;
                        } elseif (!empty($user?->avatar)) {
                            $t->image_url = $user->avatar;
                        }
                    }

                    return $t;
                });
            return response()->json($trainers);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Lỗi khi lấy dữ liệu huấn luyện viên'], 500);
        }
    }

    
    public function getPackages()
    {
        try {
            $packages = DB::table('packages')->orderBy('id', 'desc')->get();
            return response()->json($packages);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Lỗi khi lấy dữ liệu gói tập'], 500);
        }
    }

    public function getTrainerScheduleDetails($trainerId)
    {
        try {
            $trainer = DB::table('trainers')->where('id', $trainerId)->first();
            if (!$trainer) {
                $trainer = DB::table('trainers')
                    ->whereExists(function ($query) use ($trainerId) {
                        $query->select(DB::raw(1))
                            ->from('users')
                            ->whereColumn('users.email', 'trainers.email')
                            ->where('users.id', $trainerId)
                            ->where('users.role', 'trainer');
                    })
                    ->first();
            }
            if (!$trainer) {
                return response()->json(['message' => 'HLV không tồn tại'], 404);
            }

            $trainerUser = null;
            if (!empty($trainer->email)) {
                $trainerUser = DB::table('users')
                    ->where('email', $trainer->email)
                    ->where('role', 'trainer')
                    ->first();
            }
            if (!$trainerUser) {
                $trainerUser = DB::table('users')
                    ->where('role', 'trainer')
                    ->where('name', $trainer->name)
                    ->first();
            }

            $trainerUserId = $trainerUser->id ?? null;
            $workingHours = [];
            if ($trainerUserId) {
                $workingHours = DB::table('working_hours')
                    ->where('trainer_id', $trainerUserId)
                    ->orderBy('day_of_week')
                    ->get();
            }

            $bookings = DB::table('booking_trainers as bt')
                ->join('users as u', 'bt.user_id', '=', 'u.id')
                ->where('bt.trainer_id', $trainerId)
                ->select('bt.*', 'u.name as user_name', 'u.email as user_email', 'u.phone as user_phone')
                ->orderBy('bt.created_at', 'desc')
                ->get();

            $weekStart = Carbon::now()->startOfWeek(Carbon::MONDAY);
            $weekEnd = Carbon::now()->endOfWeek(Carbon::SUNDAY);
            $weeklyBookings = [];
            $otherBookings = [];

            foreach ($bookings as $booking) {
                $scheduleInfo = (string) ($booking->schedule_info ?? '');
                $scheduleDate = $this->extractScheduleDate($scheduleInfo);
                if ($scheduleDate) {
                    $booking->schedule_date = $scheduleDate->format('Y-m-d');
                }

                if ($scheduleDate && $scheduleDate->betweenIncluded($weekStart, $weekEnd)) {
                    $weeklyBookings[] = $booking;
                } else {
                    $otherBookings[] = $booking;
                }
            }

            return response()->json([
                'trainer' => [
                    'id' => $trainer->id,
                    'name' => $trainer->name,
                    'email' => $trainer->email ?? $trainerUser->email ?? null,
                    'phone' => $trainer->phone ?? $trainerUser->phone ?? null,
                    'user_id' => $trainerUserId,
                ],
                'working_hours' => $workingHours,
                'weekly_bookings' => $weeklyBookings,
                'other_bookings' => $otherBookings,
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Không thể lấy chi tiết lịch HLV', 'error' => $e->getMessage()], 500);
        }
    }

    // Đồng bộ: tạo hoặc cập nhật user cho tất cả trainer có email
    public function syncTrainersUsers(Request $request)
    {
        $password = $request->input('password', Str::random(16));
        $trainers = DB::table('trainers')
            ->whereNotNull('email')
            ->where('email', '<>', '')
            ->get();

        $created = 0;
        $updated = 0;

        foreach ($trainers as $t) {
            $user = DB::table('users')->where('email', $t->email)->first();
            if (!$user) {
                DB::table('users')->insert([
                    'name' => $t->name ?? 'Trainer',
                    'email' => $t->email,
                    'password' => bcrypt($password),
                    'role' => 'trainer',
                    'phone' => $t->phone ?? '',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                $created++;
            } else {
                $needsUpdate = false;
                $updateData = [];
                if ($user->role !== 'trainer') {
                    $updateData['role'] = 'trainer';
                    $needsUpdate = true;
                }
                if (!empty($t->name) && $t->name !== $user->name) {
                    $updateData['name'] = $t->name;
                    $needsUpdate = true;
                }
                if ($needsUpdate) {
                    $updateData['updated_at'] = now();
                    DB::table('users')->where('id', $user->id)->update($updateData);
                    $updated++;
                }
            }
        }

        return response()->json([
            'success' => true,
            'created' => $created,
            'updated' => $updated,
            'total_trainers_with_email' => $trainers->count()
        ]);
    }

    
    public function bookClassForMember(Request $request)
    {
        try {
            $userId = $request->user_id;
            $classId = $request->class_id;
            $userName = $request->user_name;
            $userEmail = $request->user_email;

            
            if (!$userId || !$classId) {
                return response()->json(['message' => 'Thiếu thông tin khách hàng hoặc lớp tập'], 400);
            }

            
            $existingBooking = DB::table('booking_classes')
                ->where('user_id', $userId)
                ->where('class_id', $classId)
                ->whereIn('status', ['pending', 'confirmed'])
                ->first();

            if ($existingBooking) {
                return response()->json(['message' => 'Khách hàng đã có lịch tập này (chưa thanh toán hoặc đã thanh toán)'], 400);
            }

            
            $gymClass = DB::table('gym_classes')->where('id', $classId)->first();
            if (!$gymClass) {
                return response()->json(['message' => 'Lớp tập không tồn tại'], 404);
            }

            
            $bookingId = DB::table('booking_classes')->insertGetId([
                'user_id' => $userId,
                'class_id' => $classId,
                'schedule' => 'Đặt bởi Admin - ' . now()->format('d/m/Y H:i'),
                'status' => 'pending', 
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'message' => 'Đã thêm lớp tập vào giỏ hàng của khách hàng',
                'booking_id' => $bookingId
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json(['message' => 'Lỗi: ' . $e->getMessage()], 500);
        }
    }

    
    public function bookTrainerForMember(Request $request)
    {
        try {
            $userId = $request->user_id;
            $trainerId = $request->trainer_id;
            $userName = $request->user_name;
            $userEmail = $request->user_email;

            
            if (!$userId || !$trainerId) {
                return response()->json(['message' => 'Thiếu thông tin khách hàng hoặc HLV'], 400);
            }

            
            $existingBooking = DB::table('booking_trainers')
                ->where('user_id', $userId)
                ->where('trainer_id', $trainerId)
                ->whereIn('status', ['pending', 'confirmed'])
                ->first();

            if ($existingBooking) {
                return response()->json(['message' => 'Khách hàng đã có lịch với HLV này'], 400);
            }

            
            $trainer = DB::table('trainers')->where('id', $trainerId)->first();
            if (!$trainer) {
                return response()->json(['message' => 'HLV không tồn tại'], 404);
            }

            
            $bookingId = DB::table('booking_trainers')->insertGetId([
                'user_id' => $userId,
                'trainer_id' => $trainerId,
                'schedule_info' => 'Đặt bởi Admin - ' . now()->format('d/m/Y H:i'),
                'status' => 'pending', 
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            return response()->json([
                'message' => 'Đã thêm HLV vào giỏ hàng của khách hàng',
                'booking_id' => $bookingId
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Lỗi: ' . $e->getMessage()], 500);
        }
    }
}
