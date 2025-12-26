-spec minimum_total(Triangle :: [[integer()]]) -> integer().
minimum_total(Triangle) ->
    %% 1. 将三角形反转，这样我们可以从底部（最后一行）开始处理
    %%    Reversed: [[4,1,8,3], [6,5,7], [3,4], [2]]
    [BottomRow | RestRows] = lists:reverse(Triangle),
    
    %% 2. 使用 foldl 逐行向上归约
    %%    BottomRow 作为初始的 Accumulator
    FinalList = lists:foldl(fun reduce_row/2, BottomRow, RestRows),
    
    %% 3. 最终列表只包含一个元素，即为顶点到底部的最小路径和
    hd(FinalList).

%% @private
%% 核心逻辑：计算当前行到底部的最小路径
%% CurrentRow: 当前处理的行 (例如 [6, 5, 7])
%% BelowAcc:   这也是 Accumulator，包含下一行已经计算好的路径和 (例如 [4, 1, 8, 3])
reduce_row(CurrentRow, BelowAcc) ->
    calculate_min_path(CurrentRow, BelowAcc).

%% 递归遍历当前行的每个元素，结合 BelowAcc 计算最小值
calculate_min_path([], _) ->
    [];
calculate_min_path([Val | RestRow], [Left, Right | RestAcc]) ->
    %% 状态转移：当前值 + min(左下, 右下)
    MinPath = Val + min(Left, Right),
    
    %% 递归处理剩余元素。
    %% 注意：RestAcc 需要保留 Right，因为它是下一个元素的 "左下" 邻居
    [MinPath | calculate_min_path(RestRow, [Right | RestAcc])].