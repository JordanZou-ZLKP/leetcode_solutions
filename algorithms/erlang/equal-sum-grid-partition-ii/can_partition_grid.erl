-spec can_partition_grid(Grid :: [[integer()]]) -> boolean().
can_partition_grid(Grid) ->
    M = length(Grid),
    N = length(hd(Grid)),
    GridT = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),

    RowSums = list_to_tuple([lists:sum(Row) || Row <- Grid]),
    InitCols = [0 || _ <- lists:seq(1, N)],
    ColSumsList = lists:foldl(
        fun(Row, Acc) -> lists:zipwith(fun erlang:'+'/2, Row, Acc) end,
        InitCols,
        Grid
    ),
    ColSums = list_to_tuple(ColSumsList),
    TotalSum = lists:sum(ColSumsList),

    Stats = build_stats(Grid, 0, #{}),

    case check_horizontal(0, M, N, RowSums, TotalSum, 0, GridT, Stats) of
        true -> true;
        false -> check_vertical(0, M, N, ColSums, TotalSum, 0, GridT, Stats)
    end.

build_stats([], _, Map) -> Map;
build_stats([Row | Rest], R, Map) ->
    NewMap = build_stats_row(Row, R, 0, Map),
    build_stats(Rest, R+1, NewMap).

build_stats_row([], _, _, Map) -> Map;
build_stats_row([V | Rest], R, C, Map) ->
    NewMap = maps:update_with(V,
        fun({MinR, MaxR, MinC, MaxC}) ->
            {erlang:min(MinR, R), erlang:max(MaxR, R), erlang:min(MinC, C), erlang:max(MaxC, C)}
        end,
        {R, R, C, C},
        Map),
    build_stats_row(Rest, R, C+1, NewMap).

check_horizontal(I, M, N, RowSums, TotalSum, TopSumAcc, GridT, Stats) when I < M - 1 ->
    TopSum = TopSumAcc + element(I+1, RowSums),
    BotSum = TotalSum - TopSum,
    D = TopSum - BotSum,

    Found = if
        D == 0 -> true;
        D > 0 ->
            R1 = I + 1,
            Rstr = ((R1 == 1) andalso (N >= 3)) orelse ((N == 1) andalso (R1 >= 3)),
            if
                Rstr ->
                    V1 = element(1, element(1, GridT)),
                    V2 = element(N, element(I+1, GridT)),
                    (V1 == D) orelse (V2 == D);
                true ->
                    case maps:find(D, Stats) of
                        {ok, {MinR, _, _, _}} -> MinR =< I;
                        error -> false
                    end
            end;
        D < 0 ->
            Target = -D,
            R2 = M - 1 - I,
            Rstr = ((R2 == 1) andalso (N >= 3)) orelse ((N == 1) andalso (R2 >= 3)),
            if
                Rstr ->
                    V1 = element(1, element(I+2, GridT)),
                    V2 = element(N, element(M, GridT)),
                    (V1 == Target) orelse (V2 == Target);
                true ->
                    case maps:find(Target, Stats) of
                        {ok, {_, MaxR, _, _}} -> MaxR > I;
                        error -> false
                    end
            end
    end,

    case Found of
        true -> true;
        false -> check_horizontal(I+1, M, N, RowSums, TotalSum, TopSum, GridT, Stats)
    end;
check_horizontal(_, _, _, _, _, _, _, _) -> false.

check_vertical(J, M, N, ColSums, TotalSum, LeftSumAcc, GridT, Stats) when J < N - 1 ->
    LeftSum = LeftSumAcc + element(J+1, ColSums),
    RightSum = TotalSum - LeftSum,
    D = LeftSum - RightSum,

    Found = if
        D == 0 -> true;
        D > 0 ->
            C1 = J + 1,
            Rstr = ((M == 1) andalso (C1 >= 3)) orelse ((C1 == 1) andalso (M >= 3)),
            if
                Rstr ->
                    V1 = element(1, element(1, GridT)),
                    V2 = element(J+1, element(M, GridT)),
                    (V1 == D) orelse (V2 == D);
                true ->
                    case maps:find(D, Stats) of
                        {ok, {_, _, MinC, _}} -> MinC =< J;
                        error -> false
                    end
            end;
        D < 0 ->
            Target = -D,
            C2 = N - 1 - J,
            Rstr = ((M == 1) andalso (C2 >= 3)) orelse ((C2 == 1) andalso (M >= 3)),
            if
                Rstr ->
                    V1 = element(J+2, element(1, GridT)),
                    V2 = element(N, element(M, GridT)),
                    (V1 == Target) orelse (V2 == Target);
                true ->
                    case maps:find(Target, Stats) of
                        {ok, {_, _, _, MaxC}} -> MaxC > J;
                        error -> false
                    end
            end
    end,

    case Found of
        true -> true;
        false -> check_vertical(J+1, M, N, ColSums, TotalSum, LeftSum, GridT, Stats)
    end;
check_vertical(_, _, _, _, _, _, _, _) -> false.