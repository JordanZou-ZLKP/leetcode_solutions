-spec earliest_finish_time(LandStartTime :: [integer()], LandDuration :: [integer()], WaterStartTime :: [integer()], WaterDuration :: [integer()]) -> integer().
earliest_finish_time(LandStartTime, LandDuration, WaterStartTime, WaterDuration) ->
    MinLE = min_end(LandStartTime, LandDuration, infinity),
    MinWE = min_end(WaterStartTime, WaterDuration, infinity),
    Ans1 = min_fin(MinLE, WaterStartTime, WaterDuration, infinity),
    Ans2 = min_fin(MinWE, LandStartTime, LandDuration, infinity),
    erlang:min(Ans1, Ans2).

min_end([], [], Min) -> 
    Min;
min_end([S | ST], [D | DT], Min) -> 
    min_end(ST, DT, erlang:min(Min, S + D)).

min_fin(_, [], [], Min) -> 
    Min;
min_fin(FirstEnd, [S | ST], [D | DT], Min) -> 
    min_fin(FirstEnd, ST, DT, erlang:min(Min, erlang:max(FirstEnd, S) + D)).