-spec longest_subarray(Nums :: [integer()]) -> integer().

longest_subarray([]) -> 
    0;
longest_subarray([Head | Tail]) ->
    % 初始状态：
    % 当前最大值 = Head
    % 当前连续长度 = 1
    % 历史最长长度 = 1
    solve(Tail, Head, 1, 1).

%% 尾递归辅助函数
%% List: 剩余列表
%% MaxVal: 当前全局最大值
%% CurLen: 当前连续等于 MaxVal 的长度
%% BestLen: 记录的最长长度
solve([], _MaxVal, _CurLen, BestLen) ->
    BestLen;

solve([X | Rest], MaxVal, CurLen, BestLen) ->
    if
        % 情况 1: 发现了新的全局最大值
        X > MaxVal ->
            % 之前的统计全部作废，重新开始
            solve(Rest, X, 1, 1);

        % 情况 2: 当前元素等于最大值
        X == MaxVal ->
            NewCurLen = CurLen + 1,
            NewBestLen = erlang:max(BestLen, NewCurLen),
            solve(Rest, MaxVal, NewCurLen, NewBestLen);

        % 情况 3: 当前元素小于最大值
        X < MaxVal ->
            % 连续中断，CurLen 重置为 0，BestLen 保持不变
            solve(Rest, MaxVal, 0, BestLen)
    end.