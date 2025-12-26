-spec largest_triangle_area(Points :: [[integer()]]) -> float().

largest_triangle_area(Points) ->
    %% 开始递归查找，初始最大面积为 0.0
    find_max_area(Points, 0.0).

%% 第一层循环：选择第一个点 P1
find_max_area([P1 | Rest], CurrentMax) ->
    %% 使用 P1 和剩余的点去寻找更大的面积
    NewMax = iter_second_point(P1, Rest, CurrentMax),
    %% 递归处理剩下的点作为 P1
    find_max_area(Rest, NewMax);
find_max_area([], FinalMax) ->
    FinalMax.

%% 第二层循环：选择第二个点 P2
iter_second_point(P1, [P2 | Rest], CurrentMax) ->
    %% 使用 P1, P2 和剩余的点去寻找更大的面积
    NewMax = iter_third_point(P1, P2, Rest, CurrentMax),
    %% 递归处理剩下的点作为 P2
    iter_second_point(P1, Rest, NewMax);
iter_second_point(_P1, [], CurrentMax) ->
    CurrentMax.

%% 第三层循环：选择第三个点 P3 并计算面积
iter_third_point(P1, P2, [P3 | Rest], CurrentMax) ->
    Area = calculate_area(P1, P2, P3),
    %% 更新最大值
    NewMax = erlang:max(CurrentMax, Area),
    iter_third_point(P1, P2, Rest, NewMax);
iter_third_point(_P1, _P2, [], CurrentMax) ->
    CurrentMax.

%% 计算三个点组成的三角形面积
%% Points 格式为 [X, Y]
calculate_area([X1, Y1], [X2, Y2], [X3, Y3]) ->
    abs(X1 * (Y2 - Y3) + X2 * (Y3 - Y1) + X3 * (Y1 - Y2)) / 2.0.