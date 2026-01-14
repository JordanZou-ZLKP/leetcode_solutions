-spec separate_squares(Squares :: [[integer()]]) -> float().
separate_squares(Squares) ->
    % 1. 离散化 X 坐标
    XSet = lists:foldl(fun([X, _, L], Acc) -> [X, X + L | Acc] end, [], Squares),
    SortedX = lists:usort(XSet),
    XTuple = list_to_tuple(SortedX),
    MaxXIdx = tuple_size(XTuple) - 1,
    
    % 构建 X 映射 Map #{Val => Idx}
    {XMap, _} = lists:foldl(fun(V, {M, I}) -> {M#{V => I}, I + 1} end, {#{}, 1}, SortedX),

    % 2. 构建扫描线事件
    % {Y, Type (+1/-1), XStart, XEnd}
    Events = lists:foldl(fun([X, Y, L], Acc) ->
        [{Y, 1, X, X + L}, {Y + L, -1, X, X + L} | Acc]
    end, [], Squares),
    SortedEvents = lists:keysort(1, Events),

    % 3. 执行扫描线
    % Tree 结构: Map #{ NodeIdx => {Count, Length} }
    [{FirstY, _, _, _} | _] = SortedEvents,
    {HistoryReverse, _, _} = lists:foldl(fun({Y, Type, XStart, XEnd}, {Hist, Tree, LastY}) ->
        Dy = Y - LastY,
        % 获取当前总覆盖宽度 (Root Node 1)
        {_, Width} = maps:get(1, Tree, {0, 0}),
        
        % 如果 Y 有推进，记录该区间的贡献
        NewHist = if Dy > 0 -> [{LastY, Y, Width} | Hist]; true -> Hist end,
        
        % 获取对应的 X 离散化区间索引 [L, R-1]
        LIdx = maps:get(XStart, XMap),
        RIdx = maps:get(XEnd, XMap),
        
        % 更新线段树
        NewTree = update_tree(1, 1, MaxXIdx, LIdx, RIdx - 1, Type, Tree, XTuple),
        
        {NewHist, NewTree, Y}
    end, {[], #{}, FirstY}, SortedEvents),

    % 4. 计算结果
    History = lists:reverse(HistoryReverse),
    TotalArea = lists:foldl(fun({S, E, W}, Acc) -> Acc + W * (E - S) end, 0, History),
    
    find_target_y(History, TotalArea / 2.0).

%% ==========================================================
%% 线段树操作
%% ==========================================================

update_tree(Node, NL, NR, QL, QR, Val, Tree, XTuple) ->
    if
        QL =< NL, NR =< QR ->
            % 完全覆盖
            {Count, _OldLen} = maps:get(Node, Tree, {0, 0}),
            NewCount = Count + Val,
            calc_len(Node, NL, NR, NewCount, Tree, XTuple);
        
        true ->
            Mid = (NL + NR) div 2,
            Tree1 = if QL =< Mid -> update_tree(2*Node, NL, Mid, QL, QR, Val, Tree, XTuple);
                       true -> Tree
                    end,
            Tree2 = if QR > Mid -> update_tree(2*Node+1, Mid+1, NR, QL, QR, Val, Tree1, XTuple);
                       true -> Tree1
                    end,
            
            % 更新本节点
            {Count, _} = maps:get(Node, Tree2, {0, 0}),
            calc_len(Node, NL, NR, Count, Tree2, XTuple)
    end.

calc_len(Node, NL, NR, Count, Tree, XTuple) ->
    NewLen = if
        Count > 0 ->
            % 物理长度
            element(NR + 1, XTuple) - element(NL, XTuple);
        NL == NR ->
            0;
        true ->
            {_, LLen} = maps:get(2*Node, Tree, {0, 0}),
            {_, RLen} = maps:get(2*Node + 1, Tree, {0, 0}),
            LLen + RLen
    end,
    maps:put(Node, {Count, NewLen}, Tree).

%% ==========================================================
%% 查找目标 Y
%% ==========================================================

find_target_y([{Start, End, Width} | Rest], Target) ->
    Area = Width * (End - Start),
    if
        Target =< Area ->
            % 如果 Width 为 0，说明没有方块覆盖，Area 必为 0。
            % 如果 Area >= Target (即 0 >= 0)，此时任何 Y 都行？
            % 但题目找 Min Y，且总面积 > 0。
            % 正常情况 Width > 0.
            Start + Target / Width;
        true ->
            find_target_y(Rest, Target - Area)
    end.