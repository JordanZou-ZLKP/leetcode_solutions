-spec busiest_servers(K :: integer(), Arrival :: [integer()], Load :: [integer()]) -> [integer()].
busiest_servers(K, Arrival, Load) ->
    Available = gb_sets:from_ordset(lists:seq(0, K - 1)),
    Busy = gb_sets:new(),
    Counts = #{},
    FinalCounts = process_requests(0, K, Arrival, Load, Available, Busy, Counts),
    Max = maps:fold(fun(_, V, Acc) -> max(V, Acc) end, 0, FinalCounts),
    maps:fold(fun(Key, Val, Acc) ->
        case Val =:= Max of
            true -> [Key | Acc];
            false -> Acc
        end
    end, [], FinalCounts).

process_requests(_I, _K, [], [], _Available, _Busy, Counts) ->
    Counts;
process_requests(I, K, [A | ArrT], [L | LoadT], Available, Busy, Counts) ->
    {Available1, Busy1} = free_servers(A, Available, Busy),
    case gb_sets:is_empty(Available1) of
        true ->
            process_requests(I + 1, K, ArrT, LoadT, Available1, Busy1, Counts);
        false ->
            Target = I rem K,
            Iter = gb_sets:iterator_from(Target, Available1),
            Assigned = case gb_sets:next(Iter) of
                {S, _} -> S;
                none -> gb_sets:smallest(Available1)
            end,
            Available2 = gb_sets:delete_any(Assigned, Available1),
            Busy2 = gb_sets:add_element({A + L, Assigned}, Busy1),
            Counts1 = maps:update_with(Assigned, fun(X) -> X + 1 end, 1, Counts),
            process_requests(I + 1, K, ArrT, LoadT, Available2, Busy2, Counts1)
    end.

free_servers(Time, Available, Busy) ->
    case gb_sets:is_empty(Busy) of
        true ->
            {Available, Busy};
        false ->
            {{EndTime, ServerId}, Busy1} = gb_sets:take_smallest(Busy),
            case EndTime =< Time of
                true ->
                    free_servers(Time, gb_sets:add_element(ServerId, Available), Busy1);
                false ->
                    {Available, Busy}
            end
    end.

