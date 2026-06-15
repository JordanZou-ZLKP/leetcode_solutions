%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

-spec pair_sum(Head :: #list_node{} | null) -> integer().
pair_sum(Head) ->
    find_mid(Head, Head, []).

find_mid(null, Slow, Acc) ->
    calc_max(Slow, Acc, 0);
find_mid(#list_node{next = #list_node{next = FastNext}}, #list_node{val = V, next = SlowNext}, Acc) ->
    find_mid(FastNext, SlowNext, [V | Acc]).

calc_max(null, [], Max) ->
    Max;
calc_max(#list_node{val = V1, next = Next}, [V2 | Rest], Max) ->
    calc_max(Next, Rest, max(Max, V1 + V2)).