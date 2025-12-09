-spec count_partitions(Nums :: [integer()], K :: integer()) -> integer().

count_partitions(Nums, K) ->
    N = length(Nums),
    NumsTuple = list_to_tuple(Nums),
    PrefArr = array:new(N + 1, {default, 0}),
    PrefArr1 = array:set(0, 1, PrefArr),
    solve(0, 0, N, NumsTuple, K, queue:new(), queue:new(), PrefArr1).

solve(J, _I, N, _Nums, _K, _MaxQ, _MinQ, Pref) when J == N ->
    Val = (array:get(N, Pref) - array:get(N - 1, Pref)) rem 1000000007,
    if Val < 0 -> Val + 1000000007; true -> Val end;

solve(J, I, N, Nums, K, MaxQ, MinQ, Pref) ->
    Val = element(J + 1, Nums),
    MaxQ1 = update_max_q(MaxQ, Val, Nums, J),
    MinQ1 = update_min_q(MinQ, Val, Nums, J),
    
    {NextI, MaxQ2, MinQ2} = adjust_window(I, MaxQ1, MinQ1, Nums, K),
    
    Sub = if NextI > 0 -> array:get(NextI - 1, Pref); true -> 0 end,
    CurrentPref = array:get(J, Pref),
    
    DpVal = (CurrentPref - Sub) rem 1000000007,
    DpValFinal = if DpVal < 0 -> DpVal + 1000000007; true -> DpVal end,
    
    NextPrefVal = (CurrentPref + DpValFinal) rem 1000000007,
    PrefNext = array:set(J + 1, NextPrefVal, Pref),
    
    solve(J + 1, NextI, N, Nums, K, MaxQ2, MinQ2, PrefNext).

update_max_q(Q, Val, Nums, Idx) ->
    case queue:out_r(Q) of
        {{value, BackIdx}, QRest} ->
            BackVal = element(BackIdx + 1, Nums),
            if Val > BackVal -> update_max_q(QRest, Val, Nums, Idx);
               true -> queue:in(Idx, Q)
            end;
        {empty, _} -> queue:in(Idx, Q)
    end.

update_min_q(Q, Val, Nums, Idx) ->
    case queue:out_r(Q) of
        {{value, BackIdx}, QRest} ->
            BackVal = element(BackIdx + 1, Nums),
            if Val < BackVal -> update_min_q(QRest, Val, Nums, Idx);
               true -> queue:in(Idx, Q)
            end;
        {empty, _} -> queue:in(Idx, Q)
    end.

adjust_window(I, MaxQ, MinQ, Nums, K) ->
    {value, MaxIdx} = queue:peek(MaxQ),
    {value, MinIdx} = queue:peek(MinQ),
    MaxVal = element(MaxIdx + 1, Nums),
    MinVal = element(MinIdx + 1, Nums),
    
    if (MaxVal - MinVal) > K ->
        NewI = I + 1,
        MaxQ2 = pop_front_if_stale(MaxQ, NewI),
        MinQ2 = pop_front_if_stale(MinQ, NewI),
        adjust_window(NewI, MaxQ2, MinQ2, Nums, K);
    true ->
        {I, MaxQ, MinQ}
    end.

pop_front_if_stale(Q, Limit) ->
    case queue:peek(Q) of
        {value, Idx} when Idx < Limit -> 
            {_, Q2} = queue:out(Q),
            Q2;
        _ -> Q
    end.