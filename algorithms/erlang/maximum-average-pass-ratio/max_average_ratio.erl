-spec max_average_ratio(Classes :: [[integer()]], ExtraStudents :: integer()) -> float().
max_average_ratio(Classes, ExtraStudents) ->
    % 1. 构建优先队列 (gb_trees)
    % 键(Key): {Gain, UniqueIndex} -> 用于排序，Index确保Gain相同时键唯一
    % 值(Value): {Pass, Total} -> 存储班级状态
    {Tree, _Count} = lists:foldl(fun([P, T], {AccTree, Idx}) ->
        Gain = calculate_gain(P, T),
        % 插入树中
        NewTree = gb_trees:insert({Gain, Idx}, {P, T}, AccTree),
        {NewTree, Idx + 1}
    end, {gb_trees:empty(), 0}, Classes),

    % 2. 贪心分配学生
    FinalTree = distribute_students(ExtraStudents, Tree),

    % 3. 计算最终平均通过率
    TotalRatio = sum_ratios(gb_trees:values(FinalTree), 0.0),
    TotalRatio / length(Classes).

%% ---------------------------------------------------------
%% 辅助函数
%% ---------------------------------------------------------

%% 递归分配 ExtraStudents 个学生
distribute_students(0, Tree) ->
    Tree;
distribute_students(N, Tree) ->
    % 取出增益最大的班级 (gb_trees 默认从小到大排，take_largest 取最大)
    {{OldGain, Idx}, {P, T}, TreeWithoutMax} = gb_trees:take_largest(Tree),
    
    % 更新班级人数
    NewP = P + 1,
    NewT = T + 1,
    
    % 计算新的增益
    NewGain = calculate_gain(NewP, NewT),
    
    % 插回树中
    NewTree = gb_trees:insert({NewGain, Idx}, {NewP, NewT}, TreeWithoutMax),
    
    % 继续分配下一个
    distribute_students(N - 1, NewTree).

%% 计算增加一名学生带来的通过率增益
%% Gain = (P+1)/(T+1) - P/T
%% 优化公式: (T - P) / (T * (T + 1))
calculate_gain(P, T) ->
    (T - P) / (T * (T + 1)).

%% 累加最终所有班级的通过率
sum_ratios([], Acc) ->
    Acc;
sum_ratios([{P, T} | Rest], Acc) ->
    sum_ratios(Rest, Acc + (P / T)).