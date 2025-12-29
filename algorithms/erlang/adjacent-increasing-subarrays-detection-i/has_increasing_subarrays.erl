-spec has_increasing_subarrays(Nums :: [integer()], K :: integer()) -> boolean().
has_increasing_subarrays(Nums, K) ->
    % 1. 生成每个位置的递增行程长度列表
    RunLengths = get_run_lengths(Nums),
    
    % 2. 检查是否存在满足条件的偏移量
    % 我们需要比较 RunLengths[i] 和 RunLengths[i + K]
    % 使用 lists:nthtail/2 跳过前 K 个元素，然后并行遍历 (zip) 检查
    try
        ShiftedRunLengths = lists:nthtail(K, RunLengths),
        check_adjacent(RunLengths, ShiftedRunLengths, K)
    catch
        error:_ -> false % 如果列表长度不足 K，直接返回 false
    end.

%% ---------------------------------------------------------
%% 辅助函数：计算以每个元素结尾的严格递增子数组长度
%% ---------------------------------------------------------
get_run_lengths([]) -> [];
get_run_lengths([H | T]) ->
    % 初始长度为 1，累加器包含第一个元素的长度
    get_run_lengths(T, H, 1, [1]).

get_run_lengths([], _PrevVal, _CurLen, Acc) ->
    lists:reverse(Acc);
get_run_lengths([H | T], PrevVal, CurLen, Acc) ->
    NewLen = case H > PrevVal of
        true  -> CurLen + 1; % 严格递增，长度累加
        false -> 1           % 非递增，重置为 1
    end,
    get_run_lengths(T, H, NewLen, [NewLen | Acc]).

%% ---------------------------------------------------------
%% 辅助函数：并行检查当前列表和偏移 K 后的列表
%% ---------------------------------------------------------
check_adjacent([], _, _) -> false;
check_adjacent(_, [], _) -> false;
check_adjacent([Len1 | T1], [Len2 | T2], K) ->
    % Len1 代表第一个子数组结尾处的递增长度
    % Len2 代表第二个子数组结尾处的递增长度（实际上是索引 i+k 处）
    case Len1 >= K andalso Len2 >= K of
        true  -> true;
        false -> check_adjacent(T1, T2, K)
    end.