-spec swim_in_water(Grid :: [[integer()]]) -> integer().
swim_in_water(Grid) ->
    N = length(Grid),
    %% 将列表转换为元组的元组，以便实现 O(1) 的随机访问
    %% Matrix[R][C] 可以通过 element(C+1, element(R+1, Matrix)) 访问
    Matrix = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),
    
    %% 起点的高度
    StartElevation = get_val(0, 0, Matrix),
    
    %% 优先级队列 (使用 gb_trees 实现)
    %% Key: Time (当前路径的最大高度)
    %% Value: List of Coordinates [{R, C}] (处理相同高度可能有多个坐标的情况)
    PQ = gb_trees:insert(StartElevation, [{0, 0}], gb_trees:empty()),
    
    %% 记录已访问的节点，防止重复处理
    %% 使用 sets:new([{version, 2}]) 以获得更好的性能
    Visited = sets:from_list([{0, 0}], [{version, 2}]),
    
    dijkstra(PQ, Visited, Matrix, N).

%% Dijkstra 主循环
dijkstra(PQ, Visited, Matrix, N) ->
    %% 取出当前水位最低的节点集合
    {Time, Coords, PQ2} = gb_trees:take_smallest(PQ),
    
    %% 处理该水位下的所有坐标
    case process_coords(Coords, Time, PQ2, Visited, Matrix, N) of
        {result, ResultTime} -> 
            ResultTime;
        {continue, NextPQ, NextVisited} -> 
            dijkstra(NextPQ, NextVisited, Matrix, N)
    end.

%% 处理当前优先级下的坐标列表
process_coords([], _Time, PQ, Visited, _Matrix, _N) ->
    {continue, PQ, Visited};
process_coords([{R, C} | Rest], Time, PQ, Visited, Matrix, N) ->
    %% 如果到达右下角 (N-1, N-1)，直接返回当前 Time
    if 
        R =:= N - 1, C =:= N - 1 ->
            {result, Time};
        true ->
            %% 获取合法的邻居
            Neighbors = get_neighbors(R, C, N),
            
            %% 过滤掉已访问的邻居，并计算新的状态
            {NewPQ, NewVisited} = lists:foldl(fun({NR, NC}, {AccPQ, AccVisited}) ->
                case sets:is_element({NR, NC}, AccVisited) of
                    true -> 
                        {AccPQ, AccVisited}; %% 已经访问过，跳过
                    false ->
                        Val = get_val(NR, NC, Matrix),
                        %% 核心逻辑：新路径的水位是 当前水位 和 邻居高度 的较大值
                        NewTime = max(Time, Val),
                        
                        %% 更新 Visited
                        UpdVisited = sets:add_element({NR, NC}, AccVisited),
                        
                        %% 更新 PQ
                        %% 注意：gb_trees 的 key 必须唯一。如果 Key 已存在，我们需要将新坐标追加到列表中。
                        UpdPQ = case gb_trees:lookup(NewTime, AccPQ) of
                            none -> 
                                gb_trees:insert(NewTime, [{NR, NC}], AccPQ);
                            {value, ExistingList} -> 
                                gb_trees:update(NewTime, [{NR, NC} | ExistingList], AccPQ)
                        end,
                        {UpdPQ, UpdVisited}
                end
            end, {PQ, Visited}, Neighbors),
            
            %% 继续处理同优先级的剩余坐标
            process_coords(Rest, Time, NewPQ, NewVisited, Matrix, N)
    end.

%% 获取矩阵中的值
get_val(R, C, Matrix) ->
    element(C + 1, element(R + 1, Matrix)).

move_flag(R,C,N,DR,DC) ->
    G1 = R + DR >= 0, 
    G2 = R + DR < N,
    G3 = C + DC >= 0,
    G4 = C + DC < N,
    Flag = G1 and G2 and G3 and G4.

%% 获取 4 个方向的合法邻居
get_neighbors(R, C, N) ->
    Moves = [{-1, 0}, {1, 0}, {0, -1}, {0, 1}],
    %%One = [ {R + DR, C + DC} || {DR, DC} <- Moves,
    %%  R + DR >= 0, R + DR < N,
    %%  C + DC >= 0, C + DC < N ],
    %io:format("show me param one ---- ~p~n",[Moves]),
    One = [ {R + DR, C + DC} || {DR, DC} <- Moves, move_flag(R,C,N,DR,DC)],
    %io:format("show me param one ---- ~p~n",[One]),
    One.