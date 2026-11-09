-spec assign_tasks(Servers :: [integer()], Tasks :: [integer()]) -> [integer()].
assign_tasks(Servers, Tasks) ->
    Free = init_free(Servers, 0, gb_sets:new()),
    Busy = gb_sets:new(),
    Ans = process_tasks(0, Tasks, 0, Free, Busy, []),
    lists:reverse(Ans).

init_free([], _Index, Set) ->
    Set;
init_free([Weight | Rest], Index, Set) ->
    init_free(Rest, Index + 1, gb_sets:add_element({Weight, Index}, Set)).

process_tasks(_J, [], _Time, _Free, _Busy, Acc) ->
    Acc;
process_tasks(J, [TaskTime | RestTasks], Time, Free, Busy, Acc) ->
    TargetTime = max(Time, J),
    {Free1, Busy1} = release_servers(TargetTime, Free, Busy),
    {FinalTime, Free2, Busy2} = case gb_sets:is_empty(Free1) of
        true ->
            {{NextTime, _, _}, _} = gb_sets:take_smallest(Busy1),
            {F, B} = release_servers(NextTime, Free1, Busy1),
            {NextTime, F, B};
        false ->
            {TargetTime, Free1, Busy1}
    end,
    {{Weight, Index}, Free3} = gb_sets:take_smallest(Free2),
    Busy3 = gb_sets:add_element({FinalTime + TaskTime, Weight, Index}, Busy2),
    process_tasks(J + 1, RestTasks, FinalTime, Free3, Busy3, [Index | Acc]).

release_servers(Time, Free, Busy) ->
    case gb_sets:is_empty(Busy) of
        true ->
            {Free, Busy};
        false ->
            {{EndTime, Weight, Index}, _} = gb_sets:take_smallest(Busy),
            case EndTime =< Time of
                true ->
                    {_, Busy1} = gb_sets:take_smallest(Busy),
                    Free1 = gb_sets:add_element({Weight, Index}, Free),
                    release_servers(Time, Free1, Busy1);
                false ->
                    {Free, Busy}
            end
    end.

