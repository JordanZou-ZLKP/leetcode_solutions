%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec sum_root_to_leaf(Root :: #tree_node{} | null) -> integer().
sum_root_to_leaf(Root) ->
    dfs(Root, 0).

dfs(null, _) ->
    0;
dfs(#tree_node{val = Val, left = null, right = null}, Acc) ->
    (Acc bsl 1) bor Val;
dfs(#tree_node{val = Val, left = Left, right = Right}, Acc) ->
    NextAcc = (Acc bsl 1) bor Val,
    dfs(Left, NextAcc) + dfs(Right, NextAcc).