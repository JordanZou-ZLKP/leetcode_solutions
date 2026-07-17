-spec gcd_sum(Nums :: [integer()]) -> integer().
gcd_sum(Nums) ->
    PrefixGcd = build_prefix(Nums, 0, []),
    Sorted = lists:sort(PrefixGcd),
    Len = length(Sorted),
    Half = Len div 2,
    {Front, Rest} = lists:split(Half, Sorted),
    BackReversed = lists:reverse(Rest),
    sum_pairs(Front, BackReversed, 0).

build_prefix([], _Max, Acc) ->
    lists:reverse(Acc);
build_prefix([H | T], Max, Acc) ->
    NewMax = max(H, Max),
    G = gcd(H, NewMax),
    build_prefix(T, NewMax, [G | Acc]).

sum_pairs([], _, Sum) ->
    Sum;
sum_pairs(_, [], Sum) ->
    Sum;
sum_pairs([H1 | T1], [H2 | T2], Sum) ->
    sum_pairs(T1, T2, Sum + gcd(H1, H2)).

gcd(A, 0) ->
    A;
gcd(A, B) ->
    gcd(B, A rem B).