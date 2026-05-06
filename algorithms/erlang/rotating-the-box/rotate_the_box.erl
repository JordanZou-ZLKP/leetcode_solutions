-spec rotate_the_box(BoxGrid :: [[char()]]) -> [[char()]].
rotate_the_box(BoxGrid) ->
    Gravitated = [apply_gravity(Row) || Row <- BoxGrid],
    transpose(lists:reverse(Gravitated)).

apply_gravity(Row) ->
    Segments = split_star(Row, 0, 0, []),
    Processed = [lists:duplicate(Len - Stones, $.) ++ lists:duplicate(Stones, $#) || {Len, Stones} <- Segments],
    join_star(Processed).

split_star([], Len, Stones, Acc) -> lists:reverse([{Len, Stones} | Acc]);
split_star([$* | T], Len, Stones, Acc) -> split_star(T, 0, 0, [{Len, Stones} | Acc]);
split_star([$# | T], Len, Stones, Acc) -> split_star(T, Len + 1, Stones + 1, Acc);
split_star([_ | T], Len, Stones, Acc) -> split_star(T, Len + 1, Stones, Acc).

join_star([]) -> [];
join_star([H]) -> H;
join_star([H | T]) -> H ++ [$* | join_star(T)].

transpose([]) -> [];
transpose([[] | _]) -> [];
transpose(Matrix) ->
    [[hd(Row) || Row <- Matrix] | transpose([tl(Row) || Row <- Matrix])].