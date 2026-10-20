-spec sortable_integers(Nums :: [integer()]) -> integer().
sortable_integers(Nums) ->
    N = length(Nums),
    Divs = divisors(N, 1, []),
    lists:sum([K || K <- Divs, check_k(Nums, K, 0)]).

divisors(N, I, Acc) when I * I > N ->
    Acc;
divisors(N, I, Acc) when I * I == N ->
    [I | Acc];
divisors(N, I, Acc) ->
    case N rem I of
        0 -> divisors(N, I + 1, [I, N div I | Acc]);
        _ -> divisors(N, I + 1, Acc)
    end.

check_k([], _, _) ->
    true;
check_k([First | Rest], K, PrevMax) ->
    check_chunk(Rest, K - 1, K, First, First, First, First, 0, PrevMax).

check_chunk(List, 0, K, First, Prev, Min, Max, Drops, PrevMax) ->
    TotalDrops = case Prev > First of
        true -> Drops + 1;
        false -> Drops
    end,
    if
        TotalDrops > 1 -> false;
        PrevMax > Min -> false;
        true -> check_k(List, K, Max)
    end;
check_chunk([X | Rest], Rem, K, First, Prev, Min, Max, Drops, PrevMax) ->
    NewDrops = case Prev > X of
        true -> Drops + 1;
        false -> Drops
    end,
    NewMin = case X < Min of
        true -> X;
        false -> Min
    end,
    NewMax = case X > Max of
        true -> X;
        false -> Max
    end,
    check_chunk(Rest, Rem - 1, K, First, X, NewMin, NewMax, NewDrops, PrevMax).

