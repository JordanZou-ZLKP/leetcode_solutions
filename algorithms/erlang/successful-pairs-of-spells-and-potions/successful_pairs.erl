-spec successful_pairs(Spells :: [integer()], Potions :: [integer()], Success :: integer()) -> [integer()].
successful_pairs(Spells, Potions, Success) ->
    % 1. 对 Potions 进行排序，复杂度 O(M log M)
    SortedPotions = lists:sort(Potions),
    
    % 2. 将列表转换为 Tuple，以便在二分查找中进行 O(1) 的随机访问。
    %    Erlang 的 list 是链表，不支持快速索引访问。
    M = length(SortedPotions),
    PotionTuple = list_to_tuple(SortedPotions),
    
    % 3. 对每个 Spell 计算符合条件的数量
    [count_valid_potions(S, PotionTuple, M, Success) || S <- Spells].

%% 计算单个 Spell 能组成的成功组合数
count_valid_potions(Spell, PotionTuple, M, Success) ->
    % 计算所需的最小 Potion 值。
    % 向上取整公式: ceil(A / B) = (A + B - 1) div B
    MinPotionNeeded = (Success + Spell - 1) div Spell,
    
    % 使用二分查找找到第一个满足 >= MinPotionNeeded 的索引
    Index = lower_bound(PotionTuple, MinPotionNeeded, 1, M),
    
    % 如果 Index > M，说明没有药水符合条件，结果为 0
    % 否则，从 Index 到 M 的所有药水都符合条件
    if 
        Index > M -> 0;
        true -> M - Index + 1
    end.

%% 二分查找 (Lower Bound)
%% 在 Tuple 中查找第一个 >= Target 的元素的索引
%% 如果所有元素都小于 Target，返回 High + 1
lower_bound(Tuple, Target, Low, High) ->
    if
        Low > High -> 
            Low; % 搜索结束，Low 即为插入位置（即第一个满足条件的索引）
        true ->
            Mid = Low + (High - Low) div 2,
            MidVal = element(Mid, Tuple),
            if
                MidVal >= Target ->
                    % 找到可能的解，尝试向左收缩以寻找更靠前的解
                    lower_bound(Tuple, Target, Low, Mid - 1);
                true ->
                    % 当前值太小，必须向右搜索
                    lower_bound(Tuple, Target, Mid + 1, High)
            end
    end.