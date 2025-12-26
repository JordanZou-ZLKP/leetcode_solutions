-spec maximum69_number (Num :: integer()) -> integer().
maximum69_number (Num) ->
    % 1. 将整数转换为字符串（在 Erlang 中是字符列表）
    Str = integer_to_list(Num),
    
    % 2. 处理列表，替换第一个 '6' 为 '9'
    NewStr = replace_first_six(Str),
    
    % 3. 将结果列表转回整数
    list_to_integer(NewStr).

%% 递归函数：寻找并替换第一个 '6'
replace_first_six([]) ->
    [];
replace_first_six([$6 | Rest]) ->
    % 找到了第一个 6，将其变为 9。
    % 注意：我们直接连接剩余部分 Rest，而不再递归调用，
    % 这样保证了只改变第一个 6。
    [$9 | Rest];
replace_first_six([Head | Tail]) ->
    % 当前字符不是 6 (即它是 9)，保持不变，继续检查剩余部分。
    [Head | replace_first_six(Tail)].