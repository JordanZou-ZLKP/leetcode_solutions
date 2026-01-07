-spec search(Nums :: [integer()], Target :: integer()) -> integer().
search(Nums, Target) ->
    % 1. 将列表转换为元组以支持 O(1) 的随机访问
    % 注意：Erlang 元组索引从 1 开始，题目要求返回 0-based 索引
    Tuple = list_to_tuple(Nums),
    binary_search(Tuple, Target, 1, tuple_size(Tuple)).

%% ---------------------------------------------------------
%% Recursive Binary Search Logic
%% Tuple: 数据源
%% Target: 目标值
%% Low, High: 当前搜索区间的左右边界 (1-based indices)
%% ---------------------------------------------------------
binary_search(_Tuple, _Target, Low, High) when Low > High ->
    -1; % 搜索区间为空，未找到

binary_search(Tuple, Target, Low, High) ->
    Mid = (Low + High) div 2,
    MidVal = element(Mid, Tuple),
    
    if
        MidVal =:= Target ->
            Mid - 1; % 找到目标，转换为 0-based 索引返回
        true ->
            LowVal = element(Low, Tuple),
            HighVal = element(High, Tuple),
            
            % 判断哪一半是有序的
            IsLeftSorted = LowVal =< MidVal,
            
            if
                IsLeftSorted ->
                    % 左半部分 [Low...Mid] 是有序的
                    % 检查 Target 是否在左半部分范围内
                    if
                        LowVal =< Target, Target < MidVal ->
                            % Target 在左侧，向左递归
                            binary_search(Tuple, Target, Low, Mid - 1);
                        true ->
                            % Target 不在左侧，向右递归
                            binary_search(Tuple, Target, Mid + 1, High)
                    end;
                true ->
                    % 右半部分 [Mid...High] 是有序的
                    % 检查 Target 是否在右半部分范围内
                    if
                        MidVal < Target, Target =< HighVal ->
                            % Target 在右侧，向右递归
                            binary_search(Tuple, Target, Mid + 1, High);
                        true ->
                            % Target 不在右侧，向左递归
                            binary_search(Tuple, Target, Low, Mid - 1)
                    end
            end
    end.
