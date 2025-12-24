-spec subarray_bitwise_o_rs(Arr :: [integer()]) -> integer().
subarray_bitwise_o_rs(Arr) ->
    %% Fold 遍历数组
    %% Acc 结构: {全局结果集合, 以当前位置结尾的OR值列表}
    {FinalSet, _} = lists:foldl(fun(X, {GlobalSet, PrevORs}) ->
        %% 核心逻辑：
        %% 新的OR值 = (旧的OR值 | 当前元素 X) + (当前元素 X 自身)
        
        %% 1. 将 X 与之前所有的结果进行 OR 运算
        CurrentORs = [Val bor X || Val <- PrevORs],
        
        %% 2. 加入 X 自身 (因为 X 本身也是一个以 X 结尾的子数组)
        %% 3. 使用 usort 去重并排序。
        %%    这是关键优化点：去重后列表长度不会超过 30。
        NextORs = lists:usort([X | CurrentORs]),
        
        %% 4. 将新产生的一批 OR 值加入全局集合
        NewGlobalSet = add_list_to_set(NextORs, GlobalSet),
        
        {NewGlobalSet, NextORs}
    end, {sets:new(), []}, Arr),
    
    %% 返回集合大小
    sets:size(FinalSet).

%% 辅助函数：将列表中的元素逐个加入集合
add_list_to_set([], Set) -> Set;
add_list_to_set([H|T], Set) -> 
    add_list_to_set(T, sets:add_element(H, Set)).