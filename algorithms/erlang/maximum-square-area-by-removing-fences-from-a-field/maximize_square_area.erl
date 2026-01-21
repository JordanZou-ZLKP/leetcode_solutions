-spec maximize_square_area(M :: integer(), N :: integer(), HFences :: [integer()], VFences :: [integer()]) -> integer().
maximize_square_area(M, N, HFences, VFences) ->
    % 1. 添加边界并排序 O(N log N)
    SortedH = lists:sort([1, M | HFences]),
    SortedV = lists:sort([1, N | VFences]),

    % 2. 生成所有可能的水平间距，存入 Map 中 O(H^2)
    % Map 的 Key 是间距，Value 是 true
    HDiffsMap = get_diffs_map(SortedH, #{}),

    % 3. 遍历所有可能的垂直间距，检查是否存在于 HDiffsMap 中 O(V^2)
    MaxSide = find_max_common_diff(SortedV, HDiffsMap, -1),

    % 4. 计算结果
    case MaxSide of
        -1 -> -1;
        _ -> 
            Mod = 1000000007,
            (MaxSide * MaxSide) rem Mod
    end.

%% ==========================================================
%% 辅助函数
%% ==========================================================

%% 生成所有坐标对之间的差值，存入 Map
get_diffs_map([], Map) -> 
    Map;
get_diffs_map([Head | Tail], Map) ->
    % 计算 Head 与 Tail 中所有元素的差值，更新 Map
    NewMap = add_diffs(Head, Tail, Map),
    % 递归处理剩下的元素
    get_diffs_map(Tail, NewMap).

%% 计算 Start 与 List 中所有元素的差值
add_diffs(_, [], Map) -> 
    Map;
add_diffs(Start, [End | Rest], Map) ->
    Diff = End - Start,
    % 将差值作为 Key 存入 Map
    add_diffs(Start, Rest, Map#{Diff => true}).

%% 遍历垂直栅栏列表，计算差值并查找最大公共边长
find_max_common_diff([], _, Max) -> 
    Max;
find_max_common_diff([Head | Tail], HMap, Max) ->
    % 检查当前 Head 与 Tail 中所有元素的差值
    NewMax = check_diffs(Head, Tail, HMap, Max),
    find_max_common_diff(Tail, HMap, NewMax).

%% 检查垂直差值是否存在于水平差值 Map 中
check_diffs(_, [], _, Max) -> 
    Max;
check_diffs(Start, [End | Rest], HMap, Max) ->
    Diff = End - Start,
    % 只有当 Diff 比当前 Max 大时才需要去 Map 里查，这算是一个小剪枝优化
    CurrentMax = case Diff > Max of
        true ->
            case maps:is_key(Diff, HMap) of
                true -> Diff; % 找到更大的共同边长
                false -> Max
            end;
        false -> 
            Max
    end,
    check_diffs(Start, Rest, HMap, CurrentMax).