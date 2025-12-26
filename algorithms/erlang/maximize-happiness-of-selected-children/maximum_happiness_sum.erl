-spec maximum_happiness_sum(Happiness :: [integer()], K :: integer()) -> integer().
maximum_happiness_sum(Happiness, K) ->
    % 1. 对列表进行排序。
    % lists:sort/1 默认是升序，我们通过 lists:reverse/1 将其转换为降序。
    % 时间复杂度: O(N * log N)
    SortedHappiness = lists:reverse(lists:sort(Happiness)),
    
    % 2. 递归计算前 K 个最大的值，考虑每轮的衰减
    calculate_sum(SortedHappiness, K, 0, 0).

%% @private
%% 递归函数参数说明：
%% List: 剩余的幸福值列表（已降序）
%% K: 还需要选择的孩子数量
%% Turn: 当前是第几轮（对应需要减去的值）
%% Acc: 当前累加的总和
calculate_sum([], _K, _Turn, Acc) ->
    Acc;
calculate_sum(_List, 0, _Turn, Acc) ->
    Acc;
calculate_sum([H | T], K, Turn, Acc) ->
    % 计算当前孩子在当前轮次下的实际幸福值
    CurrentVal = H - Turn,
    
    if
        CurrentVal > 0 ->
            % 如果当前值减去轮次后仍大于0，累加并继续
            calculate_sum(T, K - 1, Turn + 1, Acc + CurrentVal);
        true ->
            % 优化：如果当前最大的值减去轮次已经 <= 0，
            % 那么后续更小的值减去更大的轮次必然也 <= 0。
            % 直接返回当前累加值，不再继续遍历。
            Acc
    end.