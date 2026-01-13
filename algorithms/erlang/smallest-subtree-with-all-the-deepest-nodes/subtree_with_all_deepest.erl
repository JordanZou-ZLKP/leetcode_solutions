%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec subtree_with_all_deepest(Root :: #tree_node{} | null) -> #tree_node{} | null.
subtree_with_all_deepest(Root) ->
    %% dfs 返回一个元组 {MaxDepth, ResultNode}
    {_Depth, ResultNode} = dfs(Root),
    ResultNode.

%% @doc 辅助函数：执行深度优先搜索
%% 返回值: {Depth, Node}
%% Depth: 以当前节点为根的子树的最大深度
%% Node: 该子树中包含所有最深节点的根节点 (即题目要求的答案候选)
-spec dfs(Node :: #tree_node{} | null) -> {integer(), #tree_node{} | null}.
dfs(null) ->
    {0, null};
dfs(Node) ->
    {LDepth, LRes} = dfs(Node#tree_node.left),
    {RDepth, RRes} = dfs(Node#tree_node.right),
    
    if
        %% 左边更深，答案肯定在左边
        LDepth > RDepth ->
            {LDepth + 1, LRes};
        
        %% 右边更深，答案肯定在右边
        RDepth > LDepth ->
            {RDepth + 1, RRes};
        
        %% 深度相同，当前节点即为这两个最深分支的交汇点（LCA）
        true ->
            {LDepth + 1, Node}
    end.