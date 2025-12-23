-spec number_of_paths(Grid :: [[integer()]], K :: integer()) -> integer().
-define(MOD, 1000000007).

number_of_paths(Grid, K) ->
    [Row1 | _] = Grid,
    Cols = length(Row1),
    
    % 初始化一个全0的余数列表 [0, 0, ..., 0] (长度为K)
    ZeroRemList = lists:duplicate(K, 0),
    
    % 初始化“上一行”的状态。
    % 逻辑上，第-1行全是0。
    % PrevRowDP 是一个列表，包含了每一列的余数状态列表。
    InitPrevRowDP = lists:duplicate(Cols, ZeroRemList),
    
    % 使用 foldl 逐行处理网格
    % {ResultRowDP, _} = lists:foldl(Fun, Acc, List)
    % 我们额外传递 RowIndex (通过累加器中的计数器) 来判断是否是第一行，或者直接通过逻辑判断 (0,0)
    
    {FinalRowDP, _} = lists:foldl(fun(CurrGridRow, {PrevRowDP, RowIdx}) ->
        NewRowDP = process_row(CurrGridRow, PrevRowDP, K, RowIdx, ZeroRemList),
        {NewRowDP, RowIdx + 1}
    end, {InitPrevRowDP, 0}, Grid),
    
    % 结果是最后一行，最后一列的余数为0的路径数
    LastColDP = lists:last(FinalRowDP),
    lists:nth(1, LastColDP). % Erlang列表索引从1开始，对应余数0

%% 处理单行
%% Returns: Current Row DP List (List of Remainder Lists)
process_row(GridRow, PrevRowDP, K, RowIdx, ZeroRemList) ->
    process_cols(GridRow, PrevRowDP, K, RowIdx, 0, ZeroRemList, []).

%% 逐列处理 (递归)
%% GridRowVals: 当前行的数值列表
%% TopDPs: 上一行对应的 DP 状态列表
%% ColIdx: 当前列索引
%% LeftDP: 左边格子的 DP 状态 (Accumulator)
%% AccRow: 构建当前行的结果 (逆序)
process_cols([], [], _K, _RowIdx, _ColIdx, _LeftDP, AccRow) ->
    lists:reverse(AccRow);
process_cols([Val | RestVals], [TopDP | RestTop], K, RowIdx, ColIdx, LeftDP, AccRow) ->
    % 1. 计算中间态 (Top + Left)
    % 如果是第一行(RowIdx=0)，TopDP其实全是0。
    % 如果是第一列(ColIdx=0)，LeftDP 其实全是0 (传入的初始LeftDP)。
    
    % 向量相加: (Top[r] + Left[r]) % MOD
    SummedDP = vector_add(TopDP, LeftDP),
    
    % 2. 特殊处理 (0,0) 起点
    % 逻辑上起点之前的路径和为0，计数为1。我们需要把这个 1 加到余数 0 的位置上。
    BaseDP = if 
        RowIdx =:= 0, ColIdx =:= 0 ->
            [H | T] = SummedDP,
            [(H + 1) rem ?MOD | T];
        true -> 
            SummedDP
    end,
    
    % 3. 根据当前格子数值 Val 进行移位 (Shift)
    % 新的余数 r_new = (r_old + Val) % K
    CurrentDP = shift_list(BaseDP, Val, K),
    
    process_cols(RestVals, RestTop, K, RowIdx, ColIdx + 1, CurrentDP, [CurrentDP | AccRow]).

%% 两个列表对应元素相加并取模
vector_add(List1, List2) ->
    [ (A + B) rem ?MOD || {A, B} <- lists:zip(List1, List2) ].

%% 循环移位列表
%% 如果当前数值是 Val，原来的余数 r 变成了 (r + Val) % K。
%% 这意味着原来的 counts 需要向右移动 Val % K 位。
%% 或者说：新列表 index i 的值来自旧列表的 index (i - Val) % K。
%% Erlang 的 lists:sublist 可以高效分割。
shift_list(List, Val, K) ->
    Shift = Val rem K,
    if
        Shift =:= 0 -> List;
        true ->
            % 比如 [a, b, c], K=3, Val=1 (Shift 1)
            % 余数0 <- 旧余数2 (c)
            % 余数1 <- 旧余数0 (a)
            % 余数2 <- 旧余数1 (b)
            % 结果 [c, a, b]
            % 这相当于把列表末尾的 Shift 个元素移到最前面。
            SplitIdx = K - Shift,
            {L1, L2} = lists:split(SplitIdx, List),
            L2 ++ L1
    end.