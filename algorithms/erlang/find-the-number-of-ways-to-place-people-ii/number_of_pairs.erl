-spec number_of_pairs(Points :: [[integer()]]) -> integer().
number_of_pairs(Points) ->
    % 1. 数据转换：将列表的列表 [[x,y]] 转换为元组列表 [{x,y}] 以便于处理
    Tuples = [{X, Y} || [X, Y] <- Points],

    % 2. 排序：
    % 规则：X 坐标升序；如果 X 相同，则 Y 坐标降序。
    % 这样处理后，对于任意索引 i < j：
    %   - P[i].x <= P[j].x 恒成立 (Alice 在左)
    %   - 如果 P[i].x == P[j].x，则 P[i].y > P[j].y (Alice 在上)
    SortedPoints = lists:sort(
        fun({X1, Y1}, {X2, Y2}) ->
            if
                X1 < X2 -> true;
                X1 > X2 -> false;
                true -> Y1 > Y2 % X相等时，Y大者排前
            end
        end,
        Tuples
    ),

    % 3. 开始计算
    solve(SortedPoints, 0).

%% 外层递归：遍历每一个点作为 Alice
solve([], Acc) -> Acc;
solve([{_Ax, Ay} | Rest], Acc) ->
    % 初始 Limit 设为一个极小值（题目约束坐标 >= -10^9）
    % Limit 用于记录在当前 Alice 的右下方区域中，已经出现过的阻挡点的最大 Y 坐标
    Limit = -2000000000, 
    CurrentPairs = count_bobs(Rest, Ay, Limit, 0),
    solve(Rest, Acc + CurrentPairs).

%% 内层递归：遍历 Alice 之后的所有点作为 Bob
count_bobs([], _Ay, _Limit, Count) -> Count;
count_bobs([{_Bx, By} | Rest], Ay, Limit, Count) ->
    % 这里的点在 X 轴上一定是在 Alice 右边（或同列）
    if
        By =< Ay ->
            % 只有当 Bob 的 Y 坐标 <= Alice 的 Y 坐标时，才能构成题目要求的“左上-右下”矩形
            if
                By > Limit ->
                    % 如果当前 Bob 的 Y 坐标 > Limit，说明中间没有点阻挡。
                    % 这是一个合法的配对。
                    % 更新 Limit 为当前 Bob 的 Y，因为任何后续的 Bob (X 更大) 
                    % 如果 Y 坐标在这个 Limit 之上，就会把当前这个 Bob 包含进矩形，导致非法。
                    count_bobs(Rest, Ay, By, Count + 1);
                true ->
                    % 虽然位置方向正确，但是被之前的点（Limit）挡住了（By <= Limit）。
                    % 非法配对。Limit 不变（因为之前的 Limit 更高，限制更严）。
                    count_bobs(Rest, Ay, Limit, Count)
            end;
        true ->
            % 该点在 Alice 上方 (By > Ay)，不可能构成以 Alice 为左上角的矩形。
            % 这个点在 Alice 的右上方，不影响 Alice 右下方矩形的“空”属性，
            % 所以忽略该点，Limit 也不需要更新。
            count_bobs(Rest, Ay, Limit, Count)
    end.