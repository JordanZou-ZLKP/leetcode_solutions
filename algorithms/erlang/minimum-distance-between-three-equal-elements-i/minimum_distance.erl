-spec minimum_distance(Nums :: [integer()]) -> integer().
minimum_distance(Nums) ->
    Map = build(Nums, 0, #{}),
    case maps:fold(fun(_, L, Acc) -> search(L, Acc) end, infinity, Map) of
        infinity -> -1;
        Ans -> Ans
    end.

build([], _, Map) -> 
    Map;
build([H | T], Idx, Map) ->
    build(T, Idx + 1, maps:update_with(H, fun(L) -> [Idx | L] end, [Idx], Map)).

search([A, B, C | T], Acc) ->
    search([B, C | T], min(Acc, 2 * (A - C)));
search(_, Acc) ->
    Acc.