%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec max_path_sum(Root :: #tree_node{} | null) -> integer().

max_path_sum(Root) ->
    %% 初始调用 helper，解构元组获取最终的全局最大路径和
    {_RootGain, MaxPathSum} = helper(Root),
    MaxPathSum.

%% 核心递归函数
%% 返回值: {当前节点对外提供的最大贡献值, 当前子树内部发现的最大路径和}
-spec helper(Node :: #tree_node{} | null) -> {integer(), integer()}.
helper(null) ->
    %% 基础情况：空节点贡献为0，且不可能是最大路径（设为极小值）
    %% 注意：题目中节点值最小为 -1000，路径和可能为负，
    %% 这里使用 -10^9 作为一个足够小的“负无穷”替代品。
    {0, -1000000000};

helper(#tree_node{val = Val, left = Left, right = Right}) ->
    %% 1. 递归计算左右子树
    {LeftGain, LeftMax} = helper(Left),
    {RightGain, RightMax} = helper(Right),

    %% 2. 计算当前节点对外提供的贡献值
    %% 如果子树贡献为负，则不如不选（截断），取 0
    EffectiveLeft = max(LeftGain, 0),
    EffectiveRight = max(RightGain, 0),

    %% 3. 计算以当前节点为“拐点”的路径和
    %% 这是穿过当前节点的路径：左边 + 自己 + 右边
    CurrentSplitPathSum = Val + EffectiveLeft + EffectiveRight,

    %% 4. 更新全局最大路径和
    %% 比较：当前拐点路径 vs 左子树内部最大 vs 右子树内部最大
    NewMax = max(CurrentSplitPathSum, max(LeftMax, RightMax)),

    %% 5. 计算返回给父节点的贡献值
    %% 只能走一边：自己 + max(左边有效值, 右边有效值)
    ReturnGain = Val + max(EffectiveLeft, EffectiveRight),

    {ReturnGain, NewMax}.

