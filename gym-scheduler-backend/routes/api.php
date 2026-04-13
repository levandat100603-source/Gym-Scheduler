<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ScheduleController; 
use App\Http\Controllers\Api\GymClassController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\HistoryController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\PackageController;
use App\Http\Controllers\Api\BookingController;

Route::get('/', function () {
    return response()->json(['message' => 'API OK']);
});

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/send-verification-code', [AuthController::class, 'sendVerificationCode']);
Route::post('/verify-email', [AuthController::class, 'verifyEmail']); 


Route::middleware('auth:sanctum')->group(function () {
    
    Route::get('/schedules', [ScheduleController::class, 'index']);
    Route::post('/schedules', [ScheduleController::class, 'store']);
    Route::put('/schedules/{schedule}', [ScheduleController::class, 'update']);
    Route::delete('/schedules/{schedule}', [ScheduleController::class, 'destroy']);
    
    
    Route::get('/gym-classes', [GymClassController::class, 'index']);
    Route::get('/gym-classes/{id}', [GymClassController::class, 'show']);
    
    
    Route::get('/trainers', [AdminController::class, 'getTrainers']);
    Route::get('/packages', [AdminController::class, 'getPackages']);

    Route::middleware(['role:admin', 'can:admin-access'])->group(function () {
        Route::post('/admin/sync-trainers', [AdminController::class, 'syncTrainersUsers']);
        Route::get('/admin/data', [AdminController::class, 'getData']);
        Route::post('/admin/store', [AdminController::class, 'store']);
        Route::post('/admin/delete', [AdminController::class, 'delete']);
        Route::get('/admin/members', [MemberController::class, 'index']);
        Route::get('/admin/bookings', [BookingController::class, 'getAllPendingBookings']);
        Route::post('/admin/book-class', [AdminController::class, 'bookClassForMember']);
        Route::post('/admin/book-trainer', [AdminController::class, 'bookTrainerForMember']);
    });
    
    
    Route::post('/member/check-conflict', [MemberController::class, 'checkBookingConflict']);
    Route::post('/member/expo-token', [MemberController::class, 'saveExpoPushToken']);
    
    
    Route::post('/checkout', [OrderController::class, 'checkout']);
    
    
    Route::middleware('can:manage-trainer-bookings')->group(function () {
        Route::get('/bookings/pending', [BookingController::class, 'getPendingBookings']);
        Route::get('/bookings/trainer-schedule', [BookingController::class, 'getTrainerSchedule']);
        Route::post('/bookings/confirm', [BookingController::class, 'confirmBooking']);
    });
    Route::get('/bookings/my-bookings', [BookingController::class, 'getMyBookings']); 
    Route::get('/notifications', [BookingController::class, 'getNotifications']); 
    Route::post('/notifications/read', [BookingController::class, 'markAsRead']); 
    
    
    Route::get('/dashboard-stats', [DashboardController::class, 'index']);
    Route::post('/dashboard-reset', [DashboardController::class, 'reset']);
    Route::get('/user/history', [HistoryController::class, 'index']);
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
    Route::post('/user/avatar', [AuthController::class, 'updateAvatar']);
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);


});