-spec max_area(Height :: [integer()]) -> integer().
max_area(Height) ->
    %% 1. 将列表转换为元组，以实现 O(1) 的随机访问
    %% List Access: O(N) -> Tuple Access: O(1)
    H_Tuple = list_to_tuple(Height),
    N = tuple_size(H_Tuple),
    
    %% 2. 启动双指针递归
    %% Left 指针从 1 开始 (Erlang 索引从 1 开始)
    %% Right 指针从 N 开始
    two_pointers(H_Tuple, 1, N, 0).

%% 尾递归函数实现双指针逻辑
two_pointers(_Tuple, Left, Right, MaxArea) when Left >= Right ->
    %% 基本情况：指针相遇，返回最大面积
    MaxArea;

two_pointers(Tuple, Left, Right, MaxArea) ->
    %% 获取左右两边的高度
    H_Left = element(Left, Tuple),
    H_Right = element(Right, Tuple),
    
    %% 计算当前面积：min(H_Left, H_Right) * (Right - Left)
    CurrentArea = min(H_Left, H_Right) * (Right - Left),
    
    %% 更新最大面积
    NewMaxArea = max(MaxArea, CurrentArea),
    
    %% 移动指针策略：
    %% 总是移动较短的那根柱子，试图找到更高的柱子以获得更大面积。
    if
        H_Left < H_Right ->
            two_pointers(Tuple, Left + 1, Right, NewMaxArea);
        true ->
            two_pointers(Tuple, Left, Right - 1, NewMaxArea)
    end.

%% 辅助函数
min(A, B) when A < B -> A;
min(_, B) -> B.

max(A, B) when A > B -> A;
max(_, B) -> B.