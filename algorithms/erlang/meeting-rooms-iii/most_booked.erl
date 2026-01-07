-spec most_booked(N :: integer(), Meetings :: [[integer()]]) -> integer().
most_booked(N, Meetings) ->
    % 1. 按开始时间排序会议: O(M log M)
    SortedMeetings = lists:sort(Meetings),

    % 2. 初始化状态
    % FreeRooms: 包含 0 到 N-1 的最小堆
    FreeRooms = heap_from_list(lists:seq(0, N - 1)),
    % BusyRooms: 空堆，用于存储 {EndTime, RoomIndex}
    BusyRooms = heap_empty(),
    % Counts: 记录每个房间会议次数的 Map
    Counts = maps:from_list([{I, 0} || I <- lists:seq(0, N - 1)]),

    % 3. 处理所有会议: O(M log N)
    FinalCounts = process_meetings(SortedMeetings, FreeRooms, BusyRooms, Counts),

    % 4. 找出此时最大的房间: O(N)
    find_max_room(FinalCounts, N).

%% ====================================================================
%% 核心逻辑循环
%% ====================================================================
process_meetings([], _Free, _Busy, Counts) ->
    Counts;
process_meetings([[Start, End] | Rest], Free, Busy, Counts) ->
    Duration = End - Start,

    % 步骤 A: 释放所有在 Start 之前（含 Start）结束的房间
    {FreeAfterRelease, BusyAfterRelease} = release_finished_rooms(Busy, Free, Start),

    % 步骤 B: 分配房间
    case heap_is_empty(FreeAfterRelease) of
        true ->
            % 情况 1: 没有空闲房间。必须等待最早结束的房间。
            % 获取最早结束的房间 (EarliestFinishTime, RoomIndex)
            {{FinishTime, RoomIdx}, BusyRest} = heap_pop(BusyAfterRelease),
            
            % 会议延期：新的结束时间 = 房间释放时间 + 持续时间
            NewEndTime = FinishTime + Duration,
            
            % 更新状态：该房间继续忙碌，放入 BusyRooms
            NewBusy = heap_push(BusyRest, {NewEndTime, RoomIdx}),
            NewCounts = update_count(Counts, RoomIdx),
            
            process_meetings(Rest, FreeAfterRelease, NewBusy, NewCounts);

        false ->
            % 情况 2: 有空闲房间。取出房间号最小的。
            {RoomIdx, FreeRest} = heap_pop(FreeAfterRelease),
            
            % 会议正常进行：结束时间 = End
            NewBusy = heap_push(BusyAfterRelease, {End, RoomIdx}),
            NewCounts = update_count(Counts, RoomIdx),
            
            process_meetings(Rest, FreeRest, NewBusy, NewCounts)
    end.

% 辅助：将所有结束时间 <= CurrentStart 的房间从 Busy 移到 Free
release_finished_rooms(Busy, Free, CurrentStart) ->
    case heap_peek(Busy) of
        empty -> 
            {Free, Busy};
        {EndTime, _RoomIdx} when EndTime > CurrentStart -> 
            {Free, Busy};
        {_EndTime, RoomIdx} ->
            {_, BusyRest} = heap_pop(Busy),
            NewFree = heap_push(Free, RoomIdx),
            release_finished_rooms(BusyRest, NewFree, CurrentStart)
    end.

update_count(Counts, RoomIdx) ->
    maps:update_with(RoomIdx, fun(V) -> V + 1 end, 1, Counts).

find_max_room(Counts, N) ->
    % 遍历 0 到 N-1，找到 Count 最大且 Index 最小的
    {Room,Num} = lists:foldl(fun(RoomIdx, {BestRoom, MaxCount}) ->
        Count = maps:get(RoomIdx, Counts, 0),
        if
            Count > MaxCount -> {RoomIdx, Count};
            true -> {BestRoom, MaxCount}
        end
    end, {0, -1}, lists:seq(0, N - 1)),
    Room.
    
%% ====================================================================
%% 数据结构：Skew Heap (斜堆) 实现最小堆
%% 提供 O(log N) 的 push 和 pop 操作
%% ====================================================================

% 堆节点结构: nil | {Node, Left, Right}
heap_empty() -> nil.

heap_is_empty(nil) -> true;
heap_is_empty(_) -> false.

heap_push(Heap, Val) -> heap_merge(Heap, {Val, nil, nil}).

heap_peek(nil) -> empty;
heap_peek({Val, _, _}) -> Val.

heap_pop(nil) -> empty;
heap_pop({Val, Left, Right}) -> {Val, heap_merge(Left, Right)}.

heap_merge(nil, H) -> H;
heap_merge(H, nil) -> H;
heap_merge(H1 = {V1, L1, R1}, H2 = {V2, L2, R2}) ->
    if
        V1 =< V2 -> {V1, heap_merge(H2, R1), L1}; % 交换左右子树以保持平衡
        true     -> {V2, heap_merge(H1, R2), L2}
    end.

heap_from_list(List) ->
    lists:foldl(fun(X, Acc) -> heap_push(Acc, X) end, heap_empty(), List).