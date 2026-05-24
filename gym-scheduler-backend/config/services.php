<?php

return [

    

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'vnpay' => [
        'tmn_code' => trim((string) env('VNPAY_TMN_CODE')),
        'hash_secret' => trim((string) env('VNPAY_HASH_KEY')),
        'url' => trim((string) env('VNPAY_API_URL', 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html')),
        'return_url' => trim((string) env('VNPAY_RETURN_URL', 'https://gym-scheduler-3kbu.onrender.com/vnpay/return')),
        'ipn_url' => trim((string) env('VNPAY_IPN_URL', 'https://gym-scheduler-3kbu.onrender.com/vnpay/ipn')),
    ],

];

