<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class GymClassController extends Controller
{
    private function parseClassDate(?string $value): ?Carbon
    {
        $raw = trim((string) $value);
        if ($raw === '') {
            return null;
        }

        $formats = ['Y-m-d', 'd/m/Y', 'd-m-Y', 'd.m.Y'];
        foreach ($formats as $format) {
            try {
                return Carbon::createFromFormat($format, $raw)->startOfDay();
            } catch (\Throwable $e) {
            }
        }

        if (preg_match('/(\d{4}-\d{2}-\d{2})/', $raw, $match)) {
            try {
                return Carbon::parse($match[1])->startOfDay();
            } catch (\Throwable $e) {
            }
        }

        return null;
    }
    
    public function index()
    {
        $rows = DB::table('gym_classes')
            ->orderBy('created_at', 'desc')
            ->get();

        $today = Carbon::now()->startOfDay();
        $filtered = $rows->filter(function ($r) use ($today) {
            $classDate = $this->parseClassDate($r->days ?? null);
            if (!$classDate) {
                return false;
            }

            return !$classDate->lt($today);
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

