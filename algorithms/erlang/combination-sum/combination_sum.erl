-spec combination_sum(Candidates :: [integer()], Target :: integer()) -> [[integer()]].
combination_sum(Candidates, Target) ->
    %% 1. 排序 Candidates 以便进行剪枝优化
    SortedCandidates = lists:sort(Candidates),
    %% 2. 开始递归搜索
    %% 参数: 候选列表, 剩余目标值, 当前路径, 累积结果
    find(SortedCandidates, Target, [], []).

%% Base Case 1: 目标值刚好减为 0，说明找到了一组有效解
find(_, 0, CurrentPath, Acc) ->
    %% 因为构建列表是 Cons ([H|T]) 操作，顺序是反的，所以这里反转一次
    [lists:reverse(CurrentPath) | Acc];

%% Base Case 2: 候选列表为空，无法继续寻找
find([], _, _, Acc) ->
    Acc;

%% 递归步骤
find([Head | Tail] = Candidates, Target, CurrentPath, Acc) ->
    if
        %% 剪枝优化: 如果当前最小的数 (Head) 都比 Target 大，
        %% 那么后面的数肯定更大，直接停止当前分支的搜索。
        Head > Target ->
            Acc;
        true ->
            %% 分支 1: 选择当前数字 (Head)
            %% 逻辑: Target 减去 Head，将 Head 加入路径。
            %% 注意: 第一个参数依然传 Candidates (包含 Head)，因为允许重复使用数字。
            AccAfterInclude = find(Candidates, Target - Head, [Head | CurrentPath], Acc),

            %% 分支 2: 不选择当前数字 (跳过 Head)
            %% 逻辑: Target 不变，路径不变，只在剩下的 Tail 中寻找。
            %% 将分支 1 得到的结果 (AccAfterInclude) 作为累积器传入分支 2。
            find(Tail, Target, CurrentPath, AccAfterInclude)
    end.

