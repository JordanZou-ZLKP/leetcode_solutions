-spec max_side_length(Mat :: [[integer()]], Threshold :: integer()) -> integer().
max_side_length(Mat, Threshold) ->
    M = length(Mat),
    N = length(hd(Mat)),
    
    %% 1. 构建二维前缀和矩阵
    %% 结果是一个元组的元组 (Tuple of Tuples)，支持 O(1) 访问
    %% P[i][j] 代表矩阵左上角 (0,0) 到 (i-1, j-1) 的矩形和
    PrefixSumList = build_prefix_sum(Mat, N),
    PrefixSumTuple = list_to_tuple([list_to_tuple(Row) || Row <- PrefixSumList]),
    
    %% 2. 二分查找最大边长
    %% 范围 [0, min(M, N)]
    binary_search(PrefixSumTuple, Threshold, M, N, 0, min(M, N), 0).

%% ============================================================
%% 二分查找逻辑
%% ============================================================
binary_search(_P, _T, _M, _N, Low, High, Ans) when Low > High ->
    Ans;
binary_search(P, Threshold, M, N, Low, High, Ans) ->
    Mid = (Low + High) div 2,
    case has_valid_square(P, Threshold, M, N, Mid) of
        true ->
            %% 找到可行解，尝试更大的边长
            binary_search(P, Threshold, M, N, Mid + 1, High, Mid);
        false ->
            %% 不可行，尝试更小的边长
            binary_search(P, Threshold, M, N, Low, Mid - 1, Ans)
    end.

%% ============================================================
%% 检查是否存在合法正方形
%% ============================================================
has_valid_square(_P, _Threshold, _M, _N, 0) -> 
    true;
has_valid_square(P, Threshold, M, N, Len) ->
    %% 遍历所有可能的左上角 (R, C)
    check_squares(P, Threshold, M, N, Len, 0, 0).

check_squares(_P, _Threshold, M, _N, Len, R, _C) when R > M - Len ->
    false; %% 遍历完所有行，未找到
check_squares(P, Threshold, M, N, Len, R, C) when C > N - Len ->
    check_squares(P, Threshold, M, N, Len, R + 1, 0); %% 换行
check_squares(P, Threshold, M, N, Len, R, C) ->
    %% 计算区域和：Sum = P[r2][c2] - P[r1][c2] - P[r2][c1] + P[r1][c1]
    %% 注意：PrefixSumTuple 是 1-based 索引，且包含 padding
    %% 逻辑坐标 i 对应 tuple 索引 i + 1
    
    R1 = R + 1,       C1 = C + 1,
    R2 = R + Len + 1, C2 = C + Len + 1,
    
    %% 获取 Tuple 中的行
    RowLow = element(R1, P),
    RowHigh = element(R2, P),
    
    %% 获取四个角的值
    Val1 = element(C2, RowHigh), %% 右下
    Val2 = element(C2, RowLow),  %% 右上
    Val3 = element(C1, RowHigh), %% 左下
    Val4 = element(C1, RowLow),  %% 左上
    
    Sum = Val1 - Val2 - Val3 + Val4,
    
    if 
        Sum =< Threshold -> true;
        true -> check_squares(P, Threshold, M, N, Len, R, C + 1)
    end.

%% ============================================================
%% 构建前缀和矩阵 (修复了重复定义的问题)
%% ============================================================
build_prefix_sum(Mat, N) ->
    %% 初始化第 0 行 (全是 0)
    ZeroRow = lists:duplicate(N + 1, 0),
    %% 递归扫描矩阵生成前缀和
    scan_matrix(Mat, ZeroRow, [ZeroRow]).

%% scan_matrix 负责行级遍历
scan_matrix([], _PrevP, Acc) ->
    lists:reverse(Acc);
scan_matrix([Row | RestMat], PrevP, Acc) ->
    %% 计算当前行的前缀和
    %% PrevP 的长度是 N+1 (包含开头的0)
    %% Row 的长度是 N
    %% 我们需要将 Row[i] 与 PrevP[i+1] 对齐（即上一行同一列的累积值）
    %% 因此传递 tl(PrevP) 给 calc_row
    CurrP = calc_row(Row, tl(PrevP), 0, [0]),
    scan_matrix(RestMat, CurrP, [CurrP | Acc]).

%% calc_row 负责列级计算 (修复：这是一个单独的递归函数)
%% Row: 当前行的原始数值列表
%% PrevCols: 上一行对应列的前缀和列表
%% RunningSum: 当前行从左到右的累加和
%% Acc: 结果累加器
calc_row([], [], _RunningSum, Acc) ->
    lists:reverse(Acc);
calc_row([Val | RestVals], [PrevVal | RestPrev], RunningSum, Acc) ->
    NewRunningSum = RunningSum + Val,
    %% P[i][j] = P[i-1][j] (PrevVal) + 当前行累加和 (NewRunningSum)
    NewVal = PrevVal + NewRunningSum,
    calc_row(RestVals, RestPrev, NewRunningSum, [NewVal | Acc]).