-spec subsequence_pair_count(Nums :: [integer()]) -> integer().
subsequence_pair_count(Nums) ->
    Map = #{ {0, 0} => 1 },
    FinalMap = lists:foldl(fun step/2, Map, Nums),
    maps:fold(fun
        ({G, G}, Count, Acc) when G > 0 -> (Acc + Count) rem 1000000007;
        (_, _, Acc) -> Acc
    end, 0, FinalMap).

step(X, Map) ->
    maps:fold(fun({G1, G2}, Count, Acc) ->
        NG1 = gcd(G1, X),
        NG2 = gcd(G2, X),
        Acc1 = Acc#{ {NG1, G2} => (maps:get({NG1, G2}, Acc, 0) + Count) rem 1000000007 },
        Acc1#{ {G1, NG2} => (maps:get({G1, NG2}, Acc1, 0) + Count) rem 1000000007 }
    end, Map, Map).

gcd(0, X) -> X;
gcd(X, 0) -> X;
gcd(A, B) -> gcd_calc(A, B).

gcd_calc(A, 0) -> A;
gcd_calc(A, B) -> gcd_calc(B, A rem B).