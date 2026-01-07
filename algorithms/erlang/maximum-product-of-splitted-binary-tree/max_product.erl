%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec max_product(Root :: #tree_node{} | null) -> integer().
max_product(Root) ->
    %% 第一步：计算整棵树的总和
    TotalSum = get_total_sum(Root),
    %% 第二步：遍历计算子树和，并找到最大乘积
    {_, MaxProduct} = find_max(Root, TotalSum),
    %% 最后取模
    MaxProduct rem 1000000007.

%% 辅助函数：计算树的总和
get_total_sum(null) -> 0;
get_total_sum(#tree_node{val = V, left = L, right = R}) ->
    V + get_total_sum(L) + get_total_sum(R).

%% 核心递归函数
%% 返回值: {当前子树的和, 当前遍历到的最大乘积}
find_max(null, _TotalSum) ->
    {0, 0};
find_max(#tree_node{val = V, left = L, right = R}, TotalSum) ->
    %% 递归处理左右子树
    {LeftSum, LeftMax} = find_max(L, TotalSum),
    {RightSum, RightMax} = find_max(R, TotalSum),
    
    %% 当前子树的和
    CurrentSubtreeSum = V + LeftSum + RightSum,
    
    %% 计算如果切断当前节点与其父节点连接时的乘积
    %% 注意：对于根节点，TotalSum - CurrentSubtreeSum 为 0，不影响最大值选取
    CurrentProduct = CurrentSubtreeSum * (TotalSum - CurrentSubtreeSum),
    
    %% 更新最大乘积（在左子树最大值、右子树最大值、当前乘积中取最大）
    MaxSoFar = erlang:max(CurrentProduct, erlang:max(LeftMax, RightMax)),
    
    {CurrentSubtreeSum, MaxSoFar}.

