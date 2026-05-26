<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserCart extends Model
{
    protected $table = 'user_carts';

    protected $fillable = ['user_id', 'items'];

    protected $casts = [
        'items' => 'array',
    ];
}
