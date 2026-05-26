<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserCart;

class CartController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthenticated'], 401);

        $cart = UserCart::where('user_id', $user->id)->first();
        return response()->json(['items' => $cart ? $cart->items : []], 200);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthenticated'], 401);

        $items = $request->input('items', []);
        $cart = UserCart::updateOrCreate(
            ['user_id' => $user->id],
            ['items' => $items]
        );

        return response()->json(['success' => true, 'items' => $cart->items], 200);
    }

    public function destroy(Request $request)
    {
        $user = $request->user();
        if (!$user) return response()->json(['message' => 'Unauthenticated'], 401);

        UserCart::where('user_id', $user->id)->delete();
        return response()->json(['success' => true], 200);
    }
}
