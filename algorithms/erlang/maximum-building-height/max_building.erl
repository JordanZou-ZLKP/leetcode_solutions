-spec max_building(N :: integer(), Restrictions :: [[integer()]]) -> integer().
max_building(N, Restrictions) ->
    R1 = [{1, 0} | [{Id, H} || [Id, H] <- Restrictions]],
    SortedR = lists:ukeysort(1, R1),
    L2R = pass_l2r(SortedR, []),
    FinalR_Asc = pass_r2l(L2R, []),
    DescR = lists:reverse(FinalR_Asc),
    [{LastId, LastH} | _] = DescR,
    MaxAtEnd = LastH + (N - LastId),
    find_max(DescR, MaxAtEnd).

pass_l2r([], Acc) -> Acc;
pass_l2r([{Id, H} | Rest], []) ->
    pass_l2r(Rest, [{Id, H}]);
pass_l2r([{Id, H} | Rest], [{PrevId, PrevH} | _] = Acc) ->
    Limit = PrevH + (Id - PrevId),
    pass_l2r(Rest, [{Id, min(H, Limit)} | Acc]).

pass_r2l([], Acc) -> Acc;
pass_r2l([{Id, H} | Rest], []) ->
    pass_r2l(Rest, [{Id, H}]);
pass_r2l([{Id, H} | Rest], [{NextId, NextH} | _] = Acc) ->
    Limit = NextH + (NextId - Id),
    pass_r2l(Rest, [{Id, min(H, Limit)} | Acc]).

find_max([{_Id, _H}], Max) ->
    Max;
find_max([{Id2, H2}, {Id1, H1} | Rest], Max) ->
    Peak = (H1 + H2 + Id2 - Id1) div 2,
    find_max([{Id1, H1} | Rest], max(Max, Peak)).