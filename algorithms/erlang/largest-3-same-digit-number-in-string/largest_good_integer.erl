-spec largest_good_integer(Num :: unicode:unicode_binary()) -> unicode:unicode_binary().
largest_good_integer(One) ->
    Num = binary_to_list(One),
    %% 初始 Max 设为 -1，表示尚未找到任何 good integer
    Two = search(Num, -1),
    R = list_to_binary(Two).

%% 优化：如果找到了 "999"，由于它是最大的可能值，直接返回，不需要继续搜索。
%% $9 是字符 '9' 的 ASCII 码。
search([$9, $9, $9 | _], _) ->
    "999";

%% 匹配到三个连续相同的字符 X
search([X, X, X | Rest], Max) ->
    %% 如果当前的 X 比之前记录的 Max 大，则更新 Max
    NewMax = if 
        X > Max -> X; 
        true -> Max 
    end,
    %% 继续递归。注意：这里我们传入 [X, X | Rest] 而不是 Rest，
    %% 虽然题目要求长度为3且唯一，逻辑上移动一位即可，
    %% 但在当前匹配结构下，只要保留尾部继续递归即可覆盖所有情况。
    %% 实际上，为了效率和逻辑简单，直接递归剩下部分即可，
    %% 但为了严谨处理像 "1111" 这样的重叠（虽然结果一样），
    %% 我们继续递归 [X, X | Rest] 是安全的写法。
    search([X, X | Rest], NewMax);

%% 如果头部不满足三连击，剥离第一个字符继续递归
search([_ | Rest], Max) ->
    search(Rest, Max);

%% Base Case: 列表剩余长度不足3个 (匹配不到上面的模式)，结束递归
search(_, -1) ->
    ""; %% 如果 Max 还是 -1，说明没找到
search(_, Max) ->
    lists:duplicate(3, Max).