<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class VnpayService
{
    public function createPaymentUrl(int $orderId, float|int $amount, string $ipAddress): string
    {
        $tmnCode = (string) config('services.vnpay.tmn_code');
        $hashSecret = (string) config('services.vnpay.hash_secret');
        $gatewayUrl = (string) config('services.vnpay.url');
        $returnUrl = (string) config('services.vnpay.return_url');

        if ($tmnCode === '' || $hashSecret === '' || $gatewayUrl === '' || $returnUrl === '') {
            throw new \RuntimeException('VNPay configuration is missing.');
        }

        $inputData = [
            'vnp_Version' => '2.1.0',
            'vnp_Command' => 'pay',
            'vnp_TmnCode' => $tmnCode,
            'vnp_Amount' => (int) round($amount * 100),
            'vnp_CurrCode' => 'VND',
            'vnp_TxnRef' => (string) $orderId,
            'vnp_OrderInfo' => 'Thanh toan don hang #' . $orderId,
            'vnp_OrderType' => 'other',
            'vnp_Locale' => 'vn',
            'vnp_ReturnUrl' => $returnUrl,
            'vnp_IpAddr' => $ipAddress ?: '127.0.0.1',
            'vnp_CreateDate' => Carbon::now('Asia/Ho_Chi_Minh')->format('YmdHis'),
            'vnp_ExpireDate' => Carbon::now('Asia/Ho_Chi_Minh')->addMinutes(15)->format('YmdHis'),
        ];

        ksort($inputData);
        $query = http_build_query($inputData, '', '&', PHP_QUERY_RFC3986);
        $hashData = urldecode($query);
        $secureHash = hash_hmac('sha512', $hashData, $hashSecret);

        // Temporary debug log to help diagnose signature mismatches
        Log::debug('vnpay:generated', [
            'query' => $query,
            'secureHash' => $secureHash,
        ]);

        return $gatewayUrl . '?' . $query . '&vnp_SecureHash=' . $secureHash;
    }

    public function verifyCallback(array $input): bool
    {
        $secureHash = (string) ($input['vnp_SecureHash'] ?? '');
        $hashSecret = (string) config('services.vnpay.hash_secret');

        if ($secureHash === '' || $hashSecret === '') {
            return false;
        }

        unset($input['vnp_SecureHash'], $input['vnp_SecureHashType']);
        ksort($input);
        $hashData = urldecode(http_build_query($input, '', '&', PHP_QUERY_RFC3986));

        $expected = hash_hmac('sha512', $hashData, $hashSecret);

        // compare case-insensitively
        return hash_equals(strtoupper($expected), strtoupper($secureHash));
    }
}