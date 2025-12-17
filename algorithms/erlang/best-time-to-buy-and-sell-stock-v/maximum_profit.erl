-spec maximum_profit(Prices :: [integer()], K :: integer()) -> integer().

-define(INF, -10000000000000000000).

maximum_profit(Prices, K) ->
    N = length(Prices),
    if
        N == 0 -> 0;
        true ->
            Arr = array:from_list(Prices),
            Dp = array:new(K + 1, {default, {?INF, ?INF, ?INF}}),
            Price0 = array:get(0, Arr),
            Dp0 = array:set(0, {0, -Price0, Price0}, Dp),
            DpFinal = lists:foldl(fun(I, DpAcc) ->
                P = array:get(I, Arr),
                NewDp = array:new(K + 1, {default, {?INF, ?INF, ?INF}}),
                NewDp1 = array:foldl(fun(J, StateJ, Acc) ->
                    {S0_prev, S1_prev, S2_prev} = StateJ,
                    NewS0 = S0_prev,
                    NewS1 = max(S1_prev, S0_prev - P),
                    NewS2 = max(S2_prev, S0_prev + P),
                    array:set(J, {NewS0, NewS1, NewS2}, Acc)
                end, NewDp, DpAcc),
                NewDp2 = lists:foldl(fun(J, Acc) ->
                    if
                        J < K ->
                            {S0_prev, S1_prev, S2_prev} = array:get(J, DpAcc),
                            Candidate = max(S1_prev + P, S2_prev - P),
                            {CurS0, CurS1, CurS2} = array:get(J + 1, Acc),
                            NewS0_j1 = max(CurS0, Candidate),
                            array:set(J + 1, {NewS0_j1, CurS1, CurS2}, Acc);
                        true ->
                            Acc
                    end
                end, NewDp1, lists:seq(0, K - 1)),
                NewDp2
            end, Dp0, lists:seq(1, N - 1)),
            MaxProfit = array:foldl(fun(_, {S0, _, _}, Acc) ->
                max(S0, Acc)
            end, ?INF, DpFinal),
            MaxProfit
    end.