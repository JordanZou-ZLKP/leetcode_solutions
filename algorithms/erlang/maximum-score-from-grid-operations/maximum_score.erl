-spec maximum_score(Grid :: [[integer()]]) -> integer().
maximum_score(Grid) ->
    N = length(Grid),
    Cols = [[lists:nth(C, Row) || Row <- Grid] || C <- lists:seq(1, N)],
    ColPTuples = [
        begin
            {Prefixes, _} = lists:mapfoldl(fun(X, Acc) -> {Acc + X, Acc + X} end, 0, Col),
            list_to_tuple([0 | Prefixes])
        end
        || Col <- Cols
    ],
    InitStateList = [
        list_to_tuple([
            if J == 0 -> 0; true -> -1000000000000000000 end
            || J <- lists:seq(0, N)
        ])
        || _K <- lists:seq(0, N)
    ],
    InitState = list_to_tuple(InitStateList),
    FinalState = lists:foldl(
        fun(ColP, State) ->
            step(State, ColP, N)
        end,
        InitState,
        ColPTuples
    ),
    lists:max(tuple_to_list(element(1, FinalState))).

step(State, ColP, N) ->
    K_rows = [
        begin
            ColDP_tuple = element(K + 1, State),
            P_K = element(K + 1, ColP),
            V1_list = tuple_to_list(ColDP_tuple),
            Pref_list = compute_pref(V1_list, -1000000000000000000),
            V2_list = [
                case element(J + 1, ColDP_tuple) of
                    -1000000000000000000 -> -1000000000000000000;
                    Val -> Val + max(0, element(J + 1, ColP) - P_K)
                end
                || J <- lists:seq(0, N)
            ],
            Suff_list = compute_suff(V2_list),
            [
                begin
                    Val1 = case lists:nth(L + 1, Pref_list) of
                        -1000000000000000000 -> -1000000000000000000;
                        PV -> PV + max(0, element(L + 1, ColP) - P_K)
                    end,
                    Val2 = if L < N -> lists:nth(L + 2, Suff_list); true -> -1000000000000000000 end,
                    max(Val1, Val2)
                end
                || L <- lists:seq(0, N)
            ]
        end
        || K <- lists:seq(0, N)
    ],
    Transposed = [[lists:nth(L + 1, Row) || Row <- K_rows] || L <- lists:seq(0, N)],
    list_to_tuple([list_to_tuple(Row) || Row <- Transposed]).

compute_pref([], _Max) -> [];
compute_pref([H|T], Max) ->
    NewMax = if H > Max -> H; true -> Max end,
    [NewMax | compute_pref(T, NewMax)].

compute_suff(L) ->
    lists:reverse(compute_pref(lists:reverse(L), -1000000000000000000)).