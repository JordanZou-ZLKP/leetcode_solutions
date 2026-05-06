%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

-spec rotate_right(Head :: #list_node{} | null, K :: integer()) -> #list_node{} | null.
rotate_right(null, _) -> null;
rotate_right(Head, K) ->
    Vals = to_list(Head, []),
    Len = length(Vals),
    Rotations = K rem Len,
    case Rotations of
        0 -> Head;
        _ ->
            SplitIndex = Len - Rotations,
            {Left, Right} = lists:split(SplitIndex, Vals),
            to_node(Right ++ Left)
    end.

to_list(null, Acc) ->
    lists:reverse(Acc);
to_list(#list_node{val = V, next = Next}, Acc) ->
    to_list(Next, [V | Acc]).

to_node([]) ->
    null;
to_node([V | Rest]) ->
    #list_node{val = V, next = to_node(Rest)}.