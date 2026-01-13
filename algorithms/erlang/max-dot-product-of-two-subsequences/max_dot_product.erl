-spec max_dot_product(Nums1 :: [integer()], Nums2 :: [integer()]) -> integer().

-define(INF, -1000000000). % 定义一个足够小的负数作为初始值

max_dot_product(Nums1, Nums2) ->
    M = length(Nums2),
    %% 初始化第一行之前的状态为负无穷
    InitRow = lists:duplicate(M, ?INF),
    
    %% 使用 foldl 遍历 Nums1 (相当于外层循环 i)
    %% AccRow 代表上一行的 DP 状态 (dp[i-1])
    FinalRow = lists:foldl(fun(X, PrevRow) ->
        process_row(X, Nums2, PrevRow, ?INF, ?INF, [])
    end, InitRow, Nums1),
    
    %% 结果为最后一行最右侧的值
    lists:last(FinalRow).

%% @doc 处理单行数据 (相当于内层循环 j)
%% 参数说明:
%% X: Nums1 当前遍历的元素 (nums1[i])
%% [Y|RestYs]: Nums2 当前遍历的列表
%% [Up|RestUp]: 上一行对应位置的值 (相当于 dp[i-1][j])
%% Diag: 左上角的值 (相当于 dp[i-1][j-1])
%% Left: 左边的值 (相当于 dp[i][j-1])
%% Acc: 正在构建的当前行结果
process_row(_X, [], [], _Diag, _Left, Acc) ->
    lists:reverse(Acc); % 构建完成，反转列表
process_row(X, [Y | RestYs], [Up | RestUp], Diag, Left, Acc) ->
    Product = X * Y,
    
    %% 计算四种情况的最大值
    %% 1. Product: 放弃之前的积累，仅取当前两个数的积 (应对之前结果为负的情况)
    %% 2. Product + Diag: 延续之前的子序列
    %% 3. Up: 放弃 X，继承 nums1[i-1] 的结果
    %% 4. Left: 放弃 Y，继承 nums2[j-1] 的结果
    
    Option2 = if Diag =:= ?INF -> ?INF; true -> Product + Diag end,
    
    CurrentVal = max4(Product, Option2, Up, Left),
    
    %% 递归处理下一个元素
    %% 关键点：当前的 Up (dp[i-1][j]) 将成为下一个位置的 Diag (dp[i-1][j-1])
    %% 当前计算出的 CurrentVal 将成为下一个位置的 Left
    process_row(X, RestYs, RestUp, Up, CurrentVal, [CurrentVal | Acc]).

%% @doc 辅助函数：求四个数的最大值
max4(A, B, C, D) ->
    max(A, max(B, max(C, D))).