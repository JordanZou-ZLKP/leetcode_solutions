-define(INF, 1000000000000). % 定义一个足够大的数作为无穷大
-define(ALPHABET_SIZE, 26).

-spec minimum_cost(Source :: unicode:unicode_binary(), Target :: unicode:unicode_binary(), Original :: [char()], Changed :: [char()], Cost :: [integer()]) -> integer().
minimum_cost(Source, Target, Original, Changed, Cost) ->
    % 1. 初始化图：构建 26x26 的距离矩阵 (Map 表示)
    % 默认距离为无穷大，自己到自己为 0
    InitDist = maps:from_list([{{I, I}, 0} || I <- lists:seq(0, 25)]),
    
    % 2. 加载输入的边权信息
    % 注意：可能存在多条相同的边，取最小的 cost
    Graph = build_graph(Original, Changed, Cost, InitDist),
    
    % 3. 运行 Floyd-Warshall 算法计算最短路径
    ShortestPaths = floyd_warshall(Graph),
    
    % 4. 遍历字符串计算总成本
    calc_total_cost(Source, Target, ShortestPaths, 0).

%% ==========================================================
%% 辅助函数
%% ==========================================================

%% 构建初始图
build_graph([], [], [], Map) ->
    Map;
build_graph([O | RestO], [C | RestC], [Cost | RestCost], Map) ->
    U = O - $a,
    V = C - $a,
    Key = {U, V},
    OldCost = maps:get(Key, Map, ?INF),
    NewMap = if 
        Cost < OldCost -> maps:put(Key, Cost, Map);
        true -> Map
    end,
    build_graph(RestO, RestC, RestCost, NewMap).

%% Floyd-Warshall 核心算法
floyd_warshall(Graph) ->
    Seq = lists:seq(0, 25),
    % 三层循环: K (中间点), I (起点), J (终点)
    lists:foldl(fun(K, AccK) ->
        lists:foldl(fun(I, AccI) ->
            % 优化：如果 I->K 不通，则无需遍历 J
            case maps:get({I, K}, AccI, ?INF) of
                ?INF -> AccI;
                DistIK ->
                    lists:foldl(fun(J, AccJ) ->
                        DistKJ = maps:get({K, J}, AccJ, ?INF),
                        case DistKJ of
                            ?INF -> AccJ;
                            _ ->
                                DistIJ = maps:get({I, J}, AccJ, ?INF),
                                NewDist = DistIK + DistKJ,
                                if 
                                    NewDist < DistIJ -> maps:put({I, J}, NewDist, AccJ);
                                    true -> AccJ
                                end
                        end
                    end, AccI, Seq)
            end
        end, AccK, Seq)
    end, Graph, Seq).

%% 计算总成本
calc_total_cost(<<>>, <<>>, _Map, Total) ->
    Total;
calc_total_cost(<<S, RestS/binary>>, <<T, RestT/binary>>, Map, Total) ->
    if
        S =:= T -> 
            calc_total_cost(RestS, RestT, Map, Total);
        true ->
            U = S - $a,
            V = T - $a,
            Cost = maps:get({U, V}, Map, ?INF),
            if
                Cost >= ?INF -> -1; % 无法转换
                true -> calc_total_cost(RestS, RestT, Map, Total + Cost)
            end
    end.