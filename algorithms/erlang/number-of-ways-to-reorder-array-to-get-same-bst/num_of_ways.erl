-spec num_of_ways(Nums :: [integer()]) -> integer().
num_of_ways(Nums) ->
    N = length(Nums),
    FacList = fac_list(N, 1, 1, [1]),
    Fac = list_to_tuple(FacList),
    InvFac = list_to_tuple([mod_pow(X, 1000000007 - 2) || X <- FacList]),
    (dfs(Nums, Fac, InvFac) + 1000000007 - 1) rem 1000000007.

fac_list(0, _I, _Curr, Acc) -> 
    lists:reverse(Acc);
fac_list(K, I, Curr, Acc) ->
    Next = (Curr * I) rem 1000000007,
    fac_list(K - 1, I + 1, Next, [Next | Acc]).

mod_pow(_B, 0) -> 
    1;
mod_pow(B, E) ->
    Half = mod_pow(B, E div 2),
    Half2 = (Half * Half) rem 1000000007,
    case E rem 2 of
        0 -> Half2;
        1 -> (Half2 * B) rem 1000000007
    end.

dfs([], _Fac, _InvFac) -> 
    1;
dfs([_], _Fac, _InvFac) -> 
    1;
dfs([Root | Rest], Fac, InvFac) ->
    {Left, Right} = lists:partition(fun(X) -> X < Root end, Rest),
    LenL = length(Left),
    LenR = length(Right),
    WaysL = dfs(Left, Fac, InvFac),
    WaysR = dfs(Right, Fac, InvFac),
    C = comb(LenL + LenR, LenL, Fac, InvFac),
    (C * WaysL * WaysR) rem 1000000007.

comb(N, K, Fac, InvFac) ->
    Fn = element(N + 1, Fac),
    Ik = element(K + 1, InvFac),
    Ink = element(N - K + 1, InvFac),
    (((Fn * Ik) rem 1000000007) * Ink) rem 1000000007.

