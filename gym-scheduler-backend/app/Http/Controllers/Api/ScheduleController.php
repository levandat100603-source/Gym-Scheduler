<?php


namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\WorkoutSchedule;
use App\Models\Member;
use App\Events\ScheduleUpdated;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ScheduleController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        $member = $user->member;

        $schedules = WorkoutSchedule::with('trainer.user')
            ->where('member_id', $member->id)
            ->orderBy('start_time')
            ->get();

        return response()->json($schedules);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        $member = $user->member;

        $data = $request->validate([
            'trainer_id' => 'nullable|exists:trainers,id',
            'start_time' => 'required|date',
            'end_time'   => 'required|date|after:start_time',
            'title'      => 'nullable|string',
            'notes'      => 'nullable|string',
        ]);

        $schedule = WorkoutSchedule::create([
            'member_id'  => $member->id,
            'trainer_id' => $data['trainer_id'] ?? null,
            'start_time' => $data['start_time'],
            'end_time'   => $data['end_time'],
            'title'      => $data['title'] ?? null,
            'notes'      => $data['notes'] ?? null,
        ]);

        event(new ScheduleUpdated($schedule));

        return response()->json($schedule, 201);
    }

    public function update(Request $request, WorkoutSchedule $schedule)
    {
        $this->authorize('update', $schedule); 

        $data = $request->validate([
            'trainer_id' => 'nullable|exists:trainers,id',
            'start_time' => 'sometimes|date',
            'end_time'   => 'sometimes|date|after:start_time',
            'status'     => 'sometimes|string',
            'title'      => 'nullable|string',
            'notes'      => 'nullable|string',
        ]);

        $schedule->update($data);
        event(new ScheduleUpdated($schedule));

        return response()->json($schedule);
    }

    public function destroy(WorkoutSchedule $schedule)
    {
        $this->authorize('delete', $schedule);
        $schedule->delete();

        event(new ScheduleUpdated($schedule));

        return response()->json(['message' => 'Deleted']);
    }
}


