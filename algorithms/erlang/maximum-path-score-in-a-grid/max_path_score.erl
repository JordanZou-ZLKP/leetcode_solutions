-spec max_path_score(Grid :: [[integer()]], K :: integer()) -> integer().

max_path_score([Row0 | Rows], K) ->
    [_ | Row0Rest] = Row0,
    Row0Fronts = build_row0(Row0Rest, [{0, 0}], K, [[{0, 0}]]),
    LastRowFronts = lists:foldl(
        fun(Row, PrevRowFronts) ->
            build_row(Row, PrevRowFronts, [], K, [])
        end,
        Row0Fronts,
        Rows
    ),
    LastFront = lists:last(LastRowFronts),
    case LastFront of
        [] -> -1;
        _ ->
            {_, MaxScore} = lists:last(LastFront),
            MaxScore
    end.

build_row0([], _LeftFront, _K, Acc) ->
    lists:reverse(Acc);
build_row0([Cell | Cells], LeftFront, K, Acc) ->
    {DC, DS} = cv(Cell),
    OutFront = shift_front(LeftFront, DC, DS, K),
    build_row0(Cells, OutFront, K, [OutFront | Acc]).

build_row([], [], _LeftFront, _K, Acc) ->
    lists:reverse(Acc);
build_row([Cell | Cells], [UpFront | UpFronts], LeftFront, K, Acc) ->
    Merged = merge(UpFront, LeftFront, -1, []),
    {DC, DS} = cv(Cell),
    OutFront = shift_front(Merged, DC, DS, K),
    build_row(Cells, UpFronts, OutFront, K, [OutFront | Acc]).

cv(0) -> {0, 0};
cv(1) -> {1, 1};
cv(2) -> {1, 2}.

shift_front([], _DC, _DS, _K) ->
    [];
shift_front([{C, S} | T], DC, DS, K) ->
    NC = C + DC,
    if NC =< K ->
           [{NC, S + DS} | shift_front(T, DC, DS, K)];
       true ->
           []
    end.

merge([], F2, MaxS, Acc) ->
    append_rest(F2, MaxS, Acc);
merge(F1, [], MaxS, Acc) ->
    append_rest(F1, MaxS, Acc);
merge([{C1, S1} | T1] = F1, [{C2, S2} | T2] = F2, MaxS, Acc) ->
    if S1 =< MaxS -> merge(T1, F2, MaxS, Acc);
       S2 =< MaxS -> merge(F1, T2, MaxS, Acc);
       C1 < C2 -> merge(T1, F2, S1, [{C1, S1} | Acc]);
       C1 > C2 -> merge(F1, T2, S2, [{C2, S2} | Acc]);
       true ->
           if S1 >= S2 -> merge(T1, T2, S1, [{C1, S1} | Acc]);
              true -> merge(T1, T2, S2, [{C2, S2} | Acc])
           end
    end.

append_rest([], _MaxS, Acc) ->
    lists:reverse(Acc);
append_rest([{C, S} | T], MaxS, Acc) ->
    if S > MaxS -> append_rest(T, S, [{C, S} | Acc]);
       true -> append_rest(T, MaxS, Acc)
    end.