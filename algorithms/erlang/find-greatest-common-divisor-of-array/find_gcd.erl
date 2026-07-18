-spec find_gcd(Nums :: [integer()]) -> integer().
find_gcd([H | T]) ->
    {Min, Max} = find_min_max(T, H, H),
    gcd(Max, Min).

find_min_max([], Min, Max) ->
    {Min, Max};
find_min_max([H | T], Min, Max) when H < Min ->
    find_min_max(T, H, Max);
find_min_max([H | T], Min, Max) when H > Max ->
    find_min_max(T, Min, H);
find_min_max([_ | T], Min, Max) ->
    find_min_max(T, Min, Max).

gcd(A, 0) -> 
    A;
gcd(A, B) -> 
    gcd(B, A rem B).