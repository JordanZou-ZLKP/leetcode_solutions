-spec max_walls(Robots :: [integer()], Distance :: [integer()], Walls :: [integer()]) -> integer().
max_walls(Robots, Distance, Walls) ->
    RobotsDist = lists:sort(lists:zip(Robots, Distance)),
    SortedWalls = lists:sort(Walls),
    {BaseWalls, FilteredWalls} = extract_base_walls(SortedWalls, RobotsDist, 0, []),
    Segs = segment_walls(FilteredWalls, RobotsDist, [], []),
    [Seg0 | RestSegs] = Segs,
    [{P1, D1} | RestRobots] = RobotsDist,
    DP_L = count_L_cov(Seg0, P1 - D1, 0),
    DP_R = 0,
    MaxExtra = process_dp(RestRobots, RestSegs, DP_L, DP_R, {P1, D1}),
    BaseWalls + MaxExtra.

extract_base_walls([], _Rs, BaseCount, AccFiltered) ->
    {BaseCount, lists:reverse(AccFiltered)};
extract_base_walls(Ws, [], BaseCount, AccFiltered) ->
    {BaseCount, lists:reverse(AccFiltered, Ws)};
extract_base_walls([W | Ws], [{P, D} | Rs], BaseCount, AccFiltered) when W < P ->
    extract_base_walls(Ws, [{P, D} | Rs], BaseCount, [W | AccFiltered]);
extract_base_walls([W | Ws], [{P, D} | Rs], BaseCount, AccFiltered) when W == P ->
    extract_base_walls(Ws, [{P, D} | Rs], BaseCount + 1, AccFiltered);
extract_base_walls(Ws, [_ | Rs], BaseCount, AccFiltered) ->
    extract_base_walls(Ws, Rs, BaseCount, AccFiltered).

segment_walls(Ws, [], AccSeg, AccAll) ->
    LastSeg = lists:reverse(AccSeg) ++ Ws,
    lists:reverse([LastSeg | AccAll]);
segment_walls([W | Ws], [{P, D} | Rs], AccSeg, AccAll) when W < P ->
    segment_walls(Ws, [{P, D} | Rs], [W | AccSeg], AccAll);
segment_walls([W | Ws], [{P, D} | Rs], AccSeg, AccAll) when W == P ->
    segment_walls(Ws, [{P, D} | Rs], AccSeg, AccAll);
segment_walls([_ | _] = Ws, [_ | Rs], AccSeg, AccAll) ->
    segment_walls(Ws, Rs, [], [lists:reverse(AccSeg) | AccAll]);
segment_walls([], [_ | Rs], AccSeg, AccAll) ->
    segment_walls([], Rs, [], [lists:reverse(AccSeg) | AccAll]).

process_dp([], [SegN], DP_L, DP_R, {PN, DN}) ->
    R_cov_N = count_R_cov(SegN, PN + DN, 0),
    max(DP_L, DP_R + R_cov_N);
process_dp([{P, D} | Rs], [Seg | Segs], DP_L, DP_R, {PrevP, PrevD}) ->
    R_cov_prev = count_R_cov(Seg, PrevP + PrevD, 0),
    L_cov_i = count_L_cov(Seg, P - D, 0),
    Union_cov_prev = count_Union_cov(Seg, PrevP + PrevD, P - D, 0),
    Next_DP_L = max(DP_L + L_cov_i, DP_R + Union_cov_prev),
    Next_DP_R = max(DP_L, DP_R + R_cov_prev),
    process_dp(Rs, Segs, Next_DP_L, Next_DP_R, {P, D}).

count_L_cov([], _, Acc) -> Acc;
count_L_cov([X | Xs], Limit, Acc) when X >= Limit -> count_L_cov(Xs, Limit, Acc + 1);
count_L_cov([_ | Xs], Limit, Acc) -> count_L_cov(Xs, Limit, Acc).

count_R_cov([], _, Acc) -> Acc;
count_R_cov([X | Xs], Limit, Acc) when X =< Limit -> count_R_cov(Xs, Limit, Acc + 1);
count_R_cov([_ | Xs], Limit, Acc) -> count_R_cov(Xs, Limit, Acc).

count_Union_cov([], _, _, Acc) -> Acc;
count_Union_cov([X | Xs], RLimit, LLimit, Acc) when X =< RLimit orelse X >= LLimit ->
    count_Union_cov(Xs, RLimit, LLimit, Acc + 1);
count_Union_cov([_ | Xs], RLimit, LLimit, Acc) ->
    count_Union_cov(Xs, RLimit, LLimit, Acc).