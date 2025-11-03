-spec min_cost(Colors :: unicode:unicode_binary(), NeededTime :: [integer()]) -> integer().
min_cost(Colors, NeededTime) ->
    mmin_cost(binary_to_list(Colors), NeededTime).

mmin_cost([], []) ->
    0;
mmin_cost([H|T_colors], [H_time|T_time]) ->
    mmin_cost(T_colors, T_time, H, H_time, H_time, 0).

mmin_cost([], [], _PrevColor, MaxTime, SumTime, Ans) ->
    Ans + SumTime - MaxTime;

mmin_cost([C|T_colors], [T|T_time], PrevColor, MaxTime, SumTime, Ans) ->
    case C =/= PrevColor of
        true ->
            NewAns = Ans + SumTime - MaxTime,
            mmin_cost(T_colors, T_time, C, T, T, NewAns);
        false ->
            NewMaxTime = erlang:max(MaxTime, T),
            NewSumTime = SumTime + T,
            mmin_cost(T_colors, T_time, C, NewMaxTime, NewSumTime, Ans)
    end.