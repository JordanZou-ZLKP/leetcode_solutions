%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

-spec delete_middle(Head :: #list_node{} | null) -> #list_node{} | null.

delete_middle(null) -> 
    null;
delete_middle(#list_node{next = null}) -> 
    null;
delete_middle(Head) -> 
    remove_node(Head, list_size(Head, 0) div 2, []).

list_size(null, Acc) -> 
    Acc;
list_size(#list_node{next = Next}, Acc) -> 
    list_size(Next, Acc + 1).

remove_node(#list_node{next = Next}, 0, Acc) -> 
    build_list(Acc, Next);
remove_node(#list_node{val = V, next = Next}, N, Acc) -> 
    remove_node(Next, N - 1, [V | Acc]).

build_list([], Tail) -> 
    Tail;
build_list([V | Rest], Tail) -> 
    build_list(Rest, #list_node{val = V, next = Tail}).