-spec max_total_value(Nums :: [integer()], K :: integer()) -> integer().
max_total_value(Nums, K) ->
    N = length(Nums),
    T0 = erlang:list_to_tuple(Nums),
    MaxKLevel = trunc(math:log2(N)),
    ST_Min = erlang:list_to_tuple([T0 | build_st_levels(T0, N, 1, MaxKLevel, fun erlang:min/2)]),
    ST_Max = erlang:list_to_tuple([T0 | build_st_levels(T0, N, 1, MaxKLevel, fun erlang:max/2)]),
    LogTuple = erlang:list_to_tuple([trunc(math:log2(I)) || I <- lists:seq(1, N)]),
    Val = query_st(ST_Min, ST_Max, LogTuple, 1, N),
    PQ = gb_sets:singleton({-Val, 1, N}),
    Visited = #{{1, N} => true},
    loop(K, PQ, Visited, ST_Min, ST_Max, LogTuple, 0).

build_st_levels(_Prev, _N, K, MaxKLevel, _Op) when K > MaxKLevel ->
    [];
build_st_levels(Prev, N, K, MaxKLevel, Op) ->
    Half = 1 bsl (K - 1),
    Size = N - (Half bsl 1) + 1,
    L_list = [Op(element(I, Prev), element(I + Half, Prev)) || I <- lists:seq(1, Size)],
    Curr = erlang:list_to_tuple(L_list),
    [Curr | build_st_levels(Curr, N, K + 1, MaxKLevel, Op)].

query_st(ST_Min, ST_Max, LogTuple, L, R) ->
    Len = R - L + 1,
    KLevel = element(Len, LogTuple),
    LevelMin = element(KLevel + 1, ST_Min),
    LevelMax = element(KLevel + 1, ST_Max),
    Half = 1 bsl KLevel,
    Min = erlang:min(element(L, LevelMin), element(R - Half + 1, LevelMin)),
    Max = erlang:max(element(L, LevelMax), element(R - Half + 1, LevelMax)),
    Max - Min.

loop(0, _PQ, _Visited, _ST_Min, _ST_Max, _LogTuple, Sum) ->
    Sum;
loop(K, PQ, Visited, ST_Min, ST_Max, LogTuple, Sum) ->
    {{NegVal, L, R}, PQ1} = gb_sets:take_smallest(PQ),
    Sum1 = Sum - NegVal,
    {PQ2, Visited2} = if
        L + 1 =< R ->
            case maps:is_key({L + 1, R}, Visited) of
                false ->
                    Val1 = query_st(ST_Min, ST_Max, LogTuple, L + 1, R),
                    {gb_sets:add({-Val1, L + 1, R}, PQ1), Visited#{{L + 1, R} => true}};
                true ->
                    {PQ1, Visited}
            end;
        true ->
            {PQ1, Visited}
    end,
    {PQ3, Visited3} = if
        L =< R - 1 ->
            case maps:is_key({L, R - 1}, Visited2) of
                false ->
                    Val2 = query_st(ST_Min, ST_Max, LogTuple, L, R - 1),
                    {gb_sets:add({-Val2, L, R - 1}, PQ2), Visited2#{{L, R - 1} => true}};
                true ->
                    {PQ2, Visited2}
            end;
        true ->
            {PQ2, Visited2}
    end,
    loop(K - 1, PQ3, Visited3, ST_Min, ST_Max, LogTuple, Sum1).