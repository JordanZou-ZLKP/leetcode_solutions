-spec compare_version(Version1 :: unicode:unicode_binary(), Version2 :: unicode:unicode_binary()) -> integer().
compare_version(One, Two) ->
    Version1 = binary_to_list(One),
    Version2 = binary_to_list(Two),
    %% 将字符串按 "." 分割并转换为整数列表
    List1 = [list_to_integer(X) || X <- string:lexemes(Version1, ".")],
    List2 = [list_to_integer(X) || X <- string:lexemes(Version2, ".")],
    do_compare(List1, List2).

%% 递归比较函数
%% 情况 1: 两个列表都还有元素
do_compare([H1|T1], [H2|T2]) ->
    if
        H1 > H2 -> 1;
        H1 < H2 -> -1;
        true    -> do_compare(T1, T2)
    end;

%% 情况 2: Version1 较短，检查 Version2 剩余部分是否全为 0
do_compare([], [H2|T2]) ->
    if
        H2 > 0 -> -1;
        true   -> do_compare([], T2)
    end;

%% 情况 3: Version2 较短，检查 Version1 剩余部分是否全为 0
do_compare([H1|T1], []) ->
    if
        H1 > 0 -> 1;
        true   -> do_compare(T1, [])
    end;

%% 情况 4: 两个列表都已遍历完且完全相等
do_compare([], []) ->
    0.