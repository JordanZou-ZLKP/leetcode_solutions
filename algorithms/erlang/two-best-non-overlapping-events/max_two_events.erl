-spec max_two_events(Events :: [[integer()]]) -> integer().

max_two_events(Events) ->
    % 1. 按照开始时间对事件进行排序。
    % Erlang 的 lists:sort 默认对列表的第一个元素（Start Time）进行排序。
    SortedEvents = lists:sort(Events),
    N = length(SortedEvents),

    % 2. 将列表转换为 Tuple，以便在二分查找和后缀查询中进行 O(1) 的随机访问。
    EventsT = list_to_tuple(SortedEvents),

    % 3. 预处理后缀最大值 (Suffix Max)。
    % SuffixMaxT 的第 i 个元素表示从第 i 个事件到第 N 个事件中的最大 Value。
    SuffixMaxT = build_suffix_max(EventsT, N),

    % 4. 遍历所有事件，计算最大收益。
    find_max_sum(1, N, EventsT, SuffixMaxT, 0).

%% ---------------------------------------------------------
%% 辅助函数：构建后缀最大值 Tuple
%% ---------------------------------------------------------
build_suffix_max(EventsT, N) ->
    % 从后往前遍历，构建最大值列表，最后转为 Tuple
    do_build_suffix(N, EventsT, 0, []).

do_build_suffix(0, _EventsT, _CurrentMax, Acc) ->
    list_to_tuple(Acc);
do_build_suffix(Idx, EventsT, CurrentMax, Acc) ->
    [_, _, Val] = element(Idx, EventsT),
    NewMax = max(Val, CurrentMax),
    % 将 NewMax 加到列表头部，这样最终得到的列表顺序是 1..N
    do_build_suffix(Idx - 1, EventsT, NewMax, [NewMax | Acc]).

%% ---------------------------------------------------------
%% 辅助函数：主循环，寻找最大收益
%% ---------------------------------------------------------
find_max_sum(Idx, N, _EventsT, _SuffixMaxT, MaxVal) when Idx > N ->
    MaxVal;
find_max_sum(Idx, N, EventsT, SuffixMaxT, CurrentMax) ->
    [_, End, Val] = element(Idx, EventsT),
    
    % 寻找下一个不重叠的事件。
    % 下一个事件的开始时间必须 > 当前事件的结束时间 (End)。
    % 即 next_start >= End + 1
    TargetStart = End + 1,
    
    % 在区间 [Idx + 1, N] 中二分查找第一个 StartTime >= TargetStart 的索引
    NextIdx = binary_search(TargetStart, EventsT, Idx + 1, N),
    
    % 如果找到了合法的下一个事件，取其后缀最大值；否则第二个事件价值为 0
    Val2 = case NextIdx of
        not_found -> 0;
        _ -> element(NextIdx, SuffixMaxT)
    end,
    
    NewTotal = Val + Val2,
    find_max_sum(Idx + 1, N, EventsT, SuffixMaxT, max(CurrentMax, NewTotal)).

%% ---------------------------------------------------------
%% 辅助函数：二分查找 (Binary Search)
%% 寻找第一个 StartTime >= Target 的索引
%% ---------------------------------------------------------
binary_search(_Target, _EventsT, Low, High) when Low > High ->
    not_found;
binary_search(Target, EventsT, Low, High) ->
    Mid = (Low + High) div 2,
    [Start, _, _] = element(Mid, EventsT),
    if
        Start >= Target ->
            % 找到了一个符合条件的，尝试往左找更早的索引
            case binary_search(Target, EventsT, Low, Mid - 1) of
                not_found -> Mid;
                Result -> Result
            end;
        true ->
            % 当前 Start 太小，往右找
            binary_search(Target, EventsT, Mid + 1, High)
    end.