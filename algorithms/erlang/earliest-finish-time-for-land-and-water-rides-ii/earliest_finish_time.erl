-spec earliest_finish_time(LandStartTime :: [integer()], LandDuration :: [integer()], WaterStartTime :: [integer()], WaterDuration :: [integer()]) -> integer().
earliest_finish_time(LandStartTime, LandDuration, WaterStartTime, WaterDuration) ->
    MinLE = min_end(LandStartTime, LandDuration),
    MinWE = min_end(WaterStartTime, WaterDuration),
    Res1 = calc_min_finish(MinLE, WaterStartTime, WaterDuration),
    Res2 = calc_min_finish(MinWE, LandStartTime, LandDuration),
    min(Res1, Res2).

min_end([S | Ss], [D | Ds]) ->
    min_end(Ss, Ds, S + D).

min_end([], [], Acc) ->
    Acc;
min_end([S | Ss], [D | Ds], Acc) ->
    min_end(Ss, Ds, min(Acc, S + D)).

calc_min_finish(MinFirst, [S | Ss], [D | Ds]) ->
    calc_min_finish(MinFirst, Ss, Ds, max(MinFirst + D, S + D)).

calc_min_finish(_MinFirst, [], [], Acc) ->
    Acc;
calc_min_finish(MinFirst, [S | Ss], [D | Ds], Acc) ->
    calc_min_finish(MinFirst, Ss, Ds, min(Acc, max(MinFirst + D, S + D))).