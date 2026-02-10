-spec longest_balanced(Nums :: [integer()]) -> integer().
longest_balanced(Nums) ->
    % 开始外层循环，传入列表、剩余长度和当前最大值
    outer_loop(Nums, length(Nums), 0).

%% 外层循环：确定子数组的起始点
outer_loop(_, RemLen, Max) when RemLen =< Max ->
    % 剪枝：如果剩余元素的数量 <= 当前找到的最大长度，
    % 那么剩下的任何子数组都不可能比 Max 更长，直接返回结果。
    Max;
outer_loop([], _, Max) ->
    Max;
outer_loop([H|T], RemLen, Max) ->
    % 从当前元素 H 开始，进行内层扫描
    % 初始状态：
    % Distinct Even: 0, Distinct Odd: 0, Seen: #{}, CurrentLength: 0, LocalMax: 0
    LocalMax = inner_scan([H|T], 0, 0, #{}, 0, 0),
    
    % 更新全局 Max，并移动到下一个起始位置
    outer_loop(T, RemLen - 1, erlang:max(Max, LocalMax)).

%% 内层循环：从起始点向后扩展，统计 Distinct Even/Odd
inner_scan([], _EvenCnt, _OddCnt, _Seen, _Len, MaxInScan) ->
    MaxInScan;
inner_scan([Val|Rest], EvenCnt, OddCnt, Seen, Len, MaxInScan) ->
    case maps:is_key(Val, Seen) of
        true ->
            % 情况 A: 这个数字之前在当前子数组出现过
            % 不同的奇/偶数数量不变，长度 +1
            NewLen = Len + 1,
            % 如果之前的状态是平衡的，加上这个重复数字后依然平衡（因为 distinct 计数没变）
            NewMax = if EvenCnt == OddCnt -> erlang:max(MaxInScan, NewLen); 
                        true -> MaxInScan 
                     end,
            inner_scan(Rest, EvenCnt, OddCnt, Seen, NewLen, NewMax);
        false ->
            % 情况 B: 这是一个新的数字
            NewSeen = Seen#{Val => true},
            
            % 更新奇偶计数
            {NewEven, NewOdd} = case Val rem 2 of
                0 -> {EvenCnt + 1, OddCnt};
                _ -> {EvenCnt, OddCnt + 1}
            end,
            
            NewLen = Len + 1,
            % 检查是否平衡
            NewMax = if NewEven == NewOdd -> erlang:max(MaxInScan, NewLen);
                        true -> MaxInScan 
                     end,
            inner_scan(Rest, NewEven, NewOdd, NewSeen, NewLen, NewMax)
    end.