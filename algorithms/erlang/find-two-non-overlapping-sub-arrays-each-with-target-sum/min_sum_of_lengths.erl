-spec min_sum_of_lengths(Arr :: [integer()], Target :: integer()) -> integer().
min_sum_of_lengths(Arr, Target) ->
    Res = solve(Arr, Target, 1, 0, #{0 => 0}, #{0 => 1000000}, 1000000, 1000000),
    if Res >= 1000000 -> -1;
       true -> Res
    end.

solve([], _, _, _, _, _, _, GlobalMin) ->
    GlobalMin;
solve([X | T], Target, Index, Sum, SumMap, BestAt, PrevBest, GlobalMin) ->
    NewSum = Sum + X,
    NewSumMap = SumMap#{NewSum => Index},
    case maps:find(NewSum - Target, SumMap) of
        {ok, StartIdx} ->
            Len = Index - StartIdx,
            BestAtStart = maps:get(StartIdx, BestAt),
            NewGlobalMin = erlang:min(GlobalMin, Len + BestAtStart),
            CurrentBest = erlang:min(PrevBest, Len),
            NewBestAt = BestAt#{Index => CurrentBest},
            solve(T, Target, Index + 1, NewSum, NewSumMap, NewBestAt, CurrentBest, NewGlobalMin);
        error ->
            NewBestAt = BestAt#{Index => PrevBest},
            solve(T, Target, Index + 1, NewSum, NewSumMap, NewBestAt, PrevBest, GlobalMin)
    end.
