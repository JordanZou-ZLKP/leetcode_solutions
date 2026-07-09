-spec path_existence_queries(N :: integer(), Nums :: [integer()], MaxDiff :: integer(), Queries :: [[integer()]]) -> [boolean()].
path_existence_queries(_N, [H | T], MaxDiff, Queries) ->
    CompTuple = build_components(T, H, MaxDiff, 0, [0]),
    [element(U + 1, CompTuple) =:= element(V + 1, CompTuple) || [U, V] <- Queries].

build_components([], _Prev, _MaxDiff, _CurrentComp, Acc) ->
    list_to_tuple(lists:reverse(Acc));
build_components([H | T], Prev, MaxDiff, CurrentComp, Acc) ->
    NextComp = case H - Prev =< MaxDiff of
        true -> CurrentComp;
        false -> CurrentComp + 1
    end,
    build_components(T, H, MaxDiff, NextComp, [NextComp | Acc]).