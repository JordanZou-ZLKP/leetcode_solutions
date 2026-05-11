-spec separate_digits(Nums :: [integer()]) -> [integer()].
separate_digits(Nums) ->
    separate(lists:reverse(Nums), []).

separate([], Acc) ->
    Acc;
separate([H | T], Acc) ->
    separate(T, extract(H, Acc)).

extract(0, Acc) ->
    Acc;
extract(N, Acc) ->
    extract(N div 10, [N rem 10 | Acc]).