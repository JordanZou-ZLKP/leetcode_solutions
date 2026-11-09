-spec count_servers(N :: integer(), Logs :: [[integer()]], X :: integer(), Queries :: [integer()]) -> [integer()].
count_servers(N, Logs, X, Queries) ->
    SortedLogs = lists:sort(fun([_, T1], [_, T2]) -> T1 =< T2 end, Logs),
    IndexedQueries = lists:zip(Queries, lists:seq(1, length(Queries))),
    SortedQueries = lists:sort(fun({Q1, _}, {Q2, _}) -> Q1 =< Q2 end, IndexedQueries),
    Results = process_queries(SortedQueries, X, SortedLogs, SortedLogs, #{}, 0, N, []),
    SortedResults = lists:sort(fun({I1, _}, {I2, _}) -> I1 =< I2 end, Results),
    [Val || {_, Val} <- SortedResults].

process_queries([], _X, _LogsToAdd, _LogsToRemove, _FreqMap, _UniqueCount, _N, Acc) ->
    Acc;
process_queries([{Q, QIdx} | RestQueries], X, LogsToAdd, LogsToRemove, FreqMap, UniqueCount, N, Acc) ->
    {NewLogsToAdd, FreqMap1, UniqueCount1} = add_logs(LogsToAdd, Q, FreqMap, UniqueCount),
    {NewLogsToRemove, FreqMap2, UniqueCount2} = remove_logs(LogsToRemove, Q - X, FreqMap1, UniqueCount1),
    process_queries(RestQueries, X, NewLogsToAdd, NewLogsToRemove, FreqMap2, UniqueCount2, N, [{QIdx, N - UniqueCount2} | Acc]).

add_logs([[SId, T] | Rest], Q, Map, Cnt) when T =< Q ->
    OldVal = maps:get(SId, Map, 0),
    NewCnt = if OldVal =:= 0 -> Cnt + 1; true -> Cnt end,
    add_logs(Rest, Q, maps:put(SId, OldVal + 1, Map), NewCnt);
add_logs(Logs, _Q, Map, Cnt) ->
    {Logs, Map, Cnt}.

remove_logs([[SId, T] | Rest], Limit, Map, Cnt) when T < Limit ->
    OldVal = maps:get(SId, Map),
    NewCnt = if OldVal =:= 1 -> Cnt - 1; true -> Cnt end,
    remove_logs(Rest, Limit, maps:put(SId, OldVal - 1, Map), NewCnt);
remove_logs(Logs, _Limit, Map, Cnt) ->
    {Logs, Map, Cnt}.

