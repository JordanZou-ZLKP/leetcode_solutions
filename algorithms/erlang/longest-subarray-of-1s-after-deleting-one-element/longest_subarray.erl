-spec longest_subarray(Nums :: [integer()]) -> integer().
longest_subarray(Nums) ->
    solve(Nums, 0, 0, 0, false).

%% @doc
%% Tail recursive helper function.
%% List: Remaining list to process
%% Pre: Count of 1s before the last encountered 0
%% Cur: Count of current consecutive 1s
%% Max: Maximum length found so far
%% HasZero: Boolean flag to track if we have seen any 0
solve([1 | T], Pre, Cur, Max, HasZero) ->
    % 遇到 1：当前计数 Cur 加 1
    solve(T, Pre, Cur + 1, Max, HasZero);

solve([0 | T], Pre, Cur, Max, _HasZero) ->
    % 遇到 0：
    % 1. 计算当前这一段（跨越这个 0）的长度：Pre + Cur
    % 2. 更新 Max
    % 3. 下一轮的 Pre 变为当前的 Cur（因为当前的 0 被删除了，它连接了前后的 1）
    % 4. Cur 重置为 0
    % 5. 标记 HasZero 为 true
    NewMax = erlang:max(Max, Pre + Cur),
    solve(T, Cur, 0, NewMax, true);

solve([], Pre, Cur, Max, HasZero) ->
    % 列表遍历结束
    % 计算最后一段可能的长度
    FinalMax = erlang:max(Max, Pre + Cur),
    
    case HasZero of
        true -> 
            % 如果列表中包含 0，我们删除那个 0 得到的就是 FinalMax
            FinalMax;
        false -> 
            % 如果列表中全都是 1，根据题意必须删除一个元素
            % 所以结果是总长度减 1
            Cur - 1
    end.