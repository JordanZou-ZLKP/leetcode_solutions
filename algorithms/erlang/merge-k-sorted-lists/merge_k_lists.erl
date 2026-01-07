%% Definition for singly-linked list.
%%
%% -record(list_node, {val = 0 :: integer(),
%%                     next = null :: 'null' | #list_node{}}).

-spec merge_k_lists(Lists :: [#list_node{} | null]) -> #list_node{} | null.
merge_k_lists([]) -> null;
%% 2. 处理只有一个链表的输入
merge_k_lists([List]) -> List;
%% 3. 进入迭代合并流程
merge_k_lists(Lists) ->
    merge_all(Lists).

%% 核心控制流：不断进行两两合并，直到只剩一个结果
merge_all([Result]) -> 
    Result;
merge_all(Lists) ->
    %% 每一轮调用 pairwise 将列表数量减半
    merge_all(pairwise(Lists)).

%% 辅助函数：成对处理列表
%% 将 [A, B, C, D, E] -> [Merge(A,B), Merge(C,D), E]
pairwise([]) -> 
    [];
pairwise([L]) -> 
    [L];
pairwise([L1, L2 | Rest]) ->
    %% 合并前两个，并将结果放入新列表，继续处理剩余部分
    [merge_two(L1, L2) | pairwise(Rest)].

%% ---------------------------------------------------------
%% 优化后的合并两个有序链表
%% 保持 Body Recursion，但在 Erlang 中这是构建链表最高效的方式
%% ---------------------------------------------------------
merge_two(null, L2) -> L2;
merge_two(L1, null) -> L1;
merge_two(L1 = #list_node{val = V1, next = Next1}, 
          L2 = #list_node{val = V2, next = Next2}) ->
    if
        V1 =< V2 ->
            L1#list_node{next = merge_two(Next1, L2)};
        true ->
            L2#list_node{next = merge_two(L1, Next2)}
    end.
