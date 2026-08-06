-spec find_missing_elements(Nums :: [integer()]) -> [integer()].
find_missing_elements([H | T]) ->
    {Min, Max, Map} = lists:foldl(
        fun(X, {AccMin, AccMax, AccMap}) ->
            {min(X, AccMin), max(X, AccMax), maps:put(X, true, AccMap)}
        end,
        {H, H, maps:put(H, true, #{})},
        T
    ),
    [X || X <- lists:seq(Min, Max), not maps:is_key(X, Map)].