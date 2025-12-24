-spec count_max_or_subsets(Nums :: [integer()]) -> integer().
count_max_or_subsets(Nums) ->

    % 1. 计算所有元素 OR 的总和，这就是理论上的最大 OR 值
    MaxOr = lists:foldl(fun(X, Acc) -> X bor Acc end, 0, Nums),
    
    % 2. 开始递归搜索 (当前索引的列表, 当前 OR 值, 目标 OR 值)
    dfs(Nums, 0, MaxOr).

%% 优化分支 (剪枝):
%% 如果当前的 CurrentOr 已经达到了 MaxOr，
%% 那么剩余列表 Nums 中的任何子集组合（包括空集）与当前已选集合合并，
%% 其 OR 结果依然是 MaxOr。
%% 剩余 Nums 的长度为 L，则有 2^L 种组合。
dfs(Nums, CurrentOr, MaxOr) when CurrentOr =:= MaxOr ->
    Length = length(Nums),
    % 使用位移操作计算 2 的 Length 次方 (1 << Length)
    1 bsl Length;

%% 基本情况:
%% 列表为空，且 CurrentOr 不等于 MaxOr (因为等于的情况会被上面的子句捕获)
dfs([], _CurrentOr, _MaxOr) ->
    0;

%% 递归步骤:
%% 尝试 "选择" 和 "不选择" 当前头部元素 H
dfs([H | T], CurrentOr, MaxOr) ->
    % 分支 1: 选择 H (更新 CurrentOr)
    IncludeCount = dfs(T, CurrentOr bor H, MaxOr),
    
    % 分支 2: 不选择 H (CurrentOr 保持不变)
    ExcludeCount = dfs(T, CurrentOr, MaxOr),
    
    % 返回两个分支的总和
    IncludeCount + ExcludeCount.