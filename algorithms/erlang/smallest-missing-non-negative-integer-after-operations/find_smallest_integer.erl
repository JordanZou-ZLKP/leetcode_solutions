-spec find_smallest_integer(Nums :: [integer()], Value :: integer()) -> integer().
find_smallest_integer(Nums, Value) ->
    % 步骤 1: 统计每个余数的频率 (Frequency Map)
    % 注意 Erlang 的 rem 操作符对负数会保留负号（例如 -10 rem 3 = -1），
    % 我们需要数学意义上的模运算（((N % V) + V) % V）。
    Counts = lists:foldl(fun(N, Acc) ->
        Rem = ((N rem Value) + Value) rem Value,
        maps:update_with(Rem, fun(C) -> C + 1 end, 1, Acc)
    end, #{}, Nums),

    % 步骤 2: 遍历余数 0 到 Value-1，找出最小的缺失值
    find_min_missing(0, Value, Counts, undefined).

%% 递归寻找最小的缺失值
find_min_missing(R, Value, _Counts, MinMex) when R == Value ->
    % 遍历完所有可能的余数，返回找到的最小值
    MinMex;
find_min_missing(R, Value, Counts, MinMex) ->
    % 获取当前余数 R 拥有的数字个数
    Count = maps:get(R, Counts, 0),
    
    % 当前余数 R 这一组能构成的数字是 R, R+V, R+2V...
    % 因此这一组缺失的第一个数字是 R + Count * Value
    CurrentLimit = R + Count * Value,
    
    % 更新全局最小缺失值
    NewMin = case MinMex of
        undefined -> CurrentLimit;
        V when CurrentLimit < V -> CurrentLimit;
        V -> V
    end,
    
    % 剪枝优化：
    % 下一轮循环的余数是 R+1。这意味着下一轮哪怕 Count 为 0，
    % 产生的缺失值至少也是 R+1。
    % 如果我们当前的 NewMin 已经小于 R+1，那么后面的循环不可能产生更小的结果了。
    if 
        NewMin < R + 1 -> NewMin;
        true -> find_min_missing(R + 1, Value, Counts, NewMin)
    end.