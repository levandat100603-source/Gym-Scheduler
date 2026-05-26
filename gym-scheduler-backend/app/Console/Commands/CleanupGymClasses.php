<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CleanupGymClasses extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'gym:cleanup-classes {--dry-run : Do not delete, only report}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete past single-date gym classes (recurring classes are preserved).';

    public function handle()
    {
        $today = Carbon::now()->startOfDay();
        $formats = ['Y-m-d', 'd-m-Y', 'd/m/Y', 'd.m.Y'];

        $rows = DB::table('gym_classes')->get();
        $toDelete = [];

        foreach ($rows as $r) {
            $days = trim((string) ($r->days ?? ''));
            if ($days === '') continue;

            $foundDate = null;
            foreach ($formats as $fmt) {
                try {
                    $d = Carbon::createFromFormat($fmt, $days);
                    $foundDate = $d->startOfDay();
                    break;
                } catch (\Exception $e) {
                }
            }

            if (!$foundDate) {
                if (preg_match('/(\d{4}-\d{2}-\d{2})/', $days, $m)) {
                    try {
                        $foundDate = Carbon::parse($m[1])->startOfDay();
                    } catch (\Exception $e) {}
                }
            }

            if ($foundDate && $foundDate->lt($today)) {
                $toDelete[] = $r->id;
            }
        }

        if (count($toDelete) === 0) {
            $this->info('No past single-date classes found.');
            return 0;
        }

        $this->info('Found ' . count($toDelete) . ' past class(es) to delete.');
        if ($this->option('dry-run')) {
            foreach ($toDelete as $id) {
                $this->line(" - $id");
            }
            $this->info('Dry run complete. No records deleted.');
            return 0;
        }

        $deleted = 0;
        foreach ($toDelete as $id) {
            try {
                DB::table('gym_classes')->where('id', $id)->delete();
                $deleted++;
            } catch (\Exception $e) {
                $this->error('Failed to delete id ' . $id . ': ' . $e->getMessage());
            }
        }

        $this->info("Deleted $deleted class(es).");
        return 0;
    }
}
