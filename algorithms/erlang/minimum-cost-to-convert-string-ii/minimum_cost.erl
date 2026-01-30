-spec minimum_cost(Source :: unicode:unicode_binary(), Target :: unicode:unicode_binary(), Original :: [unicode:unicode_binary()], Changed :: [unicode:unicode_binary()], Cost :: [integer()]) -> integer().

-define(INFINITY, 1000000000000000).
minimum_cost(Source, Target, Original, Changed, Cost) ->
    N = byte_size(Source),
    
    % 1. 预处理转换规则，计算所有可能的子串对之间的最小转换成本
    % 结果格式: #{ {FromSub, ToSub} => MinCost }
    % 同时返回所有出现的转换长度列表
    {TransCosts, Lengths} = build_transformation_costs(Original, Changed, Cost),
    
    % 2. 初始化 DP 数组
    % 使用 array 模块作为 DP 表，索引 0 到 N。
    % Dp[i] 表示处理完前 i 个字符的最小成本。
    DpInit = array:new(N + 1, [{default, ?INFINITY}]),
    Dp0 = array:set(0, 0, DpInit),
    
    % 3. 运行动态规划
    FinalDp = run_dp(0, N, Source, Target, Lengths, TransCosts, Dp0),
    
    % 4. 获取结果
    Result = array:get(N, FinalDp),
    if 
        Result >= ?INFINITY -> -1;
        true -> Result
    end.

%% =============================================================================
%% 动态规划逻辑
%% =============================================================================

run_dp(I, N, _Source, _Target, _Lengths, _TransCosts, Dp) when I >= N ->
    Dp;
run_dp(I, N, Source, Target, Lengths, TransCosts, Dp) ->
    CurrentCost = array:get(I, Dp),
    
    if 
        CurrentCost >= ?INFINITY ->
            % 如果当前状态不可达，直接跳过
            run_dp(I + 1, N, Source, Target, Lengths, TransCosts, Dp);
        true ->
            % 尝试两种转移方式
            
            % 方式 1: 单字符匹配 (如果字符相等，成本为 0)
            SrcChar = binary:part(Source, I, 1),
            TgtChar = binary:part(Target, I, 1),
            Dp1 = if 
                SrcChar =:= TgtChar ->
                    OldVal = array:get(I + 1, Dp),
                    if 
                        CurrentCost < OldVal -> array:set(I + 1, CurrentCost, Dp);
                        true -> Dp
                    end;
                true -> 
                    Dp
            end,
            
            % 方式 2: 子串转换
            % 尝试所有已知的转换长度
            Dp2 = check_transformations(Lengths, I, N, Source, Target, TransCosts, CurrentCost, Dp1),
            
            run_dp(I + 1, N, Source, Target, Lengths, TransCosts, Dp2)
    end.

check_transformations([], _I, _N, _Source, _Target, _Costs, _CurrCost, Dp) ->
    Dp;
check_transformations([Len | Rest], I, N, Source, Target, Costs, CurrCost, Dp) ->
    NextI = I + Len,
    NewDp = if 
        NextI =< N ->
            SubS = binary:part(Source, I, Len),
            SubT = binary:part(Target, I, Len),
            
            % 检查是否有直接或间接的转换路径
            case maps:find({SubS, SubT}, Costs) of
                {ok, Cost} ->
                    NewTotal = CurrCost + Cost,
                    OldTotal = array:get(NextI, Dp),
                    if 
                        NewTotal < OldTotal -> array:set(NextI, NewTotal, Dp);
                        true -> Dp
                    end;
                error ->
                    Dp
            end;
        true ->
            Dp
    end,
    check_transformations(Rest, I, N, Source, Target, Costs, CurrCost, NewDp).

%% =============================================================================
%% 图算法与预处理逻辑
%% =============================================================================

build_transformation_costs(Original, Changed, Cost) ->
    % 将输入组合为元组列表
    Triples = lists:zip3(Original, Changed, Cost),
    
    % 按字符串长度分组: #{ Length => [{From, To, Cost}] }
    Groups = lists:foldl(fun({O, C, W}, Acc) ->
        Len = byte_size(O),
        maps:update_with(Len, fun(List) -> [{O, C, W} | List] end, [{O, C, W}], Acc)
    end, #{}, Triples),
    
    % 对每一组长度，计算所有点对最短路径
    % 最终合并为一个大的 Map: #{ {From, To} => MinCost }
    GlobalCosts = maps:fold(fun(_Len, Edges, AccMap) ->
        GroupCosts = compute_group_shortest_paths(Edges),
        maps:merge(AccMap, GroupCosts)
    end, #{}, Groups),
    
    Lengths = maps:keys(Groups),
    {GlobalCosts, Lengths}.

%% 对特定长度的一组边，计算最短路径
compute_group_shortest_paths(Edges) ->
    % 1. 构建邻接表: #{ From => [{To, Cost}] }
    %    收集所有唯一节点
    {Graph, NodesSet} = lists:foldl(fun({U, V, W}, {G, N}) ->
        G2 = maps:update_with(U, fun(Adjs) -> [{V, W} | Adjs] end, [{V, W}], G),
        N2 = sets:add_element(V, sets:add_element(U, N)),
        {G2, N2}
    end, {#{}, sets:new()}, Edges),
    
    Nodes = sets:to_list(NodesSet),
    
    % 2. 对每个节点运行 Dijkstra
    % 返回所有可达路径的成本: #{ {Start, End} => Cost }
    lists:foldl(fun(StartNode, Acc) ->
        Dists = dijkstra(StartNode, Graph),
        maps:fold(fun(EndNode, Cost, InnerAcc) ->
            if 
                StartNode =:= EndNode -> InnerAcc; % 忽略自环 (成本0)
                true -> maps:put({StartNode, EndNode}, Cost, InnerAcc)
            end
        end, Acc, Dists)
    end, #{}, Nodes).

%% 标准 Dijkstra 算法实现
dijkstra(StartNode, Graph) ->
    % Priority Queue: 使用 gb_sets 存储 {Cost, Node}
    PQ = gb_sets:singleton({0, StartNode}),
    % Distances: #{ Node => Cost }
    Dists = #{StartNode => 0},
    dijkstra_loop(PQ, Graph, Dists).

dijkstra_loop(PQ, Graph, Dists) ->
    case gb_sets:is_empty(PQ) of
        true -> Dists;
        false ->
            {{Cost, U}, PQ2} = gb_sets:take_smallest(PQ),
            
            % 检查是否已经找到更短路径 (Lazy Deletion 替代方案)
            CurrentDist = maps:get(U, Dists, ?INFINITY),
            if 
                Cost > CurrentDist -> 
                    dijkstra_loop(PQ2, Graph, Dists);
                true ->
                    Neighbors = maps:get(U, Graph, []),
                    {NewPQ, NewDists} = lists:foldl(fun({V, Weight}, {P, D}) ->
                        NewCost = Cost + Weight,
                        OldCost = maps:get(V, D, ?INFINITY),
                        if 
                            NewCost < OldCost ->
                                P_next = gb_sets:add({NewCost, V}, P),
                                D_next = maps:put(V, NewCost, D),
                                {P_next, D_next};
                            true ->
                                {P, D}
                        end
                    end, {PQ2, Dists}, Neighbors),
                    dijkstra_loop(NewPQ, Graph, NewDists)
            end
    end.