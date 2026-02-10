%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec balance_bst(Root :: #tree_node{} | null) -> #tree_node{} | null.

balance_bst(null) -> null;
balance_bst(Root) ->
    %% 第一步：中序遍历将树转为有序列表 O(N)
    SortedValues = inorder_traversal(Root, []),
    
    %% 获取节点总数 O(N)
    Count = length(SortedValues),
    
    %% 第二步：从有序列表构建平衡 BST O(N)
    {BalancedRoot, _Remaining} = build_balanced_bst(SortedValues, Count),
    BalancedRoot.

%% =========================================================
%% 辅助函数：中序遍历 (尾递归优化思路，但利用列表构建特性)
%% =========================================================
%% 使用累加器 Acc，先处理右子树，再把当前节点加入，最后处理左子树。
%% 这样可以避免使用低效的列表拼接 (++) 操作。
-spec inorder_traversal(#tree_node{} | null, [integer()]) -> [integer()].
inorder_traversal(null, Acc) -> 
    Acc;
inorder_traversal(#tree_node{val = Val, left = Left, right = Right}, Acc) ->
    %% 顺序：Left -> Val -> Right
    %% 在递归实现中，我们先把 Right 的结果放到 Acc 后面，
    %% 然后把 Val 放前面，最后把这个整体作为 Acc 传给 Left。
    inorder_traversal(Left, [Val | inorder_traversal(Right, Acc)]).

%% =========================================================
%% 辅助函数：从有序列表构建平衡 BST
%% =========================================================
%% 这种实现方式避免了在每一层递归中使用 lists:split (耗时 O(K))。
%% 我们传递列表和需要构建的节点数量，函数返回 {构建好的树, 剩余的列表}。
%% 这样只需要遍历列表一次。
-spec build_balanced_bst([integer()], integer()) -> {#tree_node{} | null, [integer()]}.
build_balanced_bst(List, 0) -> 
    {null, List};
build_balanced_bst(List, N) ->
    %% 计算左右子树的节点数量
    %% 中间节点占用 1 个，剩下 N-1 个分配给左右
    LeftCount = N div 2,
    RightCount = N - 1 - LeftCount,
    
    %% 1. 递归构建左子树
    {LeftTree, ListAfterLeft} = build_balanced_bst(List, LeftCount),
    
    %% 2. 取出当前根节点的值 (此时列表头就是中间节点)
    [RootVal | ListAfterRoot] = ListAfterLeft,
    
    %% 3. 递归构建右子树
    {RightTree, RemainingList} = build_balanced_bst(ListAfterRoot, RightCount),
    
    %% 4. 组装并返回
    Root = #tree_node{
        val = RootVal,
        left = LeftTree,
        right = RightTree
    },
    {Root, RemainingList}.