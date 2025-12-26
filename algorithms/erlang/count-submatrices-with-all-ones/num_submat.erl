-spec num_submat(Mat :: [[integer()]]) -> integer().
num_submat([]) -> 0;
num_submat(Mat) ->
    Cols = length(hd(Mat)),
    %% 初始化 prev_heights 为全 0，长度与列数相同
    InitialHeights = lists:duplicate(Cols, 0),
    solve(Mat, InitialHeights, 0).

%% @doc 遍历每一行，更新高度并累加结果
solve([], _PrevHeights, TotalCount) ->
    TotalCount;
solve([Row | RestRows], PrevHeights, TotalCount) ->
    %% 1. 计算当前行的高度 (DP步骤)
    CurrHeights = update_heights(Row, PrevHeights),
    %% 2. 使用单调栈计算当前行贡献的矩形数量
    RowContribution = count_row(CurrHeights),
    solve(RestRows, CurrHeights, TotalCount + RowContribution).

%% @doc 根据上一行的高度和当前行的值计算新高度
%% 如果当前格是 0，高度重置为 0；如果是 1，则为 prev + 1
update_heights(Row, PrevHeights) ->
    lists:zipwith(fun(Val, H) -> 
        if 
            Val == 0 -> 0; 
            true -> H + 1 
        end 
    end, Row, PrevHeights).

%% @doc 计算基于当前高度数组的矩形总数
count_row(Heights) ->
    %% Stack 存储元组: {Index, Height, AccumulatedCount}
    %% Index: 列索引 (0-based)
    %% Height: 柱子高度
    %% AccumulatedCount: 在该索引处，以该柱子为结尾的所有矩形数量之和
    process_stack(Heights, 0, [], 0).

%% @doc 单调栈处理逻辑
process_stack([], _, _, TotalRowSum) ->
    TotalRowSum;
process_stack([H | Rest], Idx, Stack, TotalRowSum) ->
    %% 弹出所有高度 >= 当前高度 H 的元素
    NewStack = pop_stack(Stack, H),
    
    %% 计算以当前位置 (Idx) 为右下角的矩形数量
    %% 公式: Contribution = (Idx - PrevIdx) * H + PrevCount
    {PrevIdx, PrevCount} = case NewStack of
        [] -> {-1, 0}; %% 栈空时，左边界视为 -1，前序计数为 0
        [{P_Idx, _, P_Count} | _] -> {P_Idx, P_Count}
    end,
    
    CurrCount = PrevCount + (Idx - PrevIdx) * H,
    
    %% 将当前状态压入栈，并累加到总和
    process_stack(Rest, Idx + 1, [{Idx, H, CurrCount} | NewStack], TotalRowSum + CurrCount).

%% @doc 弹出栈中所有高度大于等于 H 的元素，保持单调递增
pop_stack([{_, StackH, _} | Rest], H) when StackH >= H ->
    pop_stack(Rest, H);
pop_stack(Stack, _) ->
    Stack.