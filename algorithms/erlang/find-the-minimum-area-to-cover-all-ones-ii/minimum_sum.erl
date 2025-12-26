-spec minimum_sum(Grid :: [[integer()]]) -> integer().
-define(INFINITY, 100000000).

minimum_sum(Grid) ->
    %% 1. 将 Grid 解析为坐标点列表 [{R, C}]
    Points = parse_grid(Grid),
    %% 2. 调用递归求解函数，寻找 3 个矩形的最小面积
    solve(Points, 3).

%% ---------------------------------------------------------
%% 核心递归函数：计算使用 K 个矩形覆盖 Points 的最小面积
%% ---------------------------------------------------------

%% 情况 1：没有点，不需要面积（虽然题目约束至少有 3 个 1，但在递归分割中可能出现空集）
%% 如果出现空集但要求 K >= 1，返回 0（或者视为无效路径，但在求最小和时 0 优于无效）
solve([], _K) -> 0;

%% 情况 2：只需要 1 个矩形，返回边界框面积
solve(Points, 1) ->
    calc_bbox_area(Points);

%% 情况 3：需要 K > 1 个矩形，尝试分割
solve(Points, K) ->
    %% 获取当前点集的行列范围，用于限制切割循环
    {MinR, MaxR, MinC, MaxC} = get_bounds(Points),
    
    %% 尝试所有水平切割 (按行切)
    %% 切割线 i 代表：Row <= i 分为一组，Row > i 分为一组
    %% 有效切割范围是从 MinR 到 MaxR - 1
    ResH = if MinR == MaxR -> ?INFINITY; %% 无法水平切割
              true ->
                  lists:foldl(fun(SplitRow, Acc) ->
                      {P1, P2} = split_points(Points, row, SplitRow),
                      %% 尝试组合：(1, K-1), (2, K-2)...
                      Val = try_combinations(P1, P2, K),
                      min(Acc, Val)
                  end, ?INFINITY, lists:seq(MinR, MaxR - 1))
           end,

    %% 尝试所有垂直切割 (按列切)
    ResV = if MinC == MaxC -> ?INFINITY; %% 无法垂直切割
              true ->
                  lists:foldl(fun(SplitCol, Acc) ->
                      {P1, P2} = split_points(Points, col, SplitCol),
                      Val = try_combinations(P1, P2, K),
                      min(Acc, Val)
                  end, ?INFINITY, lists:seq(MinC, MaxC - 1))
           end,

    min(ResH, ResV).

%% ---------------------------------------------------------
%% 辅助函数
%% ---------------------------------------------------------

%% 尝试分配 K 个矩形给两个分区 P1 和 P2
%% 只有 K=2 (1+1) 和 K=3 (1+2 或 2+1) 两种情况
try_combinations(P1, P2, K) ->
    %% 只要有一个分区为空且我们需要分配 >0 个矩形，这通常不是最优解或无效
    %% 但如果必须分配，我们利用 loops 1..K-1 来处理
    lists:foldl(fun(I, MinAcc) ->
        Area1 = solve(P1, I),
        Area2 = solve(P2, K - I),
        min(MinAcc, Area1 + Area2)
    end, ?INFINITY, lists:seq(1, K - 1)).

%% 根据行或列分割点集
split_points(Points, row, SplitIdx) ->
    lists:partition(fun({R, _}) -> R =< SplitIdx end, Points);
split_points(Points, col, SplitIdx) ->
    lists:partition(fun({_, C}) -> C =< SplitIdx end, Points).

%% 计算边界框面积
calc_bbox_area([]) -> 0;
calc_bbox_area(Points) ->
    {MinR, MaxR, MinC, MaxC} = get_bounds(Points),
    (MaxR - MinR + 1) * (MaxC - MinC + 1).

%% 获取点集的边界 {MinR, MaxR, MinC, MaxC}
get_bounds([{R, C} | Rest]) ->
    lists:foldl(fun({Rr, Cc}, {MinR, MaxR, MinC, MaxC}) ->
        {min(MinR, Rr), max(MaxR, Rr), min(MinC, Cc), max(MaxC, Cc)}
    end, {R, R, C, C}, Rest).

%% 解析 Grid 为点列表
parse_grid(Grid) ->
    {_, Points} = lists:foldl(fun(Row, {RIdx, Acc}) ->
        {_, RowPoints} = lists:foldl(fun(Val, {CIdx, PAcc}) ->
             NewPAcc = if Val == 1 -> [{RIdx, CIdx} | PAcc]; true -> PAcc end,
             {CIdx + 1, NewPAcc}
        end, {0, []}, Row),
        {RIdx + 1, RowPoints ++ Acc}
    end, {0, []}, Grid),
    Points.