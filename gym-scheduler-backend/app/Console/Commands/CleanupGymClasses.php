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
    protected $description = 'Delete past or legacy date-based gym classes so only today and future classes remain.';

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

    public function handle()
    {
        $today = Carbon::now()->startOfDay();

        $rows = DB::table('gym_classes')->get();
        $toDelete = [];

        foreach ($rows as $r) {
            $classDate = $this->parseClassDate($r->days ?? null);
            if (!$classDate) {
                // Legacy weekday-based rows are removed during the migration to date-only classes.
                $toDelete[] = $r->id;
                continue;
            }

            if ($classDate->lt($today)) {
                $toDelete[] = $r->id;
            }
        }

        if (count($toDelete) === 0) {
            $this->info('No past or legacy classes found.');
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
