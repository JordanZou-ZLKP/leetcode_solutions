-spec sort_permutation(Nums :: [integer()]) -> integer().
sort_permutation(Nums) ->
    find_k(Nums, 0, -1).

find_k([], _Idx, -1) -> 
    0;
find_k([], _Idx, K) -> 
    K;
find_k([H | T], Idx, K) when H =/= Idx ->
    find_k(T, Idx + 1, K band H);
find_k([_ | T], Idx, K) ->
    find_k(T, Idx + 1, K).
