-spec angle_clock(Hour :: integer(), Minutes :: integer()) -> float().
angle_clock(Hour, Minutes) ->
    Diff = abs((Hour rem 12) * 30 - Minutes * 5.5),
    min(Diff, 360.0 - Diff).