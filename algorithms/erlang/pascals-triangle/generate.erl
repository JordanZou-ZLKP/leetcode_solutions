-spec generate(NumRows :: integer()) -> [[integer()]].

generate(0) -> [];
generate(NumRows) when NumRows > 0 ->
    %% 初始状态：第一行是 [1]
    %% 我们使用累加器 Acc 来存储结果，最后再反转
    generate_rows(NumRows - 1, [[1]]).

%% 基本情况：当只需要生成 0 更多行时，反转结果列表并返回
generate_rows(0, Acc) ->
    lists:reverse(Acc);

%% 递归步骤：基于上一行 (LastRow) 生成新的一行 (NewRow)
generate_rows(N, [LastRow | _] = Acc) ->
    NewRow = make_next_row(LastRow),
    generate_rows(N - 1, [NewRow | Acc]).

%% @doc 根据当前行生成下一行
%% 逻辑：下一行总是以 1 开头，中间是上一行两两相加，最后以 1 结尾
make_next_row(Row) ->
    [1 | sum_pairs(Row)].

%% 递归计算中间的数值
sum_pairs([A, B | Rest]) ->
    [A + B | sum_pairs([B | Rest])];
sum_pairs([_]) ->
    %% 当列表只剩最后一个元素时，添加行尾的 1
    [1].