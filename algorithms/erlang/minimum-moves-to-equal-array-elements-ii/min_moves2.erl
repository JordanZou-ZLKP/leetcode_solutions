-spec min_moves2(Nums :: [integer()]) -> integer().
min_moves2(Nums) ->
    Sorted = lists:sort(Nums),
    N = length(Sorted),
    Median = lists:nth(N div 2 + 1, Sorted),
    lists:foldl(fun(X, Acc) -> Acc + abs(X - Median) end, 0, Sorted).

