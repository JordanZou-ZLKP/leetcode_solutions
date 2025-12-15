-spec max_k_divisible_components(N :: integer(), Edges :: [[integer()]], Values :: [integer()], K :: integer()) -> integer().


max_k_divisible_components(N, Edges, Values, K) ->
    % 构建邻接表
    Graph = array:new(N, {default, []}),
    Graph1 = build_graph(Edges, Graph),
    
    % BFS 初始化
    Parent = array:new(N, {default, -1}),
    Depth = array:new(N, {default, 0}),
    Children = array:new(N, {default, []}),
    
    % 执行 BFS 构建树结构
    Queue = queue:from_list([0]),
    Parent1 = array:set(0, -1, Parent),
    {Parent2, Depth1, Children1} = bfs(Queue, Graph1, Parent1, Depth, Children, N),
    
    % 按深度降序排序节点
    Nodes = lists:seq(0, N-1),
    SortedNodes = lists:sort(fun(A, B) ->
        array:get(A, Depth1) > array:get(B, Depth1)
    end, Nodes),
    
    % 初始化 sum_mod 数组 (values[i] mod k)
    ValuesArray = array:from_list(Values),
    SumMod = array:map(fun(_Idx, V) -> V rem K end, ValuesArray),
    
    % 处理节点，计算最大分量数
    {Count, _} = lists:foldl(fun(U, {Cnt, SM}) ->
        Total = array:get(U, SM),
        ChildList = array:get(U, Children1),
        NewTotal = lists:foldl(fun(Child, Acc) ->
            ChildSum = array:get(Child, SM),
            (Acc + ChildSum) rem K
        end, Total, ChildList),
        if 
            NewTotal == 0 ->
                {Cnt + 1, array:set(U, 0, SM)};
            true ->
                {Cnt, array:set(U, NewTotal, SM)}
        end
    end, {0, SumMod}, SortedNodes),
    
    Count.

% 构建邻接表
build_graph([], Graph) ->
    Graph;
build_graph([[A, B] | Rest], Graph) ->
    NeighborsA = array:get(A, Graph),
    G1 = array:set(A, [B | NeighborsA], Graph),
    NeighborsB = array:get(B, G1),
    G2 = array:set(B, [A | NeighborsB], G1),
    build_graph(Rest, G2).

% BFS 遍历构建树结构
bfs(Queue, Graph, Parent, Depth, Children, N) ->
    case queue:out(Queue) of
        {empty, _} ->
            {Parent, Depth, Children};
        {{value, U}, Queue1} ->
            Neighbors = array:get(U, Graph),
            {NewParent, NewDepth, NewChildren, NewQueue} = 
                lists:foldl(fun(V, {P, D, C, Q}) ->
                    PV = array:get(U, P),  % U 的父节点
                    case V of
                        PV ->  % 跳过父节点
                            {P, D, C, Q};
                        _ ->
                            % 设置 V 的父节点为 U
                            P1 = array:set(V, U, P),
                            % 设置 V 的深度
                            D1 = array:set(V, array:get(U, D) + 1, D),
                            % 将 V 加入 U 的子节点列表
                            OldChildrenU = array:get(U, C),
                            C1 = array:set(U, [V | OldChildrenU], C),
                            % 将 V 加入队列
                            Q1 = queue:in(V, Q),
                            {P1, D1, C1, Q1}
                    end
                end, {Parent, Depth, Children, Queue1}, Neighbors),
            bfs(NewQueue, Graph, NewParent, NewDepth, NewChildren, N)
    end.
    