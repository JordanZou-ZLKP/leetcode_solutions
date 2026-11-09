-spec count_servers(Grid :: [[integer()]]) -> integer().
count_servers(Grid) ->
    {RowMap, ColMap, Servers} = parse_grid(Grid, 0, #{}, #{}, []),
    count_valid(Servers, RowMap, ColMap, 0).

parse_grid([], _R, RowMap, ColMap, Servers) ->
    {RowMap, ColMap, Servers};
parse_grid([Row | Rest], R, RowMap, ColMap, Servers) ->
    {NewRowMap, NewColMap, NewServers} = parse_row(Row, R, 0, RowMap, ColMap, Servers),
    parse_grid(Rest, R + 1, NewRowMap, NewColMap, NewServers).

parse_row([], _R, _C, RowMap, ColMap, Servers) ->
    {RowMap, ColMap, Servers};
parse_row([1 | Rest], R, C, RowMap, ColMap, Servers) ->
    UpdatedRowMap = maps:update_with(R, fun(X) -> X + 1 end, 1, RowMap),
    UpdatedColMap = maps:update_with(C, fun(X) -> X + 1 end, 1, ColMap),
    parse_row(Rest, R, C + 1, UpdatedRowMap, UpdatedColMap, [{R, C} | Servers]);
parse_row([0 | Rest], R, C, RowMap, ColMap, Servers) ->
    parse_row(Rest, R, C + 1, RowMap, ColMap, Servers).

count_valid([], _RowMap, _ColMap, Acc) ->
    Acc;
count_valid([{R, C} | Rest], RowMap, ColMap, Acc) ->
    case (maps:get(R, RowMap) > 1) orelse (maps:get(C, ColMap) > 1) of
        true -> count_valid(Rest, RowMap, ColMap, Acc + 1);
        false -> count_valid(Rest, RowMap, ColMap, Acc)
    end.

