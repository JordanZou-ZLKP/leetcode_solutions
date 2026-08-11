-spec missing_integer(Nums :: [integer()]) -> integer().
missing_integer(Nums) ->
    Sum = prefix_sum(Nums),
    Set = sets:from_list(Nums),
    find_missing(Sum, Set).

prefix_sum([H | T]) ->
    prefix_sum(T, H, H).

prefix_sum([H | T], Prev, Sum) when H =:= Prev + 1 ->
    prefix_sum(T, H, Sum + H);
prefix_sum(_, _, Sum) ->
    Sum.

find_missing(X, Set) ->
    case sets:is_element(X, Set) of
        true -> 
            find_missing(X + 1, Set);
        false -> 
            X
    end.