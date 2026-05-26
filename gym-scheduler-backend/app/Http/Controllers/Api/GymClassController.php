<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class GymClassController extends Controller
{
    
    public function index()
    {
        $rows = DB::table('gym_classes')
            ->orderBy('created_at', 'desc')
            ->get();

        $today = Carbon::now()->startOfDay();
        $filtered = $rows->filter(function ($r) use ($today) {
            $days = trim((string) ($r->days ?? ''));
            if ($days === '') return true; // no date info -> show

            // try parse explicit date formats from days field
            $formats = ['Y-m-d', 'd-m-Y', 'd/m/Y', 'd.m.Y'];
            foreach ($formats as $fmt) {
                try {
                    $d = Carbon::createFromFormat($fmt, $days);
                    if ($d->startOfDay()->lt($today)) {
                        return false; // past single-date class -> hide
                    }
                    return true; // date is today or future
                } catch (\Exception $e) {
                    // continue trying other formats
                }
            }

            // if days contains an ISO date anywhere, try parse
            if (preg_match('/\d{4}-\d{2}-\d{2}/', $days, $m)) {
                try {
                    $d = Carbon::parse($m[0]);
                    return !$d->startOfDay()->lt($today);
                } catch (\Exception $e) {}
            }

            // fallback: keep item (likely recurring weekdays like "T2,T4")
            return true;
        })->values();

        return response()->json($filtered, 200);
    }

    
    public function show($id)
    {
        $class = DB::table('gym_classes')->where('id', $id)->first();

        if (!$class) {
            return response()->json(['message' => 'Lớp học không tồn tại'], 404);
        }

        return response()->json($class, 200);
    }
}

