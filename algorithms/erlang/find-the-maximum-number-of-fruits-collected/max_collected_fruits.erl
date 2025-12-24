-spec max_collected_fruits(Fruits :: [[integer()]]) -> integer().
max_collected_fruits(Fruits) ->
    N = length(Fruits),
    % 优化：将列表列表转换为元组元组，以便在O(1)时间内访问矩阵元素
    % List access is O(N), making the algo O(N^3). Tuples make it O(N^2).
    Matrix = list_to_tuple([list_to_tuple(Row) || Row <- Fruits]),
    
    % 1. 计算孩子1的得分（固定走对角线）
    % 路径: (0,0) -> (1,1) -> ... -> (N-1, N-1)
    C1_Score = lists:sum([element(I, element(I, Matrix)) || I <- lists:seq(1, N)]),
    
    % 2. 计算孩子2（上三角）的最大得分
    % 起点: (0, N-1) [Erlang中为 (1, N)]
    % 状态: Row 1, Col N.
    Start2 = #{N => element(N, element(1, Matrix))},
    C2_Max = solve_child2(2, N, Matrix, Start2),
    
    % 3. 计算孩子3（下三角）的最大得分
    % 起点: (N-1, 0) [Erlang中为 (N, 1)]
    % 状态: Col 1, Row N.
    Start3 = #{N => element(1, element(N, Matrix))},
    C3_Max = solve_child3(2, N, Matrix, Start3),
    
    C1_Score + C2_Max + C3_Max.

%% ---------------------------------------------------------
%% 孩子2 DP 逻辑: 遍历行 (Row)，计算可能的列 (Col)
%% ---------------------------------------------------------
solve_child2(Row, N, _, AccMap) when Row > N ->
    % 最终汇聚点是 (N, N)，属于对角线，已被孩子1取走，故最后一步增益为0
    maps:get(N, AccMap, 0);
solve_child2(Row, N, Matrix, PrevMap) ->
    % 孩子2必须保持在对角线或右上方 (Col >= Row)
    % 且每步只能移动一格，所以有效列范围受限于之前的位置和当前行数
    % 有效范围: [max(Row, N - Row + 1), N]
    MinCol = max(Row, N - Row + 1),
    RowTuple = element(Row, Matrix),
    
    % 生成当前行的状态 Map
    NextMap = calc_next_step(MinCol, N, RowTuple, PrevMap, Row, child2),
    solve_child2(Row + 1, N, Matrix, NextMap).

%% ---------------------------------------------------------
%% 孩子3 DP 逻辑: 遍历列 (Col)，计算可能的行 (Row)
%% ---------------------------------------------------------
solve_child3(Col, N, _, AccMap) when Col > N ->
    maps:get(N, AccMap, 0);
solve_child3(Col, N, Matrix, PrevMap) ->
    % 孩子3必须保持在对角线或左下方 (Row >= Col)
    % 有效范围: [max(Col, N - Col + 1), N]
    MinRow = max(Col, N - Col + 1),
    
    % 生成当前列的状态 Map
    NextMap = calc_next_step(MinRow, N, Matrix, PrevMap, Col, child3),
    solve_child3(Col + 1, N, Matrix, NextMap).

%% ---------------------------------------------------------
%% 通用 DP 状态转移函数
%% ---------------------------------------------------------
calc_next_step(Min, Max, Source, PrevMap, CurrentIdx, Type) ->
    % 1. 计算每个位置的最大前驱值 (Max Previous Path)
    CandidateList = [
        begin
            % 前一步可能来自 index-1, index, index+1
            V1 = maps:get(Idx - 1, PrevMap, -1),
            V2 = maps:get(Idx, PrevMap, -1),
            V3 = maps:get(Idx + 1, PrevMap, -1),
            MaxPrev = max(V1, max(V2, V3)),
            {Idx, MaxPrev}
        end || Idx <- lists:seq(Min, Max)
    ],
    
    % 2. 加上当前格子的水果数（如果在对角线上则加0）
    maps:from_list([
        begin
            CurrentFruit = if
                Idx == CurrentIdx -> 0; % 对角线上的水果已被孩子1拿走
                Type == child2 -> element(Idx, Source); % Source是当前行Tuple
                Type == child3 -> element(CurrentIdx, element(Idx, Source)) % Source是整个Matrix, 取 Matrix[Row][Col]
            end,
            {Idx, MaxPrev + CurrentFruit}
        end
        || {Idx, MaxPrev} <- CandidateList, MaxPrev > -1 % 过滤掉不可达的路径
    ]).