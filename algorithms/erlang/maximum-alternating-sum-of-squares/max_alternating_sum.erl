-spec max_alternating_sum(Nums :: [integer()]) -> integer().
max_alternating_sum(Nums) ->
    N = length(Nums),
    PosCount = (N + 1) div 2,
    Squares = lists:reverse(lists:sort([X * X || X <- Nums])),
    {Pos, Neg} = lists:split(PosCount, Squares),
    lists:sum(Pos) - lists:sum(Neg).
