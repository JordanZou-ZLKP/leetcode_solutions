-spec total_fruit(Fruits :: [integer()]) -> integer().
total_fruit(Fruits) ->
% 1. 将列表转换为 Tuple 以便实现 O(1) 的随机访问 (模拟数组)
    FruitsT = list_to_tuple(Fruits),
    N = tuple_size(FruitsT),
    
    % 2. 启动滑动窗口递归
    % 参数: Left, Right, Tuple, Map(Counter), CurrentMax, TotalLength
    sliding_window(1, 1, FruitsT, #{}, 0, N).

%% ---------------------------------------------------------
%% 主递归循环 (移动 Right 指针)
%% ---------------------------------------------------------
sliding_window(_Left, Right, _FruitsT, _Map, MaxLen, N) when Right > N ->
    % 遍历结束，返回最大长度
    MaxLen;
sliding_window(Left, Right, FruitsT, Map, MaxLen, N) ->
    % --- Step 1: 扩张窗口 (加入 Right 对应的水果) ---
    FruitIn = element(Right, FruitsT),
    NewMap = update_counter(FruitIn, 1, Map),
    
    % --- Step 2: 收缩窗口 (如果种类 > 2) ---
    % 注意：Erlang 中 map_size 是 O(1) 操作
    {FinalLeft, FinalMap} = case map_size(NewMap) > 2 of
        true ->
            shrink_window(Left, FruitsT, NewMap);
        false ->
            {Left, NewMap}
    end,
    
    % --- Step 3: 计算当前长度并更新最大值 ---
    CurrentLen = Right - FinalLeft + 1,
    NewMax = max(MaxLen, CurrentLen),
    
    % 继续处理下一个位置
    sliding_window(FinalLeft, Right + 1, FruitsT, FinalMap, NewMax, N).

%% ---------------------------------------------------------
%% 辅助函数：收缩窗口 (移动 Left 指针)
%% 直到 Map 中原本的种类数量 <= 2
%% ---------------------------------------------------------
shrink_window(Left, FruitsT, Map) ->
    % 只有当 map_size > 2 时才会进入此逻辑
    % 移除 Left 指向的水果
    FruitOut = element(Left, FruitsT),
    Map1 = update_counter(FruitOut, -1, Map),
    
    % 如果移除后 map_size 依然 > 2，继续收缩 (实际上本题逻辑每次只加1个，这里递归稍微多余但逻辑严密)
    % 优化：题目逻辑保证每次 Right 加一个最多导致 size 变成 3，
    % 这里只需要 while (size > 2) shrink。
    case map_size(Map1) > 2 of
        true -> 
            shrink_window(Left + 1, FruitsT, Map1);
        false -> 
            {Left + 1, Map1}
    end.

%% ---------------------------------------------------------
%% 辅助函数：更新 Map 计数
%% Val 可以是 1 (增加) 或 -1 (减少)
%% ---------------------------------------------------------
update_counter(Key, Val, Map) ->
    OldCount = maps:get(Key, Map, 0),
    NewCount = OldCount + Val,
    if
        NewCount =< 0 -> maps:remove(Key, Map);
        true -> maps:put(Key, NewCount, Map)
    end.