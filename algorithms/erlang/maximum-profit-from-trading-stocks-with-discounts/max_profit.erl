-spec max_profit(N :: integer(), Present :: [integer()], Future :: [integer()], Hierarchy :: [[integer()]], Budget :: integer()) -> integer().

max_profit(N, Present, Future, Hierarchy, Budget) ->
    PTuple = list_to_tuple(Present),
    FTuple = list_to_tuple(Future),
    
    Adj = lists:foldl(fun([U, V], Acc) ->
        Existing = maps:get(U, Acc, []),
        Acc#{U => [V | Existing]}
    end, #{}, Hierarchy),
    
    {_, ResFull} = dfs(1, Adj, PTuple, FTuple, Budget),
    
    case maps:size(ResFull) of
        0 -> 0;
        _ -> lists:max(maps:values(ResFull))
    end.

dfs(U, Adj, PTuple, FTuple, Budget) ->
    Children = maps:get(U, Adj, []),
    
    InitMap = #{0 => 0},
    
    {AggBuy, AggSkip} = lists:foldl(fun(V, {AccB, AccS}) ->
        {ChildHalf, ChildFull} = dfs(V, Adj, PTuple, FTuple, Budget),
        NewAccB = combine(AccB, ChildHalf, Budget),
        NewAccS = combine(AccS, ChildFull, Budget),
        {NewAccB, NewAccS}
    end, {InitMap, InitMap}, Children),
    
    CostFull = element(U, PTuple),
    CostHalf = CostFull div 2,
    ProfitVal = element(U, FTuple),
    
    ResSkip = AggSkip, 
    
    ResBuyFull = shift_and_add(AggBuy, CostFull, ProfitVal - CostFull, Budget),
    
    ResBuyHalf = shift_and_add(AggBuy, CostHalf, ProfitVal - CostHalf, Budget),
    
    MapHalf = merge_maps(ResBuyHalf, ResSkip),
    
    MapFull = merge_maps(ResBuyFull, ResSkip),
    
    {MapHalf, MapFull}.

combine(Map1, Map2, Budget) ->
    List1 = maps:to_list(Map1),
    List2 = maps:to_list(Map2),
    
    RawList = [ {C1+C2, P1+P2} || {C1, P1} <- List1, {C2, P2} <- List2, C1+C2 =< Budget ],
    
    reduce_to_map(RawList).

shift_and_add(Map, CostDelta, ProfitDelta, Budget) ->
    List = maps:to_list(Map),
    RawList = [ {C + CostDelta, P + ProfitDelta} || {C, P} <- List, C + CostDelta =< Budget ],
    reduce_to_map(RawList).

merge_maps(Map1, Map2) ->
    maps:fold(fun(C, P, Acc) ->
        update_max(C, P, Acc)
    end, Map1, Map2).

reduce_to_map(List) ->
    lists:foldl(fun({C, P}, Acc) -> update_max(C, P, Acc) end, #{}, List).

update_max(C, P, Map) ->
    case maps:find(C, Map) of
        {ok, OldP} when OldP >= P -> Map;
        _ -> Map#{C => P}
    end.