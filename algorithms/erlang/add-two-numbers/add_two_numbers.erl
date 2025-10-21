%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

-spec add_two_numbers(L1 :: #list_node{} | null, L2 :: #list_node{} | null) -> #list_node{} | null.

add_two_numbers(L1, L2) ->
    add_num(L1, L2, 0).

add_num(null, null, Carry) when Carry > 0 ->
    #list_node{val = Carry, next = null};
add_num(null, null, 0) ->
    null;
add_num(#list_node{val = V1, next = N1}, null, Carry) ->
    Sum = V1 + Carry,
    #list_node{val = Sum rem 10, next = add_num(N1, null, Sum div 10)};
add_num(null, #list_node{val = V2, next = N2}, Carry) ->
    Sum = V2 + Carry,
    #list_node{val = Sum rem 10, next = add_num(null, N2, Sum div 10)};
add_num(#list_node{val = V1, next = N1}, #list_node{val = V2, next = N2}, Carry) ->
    Sum = V1 + V2 + Carry,
    #list_node{val = Sum rem 10, next = add_num(N1, N2, Sum div 10)}.

list_to_linked_list([]) ->
    null;
list_to_linked_list([H|T]) ->
    #list_node{val = H, next = list_to_linked_list(T)}.

linked_list_to_list(null) ->
    [];
linked_list_to_list(#list_node{val = Val, next = Next}) ->
    [Val | linked_list_to_list(Next)].
    