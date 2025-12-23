-spec min_deletion_size(Strs :: [unicode:unicode_binary()]) -> integer().

to_list(Ones) ->
    R = [binary_to_list(One) || One <- Ones].

min_deletion_size(Ones) ->
    Strs = to_list(Ones),
    N = length(Strs),
    M = length(hd(Strs)),
    
    %% 预处理每一列的 GtMask 和 EqMask
    %% Complexity: O(N * M)
    ColMasks = preprocess_cols(Strs, N, M),
    
    %% 初始掩码：所有相邻行最初都被视为相等 (所有位为 1)
    %% 掩码长度为 N-1 (对应 row 0..N-2 与 row 1..N-1 的比较)
    InitialMask = if N > 1 -> (1 bsl (N - 1)) - 1; true -> 0 end,
    
    %% 使用 ETS 表进行记忆化 (Memoization)
    Tab = ets:new(memo, [set, private]),
    
    try
        MaxKept = solve(0, InitialMask, ColMasks, M, Tab),
        M - MaxKept
    after
        ets:delete(Tab)
    end.

%% 核心递归函数 (带记忆化)
%% ColIdx: 当前处理的列索引
%% Mask: 当前的相等关系掩码
%% ColMasks: 预处理好的列特征列表
%% TotalCols: 总列数
%% Tab: ETS 表
solve(ColIdx, _Mask, _ColMasks, TotalCols, _Tab) when ColIdx == TotalCols ->
    0;
solve(ColIdx, Mask, ColMasks, TotalCols, Tab) ->
    Key = {ColIdx, Mask},
    case ets:lookup(Tab, Key) of
        [{_, Val}] -> Val;
        [] ->
            %% 取出当前列的预处理掩码
            {Gt, Eq} = lists:nth(ColIdx + 1, ColMasks),
            
            %% 选项 1: 删除当前列 (Skip)
            SkipRes = solve(ColIdx + 1, Mask, ColMasks, TotalCols, Tab),
            
            %% 选项 2: 保留当前列 (Keep)
            %% 只有当当前列不违反任何当前仍需保持顺序的行对时，才能保留
            %% 即: 对于所有 Mask 为 1 的位，Gt 必须为 0
            KeepRes = if (Mask band Gt) == 0 ->
                            NewMask = Mask band Eq,
                            1 + solve(ColIdx + 1, NewMask, ColMasks, TotalCols, Tab);
                        true ->
                            -1 %% 无法保留
                      end,
            
            Result = max(SkipRes, KeepRes),
            ets:insert(Tab, {Key, Result}),
            Result
    end.

%% 预处理：将字符串列表转化为列的掩码列表
preprocess_cols(Strs, N, M) ->
    %% 将字符串列表转换为元组列表，以便 O(1) 访问
    Rows = [list_to_tuple(S) || S <- Strs],
    
    %% 生成每一列的 {GtMask, EqMask}
    [generate_col_mask(ColIdx, Rows, N) || ColIdx <- lists:seq(1, M)].

generate_col_mask(ColIdx, Rows, N) ->
    generate_col_mask(0, ColIdx, Rows, N, 0, 0).

generate_col_mask(RowIdx, _ColIdx, _Rows, N, AccGt, AccEq) when RowIdx == N - 1 ->
    {AccGt, AccEq};
generate_col_mask(RowIdx, ColIdx, Rows, N, AccGt, AccEq) ->
    RowA = lists:nth(RowIdx + 1, Rows),
    RowB = lists:nth(RowIdx + 2, Rows),
    CharA = element(ColIdx, RowA),
    CharB = element(ColIdx, RowB),
    
    {NewGt, NewEq} = if 
        CharA > CharB -> {AccGt bor (1 bsl RowIdx), AccEq};
        CharA == CharB -> {AccGt, AccEq bor (1 bsl RowIdx)};
        true -> {AccGt, AccEq} %% CharA < CharB
    end,
    generate_col_mask(RowIdx + 1, ColIdx, Rows, N, NewGt, NewEq).