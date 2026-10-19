-spec min_swaps(Nums :: [integer()]) -> integer().
min_swaps(Nums) ->
    N = length(Nums),
    WithOriginal = lists:zip(Nums, lists:seq(1, N)),
    Mapped = [{digit_sum(Num, 0), Num, Idx} || {Num, Idx} <- WithOriginal],
    Sorted = lists:sort(Mapped),
    PermTuple = list_to_tuple([Idx || {_, _, Idx} <- Sorted]),
    Cycles = count_cycles(1, N, PermTuple, #{}, 0),
    N - Cycles.

digit_sum(0, Acc) -> 
    Acc;
digit_sum(N, Acc) -> 
    digit_sum(N div 10, Acc + N rem 10).

count_cycles(I, N, _PermTuple, _Visited, Cycles) when I > N ->
    Cycles;
count_cycles(I, N, PermTuple, Visited, Cycles) ->
    case maps:is_key(I, Visited) of
        true -> 
            count_cycles(I + 1, N, PermTuple, Visited, Cycles);
        false ->
            NewVisited = traverse_cycle(I, PermTuple, Visited),
            count_cycles(I + 1, N, PermTuple, NewVisited, Cycles + 1)
    end.

traverse_cycle(Curr, PermTuple, Visited) ->
    case maps:is_key(Curr, Visited) of
        true -> 
            Visited;
        false ->
            Next = element(Curr, PermTuple),
            traverse_cycle(Next, PermTuple, maps:put(Curr, true, Visited))
    end.

