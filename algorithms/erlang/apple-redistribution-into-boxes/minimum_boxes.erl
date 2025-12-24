-spec minimum_boxes(Apple :: [integer()], Capacity :: [integer()]) -> integer().
minimum_boxes(Apple, Capacity) ->
    % 1. 计算苹果总数 (O(N))
    TotalApples = lists:sum(Apple),
    
    % 2. 对箱子容量进行降序排序 (O(M log M))
    % Erlang 的 lists:sort 是升序，所以我们需要反转结果
    SortedCapacity = lists:reverse(lists:sort(Capacity)),
    
    % 3. 贪心选择箱子 (O(M))
    select_boxes(TotalApples, SortedCapacity, 0).

%% 递归函数：选择箱子
%% Base Case: 如果剩余需要的苹果数 <= 0，说明已经装完了，返回计数
select_boxes(RemApples, _, Count) when RemApples =< 0 ->
    Count;

%% Recursive Step: 还有苹果没装完，取当前最大的箱子 (H)
select_boxes(RemApples, [H | T], Count) ->
    % 减去当前箱子的容量，计数+1，继续递归
    select_boxes(RemApples - H, T, Count + 1).