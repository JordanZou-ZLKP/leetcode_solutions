-spec has_same_digits(S :: unicode:unicode_binary()) -> boolean().
has_same_digits(One) ->
    S = binary_to_list(One),
    %% 1. 将字符串转换为整数列表 (例如 "3902" -> [3, 9, 0, 2])
    %% $0 是字符 '0' 的 ASCII 码，做减法即可得到实际整数值
    Digits = [C - $0 || C <- S],
    %% 2. 开始递归求解
    solve(Digits).

%% @doc 递归终止条件：当列表只剩下两个数字时
solve([D1, D2]) ->
    D1 =:= D2;

%% @doc 递归步骤：执行一次归约操作，然后继续递归
solve(List) ->
    NewList = reduce_step(List, []),
    solve(NewList).

%% @doc 执行单次归约操作 (尾递归优化)
%% 输入: [3, 9, 0, 2], Acc: []
%% 过程: (3+9)%10=2 -> Acc:[2]
%%       (9+0)%10=9 -> Acc:[9, 2]
%%       (0+2)%10=2 -> Acc:[2, 9, 2]
%% 结束: 翻转 Acc -> [2, 9, 2]
reduce_step([A, B | Rest], Acc) ->
    NewDigit = (A + B) rem 10,
    %% 注意：这里保留 [B | Rest] 因为 B 还需要和下一个数字相加
    reduce_step([B | Rest], [NewDigit | Acc]);
reduce_step([_Last], Acc) ->
    lists:reverse(Acc).