-spec max_num_of_substrings(S :: unicode:unicode_binary()) -> [unicode:unicode_binary()].
max_num_of_substrings(S) ->
    Size = byte_size(S),
    Bounds = find_bounds(S, 0, Size, #{}),
    Intervals = find_intervals(Bounds, S),
    SortedIntervals = lists:sort(fun({_, E1}, {_, E2}) -> E1 < E2 end, Intervals),
    extract_substrings(SortedIntervals, S, -1, []).

find_bounds(S, Idx, Size, Acc) when Idx < Size ->
    C = binary:at(S, Idx),
    case maps:find(C, Acc) of
        error -> 
            find_bounds(S, Idx + 1, Size, maps:put(C, {Idx, Idx}, Acc));
        {ok, {First, _}} -> 
            find_bounds(S, Idx + 1, Size, maps:put(C, {First, Idx}, Acc))
    end;
find_bounds(_, _, _, Acc) -> 
    Acc.

find_intervals(Bounds, S) ->
    maps:fold(fun(C, {First, _}, Acc) ->
        case check_interval(First, Bounds, S) of
            {ok, Last} -> [{First, Last} | Acc];
            error -> Acc
        end
    end, [], Bounds).

check_interval(First, Bounds, S) ->
    C = binary:at(S, First),
    {_, Last} = maps:get(C, Bounds),
    expand_interval(First, First, Last, Bounds, S).

expand_interval(OrigFirst, CurIdx, CurLast, Bounds, S) when CurIdx =< CurLast ->
    C = binary:at(S, CurIdx),
    {CFirst, CLast} = maps:get(C, Bounds),
    if
        CFirst < OrigFirst -> 
            error;
        true -> 
            expand_interval(OrigFirst, CurIdx + 1, erlang:max(CurLast, CLast), Bounds, S)
    end;
expand_interval(_, _, CurLast, _, _) ->
    {ok, CurLast}.

extract_substrings([{Start, End} | Rest], S, LastEnd, Acc) ->
    if
        Start > LastEnd ->
            Sub = binary:part(S, Start, End - Start + 1),
            extract_substrings(Rest, S, End, [Sub | Acc]);
        true ->
            extract_substrings(Rest, S, LastEnd, Acc)
    end;
extract_substrings([], _, _, Acc) ->
    lists:reverse(Acc).
