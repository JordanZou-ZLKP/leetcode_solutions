-spec maximize_square_hole_area(N :: integer(), M :: integer(), HBars :: [integer()], VBars :: [integer()]) -> integer().
maximize_square_hole_area(N, M, HBars, VBars) ->
    % 1. 对数组进行排序
    SortedH = lists:sort(HBars),
    SortedV = lists:sort(VBars),

    % 2. 计算最长连续序列长度
    MaxHRun = get_max_consecutive(SortedH),
    MaxVRun = get_max_consecutive(SortedV),

    % 3. 间隙大小 = 连续移除数量 + 1
    MaxHeight = MaxHRun + 1,
    MaxWidth = MaxVRun + 1,

    % 4. 正方形边长受限于较小的一边
    Side = min(MaxHeight, MaxWidth),

    % 5. 返回面积
    Side * Side.

%% @private
%% @doc 获取列表中最长的连续整数序列长度
%% 例如: [2, 3, 5, 6, 7] -> 最长连续是 [5, 6, 7]，长度为 3
get_max_consecutive([]) -> 0;
get_max_consecutive([H|T]) ->
    % 初始状态：当前数字 H，当前连续长度 1，最大连续长度 1
    get_max_consecutive(T, H, 1, 1).

%% @private
%% 尾递归遍历列表
%% Rest: 剩余列表
%% Prev: 上一个处理的数字
%% CurrRun: 当前正在统计的连续长度
%% MaxRun: 目前为止发现的最大连续长度
get_max_consecutive([], _Prev, _CurrRun, MaxRun) ->
    MaxRun;
get_max_consecutive([H|T], Prev, CurrRun, MaxRun) ->
    if
        H =:= Prev + 1 ->
            % 如果当前数字是上一个数字 + 1，连续长度加 1，更新最大值
            NewRun = CurrRun + 1,
            get_max_consecutive(T, H, NewRun, max(MaxRun, NewRun));
        true ->
            % 如果不连续，重置当前连续长度为 1
            get_max_consecutive(T, H, 1, MaxRun)
    end.