-spec result_array(Nums :: [integer()], K :: integer()) -> [integer()].
result_array(Nums, K) ->
    InitTuple = erlang:make_tuple(K, 0),
    {TotalTuple, _} = lists:foldl(
        fun(X, {AccTotal, AccDP}) ->
            V = X rem K,
            BaseDP = setelement(V + 1, InitTuple, 1),
            NextDP = update_dp(AccDP, BaseDP, V, K, 1),
            NextTotal = add_tuples(AccTotal, NextDP, K, 1),
            {NextTotal, NextDP}
        end,
        {InitTuple, InitTuple},
        Nums
    ),
    erlang:tuple_to_list(TotalTuple).

update_dp(_AccDP, NextDP, _V, K, Idx) when Idx > K ->
    NextDP;
update_dp(AccDP, NextDP, V, K, Idx) ->
    Count = element(Idx, AccDP),
    case Count > 0 of
        true ->
            OldV = Idx - 1,
            NewV = (OldV * V) rem K,
            NewIdx = NewV + 1,
            CurrentVal = element(NewIdx, NextDP),
            NextDP2 = setelement(NewIdx, NextDP, CurrentVal + Count),
            update_dp(AccDP, NextDP2, V, K, Idx + 1);
        false ->
            update_dp(AccDP, NextDP, V, K, Idx + 1)
    end.

add_tuples(T1, _T2, K, Idx) when Idx > K ->
    T1;
add_tuples(T1, T2, K, Idx) ->
    V1 = element(Idx, T1),
    V2 = element(Idx, T2),
    add_tuples(setelement(Idx, T1, V1 + V2), T2, K, Idx + 1).

