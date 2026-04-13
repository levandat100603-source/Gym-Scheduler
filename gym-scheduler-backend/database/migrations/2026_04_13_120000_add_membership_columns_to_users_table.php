<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('users')) {
            return;
        }

        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'membership_package')) {
                $table->string('membership_package')->nullable()->after('phone');
            }

            if (!Schema::hasColumn('users', 'membership_expiry')) {
                $table->timestamp('membership_expiry')->nullable()->after('membership_package');
            }
        });
    }

    public function down(): void
    {
        if (!Schema::hasTable('users')) {
            return;
        }

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'membership_expiry')) {
                $table->dropColumn('membership_expiry');
            }

            if (Schema::hasColumn('users', 'membership_package')) {
                $table->dropColumn('membership_package');
            }
        });
    }
};
