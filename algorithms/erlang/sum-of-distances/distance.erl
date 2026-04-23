-spec distance(Nums :: [integer()]) -> [integer()].
distance(Nums) ->
    Indexed = index_nums(Nums, 0, []),
    Groups = lists:foldl(
        fun({I, V}, Acc) ->
            maps:update_with(V, fun(L) -> [I | L] end, [I], Acc)
        end,
        #{},
        Indexed
    ),
    Pairs = maps:fold(
        fun(_, Indices, Acc) ->
            TotalSum = lists:sum(Indices),
            TotalCount = length(Indices),
            {_, _, GroupPairs} = lists:foldl(
                fun(Idx, {LC, LS, ResAcc}) ->
                    RC = TotalCount - LC,
                    RS = TotalSum - LS,
                    Val = (Idx * LC - LS) + (RS - Idx * RC),
                    {LC + 1, LS + Idx, [{Idx, Val} | ResAcc]}
                end,
                {0, 0, Acc},
                Indices
            ),
            GroupPairs
        end,
        [],
        Groups
    ),
    [Val || {_, Val} <- lists:keysort(1, Pairs)].

index_nums([], _, Acc) -> 
    Acc;
index_nums([H | T], I, Acc) -> 
    index_nums(T, I + 1, [{I, H} | Acc]).