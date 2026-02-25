-record(node, {
    min = 0 :: integer(),
    max = 0 :: integer(),
    lazy = 0 :: integer(),
    left = undefined :: undefined | #node{},
    right = undefined :: undefined | #node{}
}).

-spec longest_balanced(Nums :: [integer()]) -> integer().
longest_balanced(Nums) ->
    N = length(Nums),
    %% 构建覆盖 [0, N] 的线段树，初始值全为 0
    Tree = build(0, N),
    
    %% 使用 foldl 模拟遍历
    %% Accumulator: {MaxLen, CurrentIndex, Tree, LastPosMap, CurrentBalance}
    {MaxLen, _, _, _, _} = lists:foldl(fun(X, {Max, I, T, LastPos, Bal}) ->
        CurrentI = I + 1,
        IsOdd = (X rem 2) /= 0,
        Det = if IsOdd -> 1; true -> -1 end,
        
        %% 1. 处理旧位置：如果 X 出现过，移除旧的贡献
        {T_Step1, NewBal} = case maps:find(X, LastPos) of
            {ok, PrevI} ->
                %% X 从 PrevI 移动到 CurrentI。
                %% 原本在 PrevI 处的 Det 被移除（变为0），
                %% 这会导致 PrefixSum 在范围 [PrevI, N] 内减少 Det。
                %% 但我们在下一步会加回来。实际上，对于 sweep-line 逻辑：
                %% 我们需要撤销 PrevI 的贡献。
                {update(T, PrevI, N, -Det, 0, N), Bal};
            error ->
                %% X 是第一次出现，总的 Distinct Balance 发生变化
                {T, Bal + Det}
        end,
        
        %% 2. 处理新位置：在 CurrentI 处添加贡献
        %% PrefixSum 在范围 [CurrentI, N] 增加 Det
        T_Step2 = update(T_Step1, CurrentI, N, Det, 0, N),
        
        %% 3. 查询：寻找最小的索引 k (0 <= k < CurrentI)，使得 PrefixSum[k] == NewBal
        %% 因为 PrefixSum[CurrentI] 必然等于 NewBal，所以一定能找到。
        FirstIdx = query_first(T_Step2, NewBal, 0, 0, N),
        
        NewLen = CurrentI - FirstIdx,
        {erlang:max(Max, NewLen), CurrentI, T_Step2, LastPos#{X => CurrentI}, NewBal}
    end, {0, 0, Tree, #{}, 0}, Nums),
    
    MaxLen.

%% ====================================================================
%% Segment Tree Helper Functions
%% ====================================================================

%% 构建树：O(N)
build(L, R) when L == R ->
    #node{};
build(L, R) ->
    Mid = (L + R) div 2,
    #node{
        left = build(L, Mid),
        right = build(Mid + 1, R)
    }.

%% 区间更新：O(log N)
%% 将区间 [QL, QR] 内的所有值加上 Diff
update(Node, QL, QR, Diff, L, R) when QL =< L, R =< QR ->
    %% 完全覆盖，更新 Lazy 和 Min/Max
    Node#node{
        min = Node#node.min + Diff,
        max = Node#node.max + Diff,
        lazy = Node#node.lazy + Diff
    };
update(Node, QL, QR, Diff, L, R) ->
    Mid = (L + R) div 2,
    
    %% 递归更新子节点
    NewLeft = if QL =< Mid -> update(Node#node.left, QL, QR, Diff, L, Mid);
                 true -> Node#node.left end,
    NewRight = if QR > Mid -> update(Node#node.right, QL, QR, Diff, Mid + 1, R);
                  true -> Node#node.right end,
    
    %% 根据子节点重新计算当前节点的 Min/Max
    %% 注意：父节点的 Lazy 不需要下推（Push Down），而是叠加在计算结果上
    MinVal = erlang:min(NewLeft#node.min, NewRight#node.min),
    MaxVal = erlang:max(NewLeft#node.max, NewRight#node.max),
    
    Node#node{
        left = NewLeft,
        right = NewRight,
        min = MinVal + Node#node.lazy,
        max = MaxVal + Node#node.lazy
    }.

%% 查询第一个等于 Target 的索引：O(log N)
%% AccLazy 累积了路径上所有祖先节点的 Lazy 值
query_first(Node, Target, AccLazy, L, R) ->
    CurrentEffectiveLazy = Node#node.lazy + AccLazy,
    
    if L == R -> 
        L; %% 找到叶子节点
       true ->
           Mid = (L + R) div 2,
           Left = Node#node.left,
           %% 检查左子树的有效值范围是否包含 Target
           LeftMin = Left#node.min + CurrentEffectiveLazy,
           LeftMax = Left#node.max + CurrentEffectiveLazy,
           
           if Target >= LeftMin, Target =< LeftMax ->
               query_first(Left, Target, CurrentEffectiveLazy, L, Mid);
           true ->
               query_first(Node#node.right, Target, CurrentEffectiveLazy, Mid + 1, R)
           end
    end.