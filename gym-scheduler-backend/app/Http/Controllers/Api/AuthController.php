<?php

namespace App\Http\Controllers\Api; 

use App\Http\Controllers\Controller; 
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\EmailVerificationCode;
use App\Models\PendingRegistration;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function updateAvatar(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'avatar' => 'required|image|mimes:jpg,jpeg,png,webp|max:2048',
        ], [
            'avatar.required' => 'Vui lòng chọn ảnh đại diện',
            'avatar.image' => 'Tệp tải lên phải là ảnh',
            'avatar.max' => 'Ảnh đại diện không được vượt quá 2MB',
        ]);

        if ($user->avatar) {
            $oldPath = ltrim((string) $user->avatar, '/');
            if (str_starts_with($oldPath, 'storage/')) {
                $storagePath = substr($oldPath, strlen('storage/'));
                if ($storagePath !== '') {
                    Storage::disk('public')->delete($storagePath);
                }
            }
        }

        $storedPath = $request->file('avatar')->store('avatars', 'public');
        $publicPath = '/storage/' . $storedPath;

        $user->avatar = $publicPath;
        $user->save();

        return response()->json([
            'message' => 'Cập nhật ảnh đại diện thành công',
            'avatar' => $publicPath,
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:20',
        ], [
            'name.required' => 'Vui lòng nhập họ tên',
            'name.max' => 'Họ tên không được vượt quá 255 ký tự',
            'phone.max' => 'Số điện thoại không được vượt quá 20 ký tự',
        ]);

        $user->name = $validated['name'];
        $user->phone = $validated['phone'] ?? null;
        $user->save();

        return response()->json([
            'message' => 'Cập nhật hồ sơ thành công',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role,
            ],
        ]);
    }

    public function changePassword(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'current_password' => 'required|string|min:6',
            'new_password' => 'required|string|min:6|different:current_password|confirmed',
        ], [
            'current_password.required' => 'Vui lòng nhập mật khẩu hiện tại',
            'new_password.required' => 'Vui lòng nhập mật khẩu mới',
            'new_password.min' => 'Mật khẩu mới phải có ít nhất 6 ký tự',
            'new_password.different' => 'Mật khẩu mới phải khác mật khẩu hiện tại',
            'new_password.confirmed' => 'Xác nhận mật khẩu mới không khớp',
        ]);

        if (!Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'message' => 'Mật khẩu hiện tại không đúng',
            ], 422);
        }

        $user->password = Hash::make($validated['new_password']);
        $user->save();

        return response()->json([
            'message' => 'Đổi mật khẩu thành công',
        ]);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6',
        ], [
            'email.required' => 'Vui lòng nhập email',
            'email.email' => 'Email không đúng định dạng',
            'password.required' => 'Vui lòng nhập mật khẩu',
            'password.min' => 'Mật khẩu phải có ít nhất 6 ký tự',
        ]);

        
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại!'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        
        return response()->json([
            'message' => 'Đăng nhập thành công',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role, 
            ]
        ]);
    }
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ], [
            'email.unique' => 'Email đã được đăng ký',
            'name.required' => 'Vui lòng nhập họ tên',
            'email.required' => 'Vui lòng nhập email',
            'email.email' => 'Email không đúng định dạng',
            'password.required' => 'Vui lòng nhập mật khẩu',
            'password.min' => 'Mật khẩu phải có ít nhất 6 ký tự',
        ]);

        PendingRegistration::where('email', $request->email)
            ->whereNull('verified_at')
            ->delete();


        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $pendingUser = PendingRegistration::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'verification_code' => $code,
            'code_expires_at' => Carbon::now()->addSeconds(60), // chỉ hiệu lực 60s
        ]);

        try {
            $this->sendVerificationEmail($request->email, $request->name, $code);
        } catch (\Exception $e) {
            \Log::error('Failed to send verification email: ' . $e->getMessage());
        }

        return response()->json([
            'message' => 'Đăng ký thành công. Vui lòng kiểm tra email để xác thực tài khoản',
            'pending_id' => $pendingUser->id,
            'email' => $pendingUser->email,
        ], 201);
    }

    public function sendVerificationCode(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email|max:255',
        ]);

        $pendingUser = PendingRegistration::where('email', $request->email)
            ->whereNull('verified_at')
            ->first();

        if (!$pendingUser) {
            return response()->json([
                'message' => 'Không tìm thấy đăng ký chưa xác thực cho email này',
            ], 404);
        }

        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $pendingUser->update([
            'verification_code' => $code,
            'code_expires_at' => Carbon::now()->addMinutes(15),
        ]);

        try {
            $this->sendVerificationEmail($pendingUser->email, $pendingUser->name, $code);
        } catch (\Exception $e) {
            \Log::error('Failed to send verification email: ' . $e->getMessage());
            return response()->json([
                'message' => 'Không thể gửi email. Vui lòng thử lại',
            ], 500);
        }

        return response()->json([
            'message' => 'Mã xác thực đã được gửi đến email của bạn',
        ]);
    }

    public function verifyEmail(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'code' => 'required|string|size:6',
        ]);

        $pendingUser = PendingRegistration::where('email', $request->email)
            ->whereNull('verified_at')
            ->first();

        if (!$pendingUser || $pendingUser->verification_code !== $request->code) {
            // Nếu sai mã thì xóa luôn bản ghi pending
            if ($pendingUser) $pendingUser->delete();
            return response()->json([
                'message' => 'Mã xác thực không đúng hoặc đã hết hạn. Vui lòng đăng ký lại.',
            ], 422);
        }

        if ($pendingUser->isExpired()) {
            $pendingUser->delete();
            return response()->json([
                'message' => 'Mã xác thực đã hết hạn (quá 60 giây). Vui lòng đăng ký lại.',
            ], 422);
        }

        $user = User::create([
            'name' => $pendingUser->name,
            'email' => $pendingUser->email,
            'password' => $pendingUser->password,
            'role' => 'user',
            'email_verified' => true,
            'email_verified_at' => Carbon::now(),
        ]);

        // Xóa bản ghi pending sau khi tạo user thành công
        $pendingUser->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Xác thực email thành công',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
            ]
        ]);
    }

    private function generateVerificationCode(User $user): EmailVerificationCode
    {
        EmailVerificationCode::where('user_id', $user->id)
            ->where('verified_at', null)
            ->delete();

        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        return EmailVerificationCode::create([
            'user_id' => $user->id,
            'code' => $code,
            'expires_at' => Carbon::now()->addMinutes(15),
        ]);
    }

    private function sendVerificationEmail(string $email, string $name, string $code): void
    {
        $message = "Xin chào {$name},\n\nMã xác thực của bạn là: {$code}\n\nMã này sẽ hết hạn sau 15 phút.";

        if (config('mail.mailer') !== 'log') {
            Mail::raw($message, function ($mail) use ($email, $name) {
                $mail->to($email)
                    ->subject('Xác thực email FitZone Gym');
            });
        }
    }
}
