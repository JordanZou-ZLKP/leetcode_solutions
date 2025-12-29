-spec min_time(Skill :: [integer()], Mana :: [integer()]) -> integer().
min_time(Skill, Mana) ->
    % 1. 预计算技能的前缀和 (Prefix Sums)
    % 时间复杂度: O(N)
    PrefixSums = calc_prefix_sums(Skill),
    
    % 获取最后一个巫师的累计技能值 (P[n-1])，用于最后一步计算
    LastP = lists:last(PrefixSums),
    
    % 2. 遍历 Mana 列表计算药水间的最大延迟总和
    % 时间复杂度: O(M * N)
    TotalGap = sum_gaps(Mana, PrefixSums, 0),
    
    % 获取最后一瓶药水的 Mana
    LastMana = lists:last(Mana),
    
    % 3. 结果 = 延迟总和 + 最后一瓶药水的处理时间
    TotalGap + (LastMana * LastP).

%% ---------------------------------------------------------
%% 辅助函数
%% ---------------------------------------------------------

%% 计算前缀和列表
%% 输入: [1, 5, 2], 输出: [1, 6, 8]
calc_prefix_sums(List) ->
    lists:reverse(calc_prefix_sums(List, 0, [])).

calc_prefix_sums([], _Sum, Acc) ->
    Acc;
calc_prefix_sums([H|T], Sum, Acc) ->
    NewSum = Sum + H,
    calc_prefix_sums(T, NewSum, [NewSum | Acc]).

%% 计算所有药水之间的时间间隔总和
%% 遍历 Mana 列表，每次取相邻的两个 (PrevMana, CurrMana)
sum_gaps([M_prev, M_curr | Rest], PrefixSums, AccGap) ->
    % 计算当前两瓶药水之间的最大延迟
    Gap = find_max_gap(PrefixSums, 0, M_prev, M_curr, -1),
    sum_gaps([M_curr | Rest], PrefixSums, AccGap + Gap);
sum_gaps([_Last], _PrefixSums, AccGap) ->
    % 只有一瓶药水或已到达最后一瓶，递归结束
    AccGap.

%% 内层循环：找到限制最大的 Gap
%% 公式: max( P[i]*M_prev - P[i-1]*M_curr ) for all i
find_max_gap([], _, _, _, MaxVal) ->
    MaxVal;
find_max_gap([P_curr | RestP], P_prev, M_prev, M_curr, CurrentMax) ->
    % 计算当前巫师节点的限制
    Val = (P_curr * M_prev) - (P_prev * M_curr),
    
    % 更新最大值
    NewMax = if 
        Val > CurrentMax -> Val;
        true -> CurrentMax
    end,
    
    find_max_gap(RestP, P_curr, M_prev, M_curr, NewMax).