-spec three_sum(Nums :: [integer()]) -> [[integer()]].

three_sum(Nums) when length(Nums) < 3 ->
    [];
three_sum(Nums) ->
    %% 1. 排序 (O(N log N))
    SortedList = lists:sort(Nums),
    %% 2. 转换为 Tuple 以支持 O(1) 随机访问
    Tuple = list_to_tuple(SortedList),
    Len = tuple_size(Tuple),
    %% 3. 开始遍历查找 (O(N^2))
    three_sum_loop(Tuple, Len, 1, []).

%% 外层循环：固定第一个数 nums[i]
three_sum_loop(_Tuple, Len, I, Acc) when I > Len - 2 ->
    lists:reverse(Acc); %% 结果翻转回正确顺序（可选，视需求而定）
three_sum_loop(Tuple, Len, I, Acc) ->
    Val = element(I, Tuple),
    %% 去重逻辑：如果当前数字与上一个数字相同，则跳过
    case I > 1 andalso element(I - 1, Tuple) =:= Val of
        true ->
            three_sum_loop(Tuple, Len, I + 1, Acc);
        false ->
            %% 在 I+1 到 Len 的范围内寻找两数之和等于 -Val
            Target = -Val,
            NewTriplets = two_sum(Tuple, I + 1, Len, Target, Val),
            %% 将找到的三元组加入累加器，继续下一个 I
            three_sum_loop(Tuple, Len, I + 1, NewTriplets ++ Acc)
    end.

%% 内层循环：双指针寻找 nums[L] + nums[R] == Target
two_sum(Tuple, L, R, Target, FixedVal) ->
    two_sum_loop(Tuple, L, R, Target, FixedVal, []).

two_sum_loop(_Tuple, L, R, _Target, _FixedVal, Acc) when L >= R ->
    Acc;
two_sum_loop(Tuple, L, R, Target, FixedVal, Acc) ->
    ValL = element(L, Tuple),
    ValR = element(R, Tuple),
    Sum = ValL + ValR,
    if
        Sum == Target ->
            %% 找到匹配，记录结果
            Res = [FixedVal, ValL, ValR],
            %% 移动指针并去重
            NextL = skip_left(Tuple, L, R, ValL),
            NextR = skip_right(Tuple, L, R, ValR),
            [Res | two_sum_loop(Tuple, NextL, NextR, Target, FixedVal, Acc)];
        Sum < Target ->
            %% 和太小，左指针右移
            two_sum_loop(Tuple, L + 1, R, Target, FixedVal, Acc);
        Sum > Target ->
            %% 和太大，右指针左移
            two_sum_loop(Tuple, L, R - 1, Target, FixedVal, Acc)
    end.

%% 辅助函数：左指针去重，跳过相同的值
skip_left(Tuple, L, R, Val) when L < R, element(L, Tuple) =:= Val ->
    skip_left(Tuple, L + 1, R, Val);
skip_left(_Tuple, L, _R, _Val) ->
    L.

%% 辅助函数：右指针去重，跳过相同的值
skip_right(Tuple, L, R, Val) when L < R, element(R, Tuple) =:= Val ->
    skip_right(Tuple, L, R - 1, Val);
skip_right(_Tuple, _L, R, _Val) ->
    R.
