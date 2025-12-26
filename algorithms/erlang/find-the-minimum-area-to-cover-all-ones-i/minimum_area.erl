-spec minimum_area(Grid :: [[integer()]]) -> integer().
minimum_area(Grid) ->
    %% 初始化边界值
    %% 由于约束条件 grid 长度最大 1000，我们设置初始 Min 为 2000，Max 为 -1
    InitialBounds = {2000, -1, 2000, -1},
    
    %% 开始遍历网格，RowIdx 从 0 开始
    {MinR, MaxR, MinC, MaxC} = traverse_grid(Grid, 0, InitialBounds),
    
    %% 计算面积
    (MaxR - MinR + 1) * (MaxC - MinC + 1).

%% @doc 遍历所有行
traverse_grid([], _RowIdx, Bounds) ->
    Bounds;
traverse_grid([Row|RestRows], RowIdx, Bounds) ->
    %% 处理当前行
    NewBounds = traverse_row(Row, RowIdx, 0, Bounds),
    %% 递归处理下一行
    traverse_grid(RestRows, RowIdx + 1, NewBounds).

%% @doc 遍历行内的所有列
traverse_row([], _RowIdx, _ColIdx, Bounds) ->
    Bounds;
%% 如果当前值为 0，直接跳过，ColIdx + 1
traverse_row([0|RestCols], RowIdx, ColIdx, Bounds) ->
    traverse_row(RestCols, RowIdx, ColIdx + 1, Bounds);
%% 如果当前值为 1，更新边界
traverse_row([1|RestCols], RowIdx, ColIdx, {MinR, MaxR, MinC, MaxC}) ->
    NewMinR = min(MinR, RowIdx),
    NewMaxR = max(MaxR, RowIdx),
    NewMinC = min(MinC, ColIdx),
    NewMaxC = max(MaxC, ColIdx),
    traverse_row(RestCols, RowIdx, ColIdx + 1, {NewMinR, NewMaxR, NewMinC, NewMaxC}).