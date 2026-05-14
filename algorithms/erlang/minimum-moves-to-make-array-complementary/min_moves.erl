-spec min_moves(Nums :: [integer()], Limit :: integer()) -> integer().
min_moves(Nums, Limit) ->
    N = length(Nums),
    Half = N div 2,
    {L1, L2} = lists:split(Half, Nums),
    Events = build_events(L1, lists:reverse(L2), Limit, []),
    Merged = merge_events(lists:sort(Events)),
    find_min(Merged, N, 0, N).

build_events([], [], _, Acc) -> 
    Acc;
build_events([A | T1], [B | T2], Limit, Acc) ->
    Min = min(A, B),
    Max = max(A, B),
    Sum = A + B,
    build_events(T1, T2, Limit, 
        [{Min + 1, -1}, {Sum, -1}, {Sum + 1, 1}, {Max + Limit + 1, 1} | Acc]).

merge_events([]) -> 
    [];
merge_events([{Pos, D} | T]) -> 
    merge_events(T, Pos, D, []).

merge_events([], Pos, D, Acc) -> 
    lists:reverse([{Pos, D} | Acc]);
merge_events([{Pos, D1} | T], Pos, D, Acc) -> 
    merge_events(T, Pos, D + D1, Acc);
merge_events([{Pos1, D1} | T], Pos, D, Acc) -> 
    merge_events(T, Pos1, D1, [{Pos, D} | Acc]).

find_min([], _, _, MinCost) -> 
    MinCost;
find_min([{_, D} | T], Base, Curr, MinCost) ->
    Next = Curr + D,
    find_min(T, Base, Next, min(MinCost, Base + Next)).