-spec sort_matrix(Grid :: [[integer()]]) -> [[integer()]].
sort_matrix(Grid) ->
    N = length(Grid),
    
    % 第一步：提取所有对角线的元素
    % 使用 Map 存储，Key 为 (Row - Col)，Value 为该对角线上的元素列表
    DiagonalsMap = extract_diagonals(Grid),
    
    % 第二步：根据规则对 Map 中的每个列表进行排序
    SortedDiagonalsMap = sort_diagonals(DiagonalsMap),
    
    % 第三步：根据排序后的 Map 重构矩阵
    reconstruct_grid(SortedDiagonalsMap, N).

%% ============================================================
%% 辅助函数
%% ============================================================

%% 1. 提取对角线元素
extract_diagonals(Grid) ->
    % 使用 foldl 遍历行和列
    {_, FinalMap} = lists:foldl(fun(RowData, {R, MapAcc}) ->
        {_, NewMapAcc} = lists:foldl(fun(Val, {C, InnerMap}) ->
            Key = R - C,
            ExistingVals = maps:get(Key, InnerMap, []),
            {C + 1, InnerMap#{Key => [Val | ExistingVals]}}
        end, {0, MapAcc}, RowData),
        {R + 1, NewMapAcc}
    end, {0, #{}}, Grid),
    FinalMap.

%% 2. 排序对角线
sort_diagonals(Map) ->
    maps:map(fun(Key, Vals) ->
        Sorted = lists:sort(Vals),
        if
            Key >= 0 -> 
                % Bottom-left triangle (r >= c, so r-c >= 0): Non-increasing
                lists:reverse(Sorted);
            true -> 
                % Top-right triangle (r < c, so r-c < 0): Non-decreasing
                Sorted
        end
    end, Map).

%% 3. 重构矩阵
reconstruct_grid(SortedMap, N) ->
    RowIndices = lists:seq(0, N - 1),
    ColIndices = lists:seq(0, N - 1),
    
    % 使用 mapfoldl 遍历坐标，同时维护剩余元素的 Map 状态
    {ResultGrid, _} = lists:mapfoldl(fun(R, MapAcc) ->
        lists:mapfoldl(fun(C, InnerMapAcc) ->
            Key = R - C,
            [Val | Rest] = maps:get(Key, InnerMapAcc),
            % 取出当前对角线列表的头部元素，并将剩余列表更新回 Map
            {Val, InnerMapAcc#{Key => Rest}}
        end, MapAcc, ColIndices)
    end, SortedMap, RowIndices),
    ResultGrid.