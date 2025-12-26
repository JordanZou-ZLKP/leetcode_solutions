-spec best_closing_time(Customers :: unicode:unicode_binary()) -> integer().
best_closing_time(One) ->
    Customers = binary_to_list(One),
    % 第一步：计算第 0 小时关门的初始惩罚 (即所有 'Y' 的总数)
    % 时间复杂度: O(N)
    InitialPenalty = count_total_y(Customers, 0),
    
    % 第二步：遍历并寻找最小惩罚
    % CurrentHour 从 1 开始尝试 (因为我们已经有了 0 的结果)
    % 时间复杂度: O(N)
    find_best(Customers, 1, InitialPenalty, InitialPenalty, 0).

%% 辅助函数：计算列表中 'Y' 的总数
count_total_y([], Count) -> 
    Count;
count_total_y([$Y | Rest], Count) -> 
    count_total_y(Rest, Count + 1);
count_total_y([_ | Rest], Count) -> 
    count_total_y(Rest, Count).

%% 核心递归逻辑
%% List: 剩余的客户日志
%% NextHour: 当前正在考虑的关门时间 (1, 2, 3...)
%% CurrentPenalty: 上一时刻的惩罚值
%% MinPenalty: 目前为止发现的最小惩罚
%% BestHour: 目前为止最小惩罚对应的最早时间
find_best([], _, _, _, BestHour) ->
    BestHour;
find_best([Char | Rest], NextHour, CurrentPenalty, MinPenalty, BestHour) ->
    % 根据当前字符计算新的惩罚值
    % 如果是 'Y': 从关门变为开门，减少了一个未接待客户的惩罚 (-1)
    % 如果是 'N': 从关门变为开门，增加了一个空闲时间的惩罚 (+1)
    NewPenalty = case Char of
        $Y -> CurrentPenalty - 1;
        $N -> CurrentPenalty + 1
    end,

    % 检查是否找到了更优解
    % 注意：只有当 NewPenalty < MinPenalty (严格小于) 时才更新
    % 这保证了如果有多个相同的最小惩罚，我们保留最早的那个 (即保持旧的 BestHour)
    {NewMin, NewBestHour} = if
        NewPenalty < MinPenalty -> {NewPenalty, NextHour};
        true -> {MinPenalty, BestHour}
    end,

    % 尾递归处理下一个字符
    find_best(Rest, NextHour + 1, NewPenalty, NewMin, NewBestHour).