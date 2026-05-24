<?php

use App\Http\Controllers\Api\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'status' => 'ok',
        'service' => 'gym-scheduler-backend',
    ]);
});

Route::match(['get', 'post'], '/vnpay/return', [OrderController::class, 'vnpayReturn']);
Route::match(['get', 'post'], '/vnpay/ipn', [OrderController::class, 'vnpayIpn']);

