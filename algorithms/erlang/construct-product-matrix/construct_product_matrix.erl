-spec construct_product_matrix(Grid :: [[integer()]]) -> [[integer()]].
construct_product_matrix(Grid) ->
    Flat = lists:flatten(Grid),
    {Prefixes, _} = lists:mapfoldl(fun(X, Acc) -> 
        {Acc, (Acc * (X rem 12345)) rem 12345} 
    end, 1, Flat),
    {RevSuffixes, _} = lists:mapfoldl(fun(X, Acc) -> 
        {Acc, (Acc * (X rem 12345)) rem 12345} 
    end, 1, lists:reverse(Flat)),
    Suffixes = lists:reverse(RevSuffixes),
    ResFlat = lists:zipwith(fun(P, S) -> 
        (P * S) rem 12345 
    end, Prefixes, Suffixes),
    rebuild(Grid, ResFlat).

rebuild([], []) ->
    [];
rebuild([Row | RestGrid], FlatRes) ->
    {RowRes, RestFlatRes} = lists:split(length(Row), FlatRes),
    [RowRes | rebuild(RestGrid, RestFlatRes)].