-spec triangular_sum(Nums :: [integer()]) -> integer().
triangular_sum(Nums) ->
    process_layer(Nums).

%% @doc 递归终止条件：当列表只剩一个元素时，返回该元素
process_layer([Result]) ->
    Result;
%% @doc 递归步骤：计算下一层列表，然后继续处理
process_layer(Nums) ->
    NextLayer = make_next_layer(Nums),
    process_layer(NextLayer).

%% @doc 构建下一层列表
%% 这里的逻辑是：Current[i] = (Old[i] + Old[i+1]) % 10
make_next_layer([A, B | Rest]) ->
    Sum = (A + B) rem 10,
    [Sum | make_next_layer([B | Rest])];
make_next_layer([_]) ->
    %% 当只剩最后一个元素时，这一层构建结束
    [].