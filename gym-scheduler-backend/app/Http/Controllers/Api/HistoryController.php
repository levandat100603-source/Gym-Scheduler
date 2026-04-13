<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class HistoryController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        
        $membership = [
            'package' => $user->membership_package ?? 'Chưa đăng ký',
            'expiry' => $user->membership_expiry,
            'is_active' => $user->membership_expiry && now()->lte($user->membership_expiry)
        ];

        
        $classes = DB::table('booking_classes')
            ->join('gym_classes', 'booking_classes.class_id', '=', 'gym_classes.id')
            ->where('booking_classes.user_id', $user->id)
            ->select(
                'gym_classes.name as class_name',
                'gym_classes.location',
                'booking_classes.schedule',
                'booking_classes.status'
            )
            ->orderBy('booking_classes.created_at', 'desc')
            ->get();

        
        $trainers = DB::table('booking_trainers')
            ->join('trainers', 'booking_trainers.trainer_id', '=', 'trainers.id')
            ->where('booking_trainers.user_id', $user->id)
            ->select(
                'trainers.name as trainer_name',
                'booking_trainers.schedule_info',
                'booking_trainers.status'
            )
            ->orderBy('booking_trainers.created_at', 'desc')
            ->get();

        return response()->json([
            'user_info' => [
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'avatar' => $user->avatar
            ],
            'membership' => $membership,
            'classes' => $classes,
            'trainers' => $trainers
        ]);
    }
}
