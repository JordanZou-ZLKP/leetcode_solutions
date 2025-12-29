-spec pacific_atlantic(Heights :: [[integer()]]) -> [[integer()]].

-type coord() :: {integer(), integer()}.
-type grid() :: #{coord() => integer()}.

pacific_atlantic(Heights) ->
    case Heights of
        [] -> [];
        _ ->
            RowLen = length(Heights),
            ColLen = length(hd(Heights)),
            
            % 1. 将输入的列表列表转换为 Map，以便进行 O(log N) 的随机访问
            % Grid 格式: #{{Row, Col} => Height}
            Grid = parse_grid(Heights, 0, #{}),
            
            % 2. 定义太平洋和大西洋的起始边缘节点
            % 太平洋：左边 (Col 0) 和 上边 (Row 0)
            PacificStarts = [{R, 0} || R <- lists:seq(0, RowLen - 1)] ++ 
                            [{0, C} || C <- lists:seq(0, ColLen - 1)],
            
            % 大西洋：右边 (Col N-1) 和 下边 (Row M-1)
            AtlanticStarts = [{R, ColLen - 1} || R <- lists:seq(0, RowLen - 1)] ++ 
                             [{RowLen - 1, C} || C <- lists:seq(0, ColLen - 1)],
            
            % 3. 分别执行 BFS/DFS 搜索
            % 太平洋可达集合
            PacificReachable = bfs(PacificStarts, Grid, sets:new(), RowLen, ColLen),
            % 大西洋可达集合
            AtlanticReachable = bfs(AtlanticStarts, Grid, sets:new(), RowLen, ColLen),
            
            % 4. 取交集
            Intersection = sets:intersection(PacificReachable, AtlanticReachable),
            
            % 5. 格式化输出为 [[r, c], ...]
            lists:sort([ [R, C] || {R, C} <- sets:to_list(Intersection) ])
    end.

%% @doc 广度优先搜索 (也可以用 DFS)
%% 从边缘节点出发，如果邻居高度 >= 当前节点高度，则可以“反向流”过去
-spec bfs([coord()], grid(), sets:set(coord()), integer(), integer()) -> sets:set(coord()).
bfs([], _Grid, Visited, _M, _N) ->
    Visited;
bfs([Current | Rest], Grid, Visited, M, N) ->
    case sets:is_element(Current, Visited) of
        true ->
            % 如果已经访问过，跳过
            bfs(Rest, Grid, Visited, M, N);
        false ->
            % 标记为已访问
            NewVisited = sets:add_element(Current, Visited),
            % 获取符合条件（高度更高或相等）的邻居
            Neighbors = get_valid_neighbors(Current, Grid, M, N),
            % 将邻居加入队列
            bfs(Rest ++ Neighbors, Grid, NewVisited, M, N)
    end.

%% @doc 获取合法的逆流邻居
-spec get_valid_neighbors(coord(), grid(), integer(), integer()) -> [coord()].
get_valid_neighbors({R, C}, Grid, M, N) ->
    CurrentHeight = maps:get({R, C}, Grid),
    Directions = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
    
    lists:filtermap(fun({Dr, Dc}) ->
        Nr = R + Dr,
        Nc = C + Dc,
        % 边界检查
        case (Nr >= 0 andalso Nr < M andalso Nc >= 0 andalso Nc < N) of
            true ->
                NeighborHeight = maps:get({Nr, Nc}, Grid),
                % 关键逻辑：逆向思维，水往高处流（寻找来源）
                % 只有当邻居高度 >= 当前高度时，水才能从邻居流向当前
                if NeighborHeight >= CurrentHeight -> {true, {Nr, Nc}};
                   true -> false
                end;
            false -> false
        end
    end, Directions).

%% @doc 将 List of Lists 解析为 Map #{ {R,C} => H }
parse_grid([], _RowIdx, Map) -> Map;
parse_grid([RowData | Rest], RowIdx, Map) ->
    NewMap = parse_row(RowData, RowIdx, 0, Map),
    parse_grid(Rest, RowIdx + 1, NewMap).

parse_row([], _RowIdx, _ColIdx, Map) -> Map;
parse_row([H | Rest], RowIdx, ColIdx, Map) ->
    parse_row(Rest, RowIdx, ColIdx + 1, Map#{{RowIdx, ColIdx} => H}).  