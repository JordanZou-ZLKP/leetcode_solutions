-spec max_run_time(N :: integer(), Batteries :: [integer()]) -> integer().
max_run_time(N, Batteries) ->
    Sorted = lists:reverse(lists:sort(Batteries)), % descending order
    Total = lists:sum(Batteries),
    {FinalTotal, FinalN} = remove_excess_batteries(Sorted, Total, N),
    FinalTotal div FinalN.  % integer division is safe per problem logic

%% Helper: recursively remove "excess" large batteries
remove_excess_batteries([], Total, N) ->
    {Total, N};
remove_excess_batteries([H|T], Total, N) when N > 0 ->
    case H =< Total div N of
        true ->
            {Total, N};  % no more excess batteries
        false ->
            % H is too big: assign it to one computer exclusively
            NewTotal = Total - H,
            NewN = N - 1,
            if
                NewN =< 0 ->
                    % Should not happen per constraints, but safe guard
                    {NewTotal, 1};
                true ->
                    remove_excess_batteries(T, NewTotal, NewN)
            end
    end;
remove_excess_batteries(_, Total, N) ->
    {Total, N}.