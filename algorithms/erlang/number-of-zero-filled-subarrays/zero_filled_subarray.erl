-spec zero_filled_subarray(Nums :: [integer()]) -> integer().
zero_filled_subarray(Nums) ->
    %% 调用尾递归辅助函数
    %% 初始 CurrentStreak (当前连续0的个数) 为 0
    %% 初始 Total (总计数) 为 0
    count_zeros(Nums, 0, 0).

%% 辅助函数：列表为空，返回累计的总数
count_zeros([], _CurrentStreak, Total) ->
    Total;

%% 辅助函数：头部元素为 0
count_zeros([0 | Rest], CurrentStreak, Total) ->
    NewStreak = CurrentStreak + 1,
    %% 核心逻辑：Total 增加的数量等于当前的连续长度
    count_zeros(Rest, NewStreak, Total + NewStreak);

%% 辅助函数：头部元素不为 0
count_zeros([_ | Rest], _CurrentStreak, Total) ->
    %% 重置连续计数为 0，Total 保持不变
    count_zeros(Rest, 0, Total).