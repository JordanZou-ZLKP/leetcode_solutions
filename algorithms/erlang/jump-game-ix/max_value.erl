-spec max_value(Nums :: [integer()]) -> [integer()].
max_value(Nums) ->
    PMax = build_pmax(Nums, -1, []),
    SMin = build_smin(lists:reverse(Nums), 10000000000, []),
    [_ | SMinTail] = SMin ++ [10000000000],
    build_blocks(PMax, SMinTail, 0, []).

build_pmax([H | T], CurrentMax, Acc) ->
    NextMax = max(H, CurrentMax),
    build_pmax(T, NextMax, [NextMax | Acc]);
build_pmax([], _, Acc) ->
    lists:reverse(Acc).

build_smin([H | T], CurrentMin, Acc) ->
    NextMin = min(H, CurrentMin),
    build_smin(T, NextMin, [NextMin | Acc]);
build_smin([], _, Acc) ->
    Acc.

build_blocks([P | PT], [S | ST], Count, Acc) ->
    if
        P =< S ->
            build_blocks(PT, ST, 0, replicate(Count + 1, P, Acc));
        true ->
            build_blocks(PT, ST, Count + 1, Acc)
    end;
build_blocks([], [], 0, Acc) ->
    lists:reverse(Acc).

replicate(0, _, Acc) -> Acc;
replicate(N, Val, Acc) -> replicate(N - 1, Val, [Val | Acc]).