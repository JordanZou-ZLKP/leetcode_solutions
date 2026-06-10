%% Definition for a binary tree node.
%%
%% -record(tree_node, {val = 0 :: integer(),
%%                     left = null  :: 'null' | #tree_node{},
%%                     right = null :: 'null' | #tree_node{}}).

-spec create_binary_tree(Descriptions :: [[integer()]]) -> #tree_node{} | null.
create_binary_tree(Descriptions) ->
    {TreeMap, ChildrenMap} = lists:foldl(
        fun([P, C, IsLeft], {MapAcc, CMapAcc}) ->
            {L, R} = maps:get(P, MapAcc, {null, null}),
            NewKids = if 
                IsLeft =:= 1 -> {C, R}; 
                true -> {L, C} 
            end,
            {MapAcc#{P => NewKids}, CMapAcc#{C => true}}
        end,
        {#{}, #{}},
        Descriptions
    ),
    RootVal = find_root(Descriptions, ChildrenMap),
    build_tree(RootVal, TreeMap).

find_root([[P, _, _] | T], ChildrenMap) ->
    case maps:is_key(P, ChildrenMap) of
        true -> find_root(T, ChildrenMap);
        false -> P
    end.

build_tree(null, _TreeMap) ->
    null;
build_tree(Val, TreeMap) ->
    {L, R} = maps:get(Val, TreeMap, {null, null}),
    #tree_node{
        val = Val,
        left = build_tree(L, TreeMap),
        right = build_tree(R, TreeMap)
    }.