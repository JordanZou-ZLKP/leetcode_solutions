-spec count_squares(Matrix :: [[integer()]]) -> integer().
count_squares([]) -> 0;
count_squares(Matrix) ->
    %% 获取列数，用于初始化虚拟的"上一行"
    Cols = length(hd(Matrix)),
    %% 初始化第一行上面的虚拟行，全为0
    InitialPrevDP = lists:duplicate(Cols, 0),
    
    %% 使用 foldl 逐行处理矩阵
    %% Acc 结构: {上一行的DP状态列表, 目前的总正方形数}
    {_, TotalCount} = lists:foldl(fun process_row/2, {InitialPrevDP, 0}, Matrix),
    TotalCount.

%% 处理单行
%% Row: 当前矩阵行 (如 [0,1,1])
%% Acc: {上一行的DP状态, 当前总计数}
process_row(Row, {PrevDP, TotalSum}) ->
    %% process_cells 参数: 
    %% 1. 当前矩阵行剩余元素
    %% 2. 上一行DP状态剩余元素
    %% 3. 左边的DP值 (Left)
    %% 4. 左上角的DP值 (TopLeft) - 注意：这其实是上一轮迭代的"Top"
    %% 5. 当前行DP状态累加器 (结果列表)
    %% 6. 当前行数值累加器
    {NewDP, RowSum} = process_cells(Row, PrevDP, 0, 0, [], 0),
    {NewDP, TotalSum + RowSum}.

%% 递归处理行内的单元格 (Base Case: 处理完毕)
process_cells([], [], _, _, DPAcc, SumAcc) ->
    %% 返回 {反转后的当前行DP列表, 当前行总和}
    {lists:reverse(DPAcc), SumAcc};

%% Case 1: 当前矩阵元素为 0
process_cells([0 | RestRow], [Top | RestPrevDP], _Left, _TopLeft, DPAcc, SumAcc) ->
    CurrentDP = 0,
    %% 递归调用：
    %% - Left 变为 0
    %% - TopLeft 变为当前的 Top (因为对于下一个元素来说，当前的 Top 就是它的 TopLeft)
    process_cells(RestRow, RestPrevDP, CurrentDP, Top, [CurrentDP | DPAcc], SumAcc);

%% Case 2: 当前矩阵元素为 1
process_cells([1 | RestRow], [Top | RestPrevDP], Left, TopLeft, DPAcc, SumAcc) ->
    %% DP方程: min(Top, Left, TopLeft) + 1
    CurrentDP = min(Top, min(Left, TopLeft)) + 1,
    %% 递归调用，累加 SumAcc
    process_cells(RestRow, RestPrevDP, CurrentDP, Top, [CurrentDP | DPAcc], SumAcc + CurrentDP).