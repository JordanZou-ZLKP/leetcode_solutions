-spec min_number_of_seconds(MountainHeight :: integer(), WorkerTimes :: [integer()]) -> integer().
min_number_of_seconds(MountainHeight, WorkerTimes) ->
    MinW = lists:min(WorkerTimes),
    High = MinW * MountainHeight * (MountainHeight + 1) div 2,
    bs(1, High, MountainHeight, WorkerTimes).

bs(Low, High, _, _) when Low > High ->
    Low;
bs(Low, High, Target, WorkerTimes) ->
    Mid = Low + (High - Low) div 2,
    case can_reduce(WorkerTimes, Mid, Target, 0) of
        true -> bs(Low, Mid - 1, Target, WorkerTimes);
        false -> bs(Mid + 1, High, Target, WorkerTimes)
    end.

can_reduce(_, _, Target, Acc) when Acc >= Target ->
    true;
can_reduce([], _, Target, Acc) ->
    Acc >= Target;
can_reduce([W | Rest], Mid, Target, Acc) ->
    Val = (isqrt(1 + 8 * (Mid div W)) - 1) div 2,
    can_reduce(Rest, Mid, Target, Acc + Val).

isqrt(0) -> 0;
isqrt(N) ->
    isqrt_refine(N, trunc(math:sqrt(N))).

isqrt_refine(N, X) ->
    if
        X * X > N -> isqrt_refine(N, X - 1);
        (X + 1) * (X + 1) =< N -> isqrt_refine(N, X + 1);
        true -> X
    end.