-spec min_moves(Nums :: [integer()]) -> integer().
min_moves(Nums) ->
    Min = lists:min(Nums),
    Sum = lists:sum(Nums),
    N = length(Nums),
    Sum - Min * N.

