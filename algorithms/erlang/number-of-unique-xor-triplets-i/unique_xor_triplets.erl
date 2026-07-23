-spec unique_xor_triplets(Nums :: [integer()]) -> integer().
unique_xor_triplets(Nums) ->
    N = length(Nums),
    if
        N =:= 1 -> 1;
        N =:= 2 -> 2;
        true -> next_power_of_two(N, 1)
    end.

next_power_of_two(N, P) when P > N -> P;
next_power_of_two(N, P) -> next_power_of_two(N, P bsl 1).