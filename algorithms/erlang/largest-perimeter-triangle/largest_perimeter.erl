-spec largest_perimeter(Nums :: [integer()]) -> integer().
largest_perimeter(Nums) ->
    % 1. 排序：Erlang 的 lists:sort/1 默认为升序。
    %    为了方便模式匹配处理最大值，我们先排序再反转，得到降序列表。
    SortedAsc = lists:sort(Nums),
    SortedDesc = lists:reverse(SortedAsc),
    
    % 2. 开始贪心查找
    find_largest(SortedDesc).

%% 递归函数：检查列表的前三个元素
%% Case 1: 满足三角形不等式 (两边之和大于第三边)
find_largest([A, B, C | _Rest]) when B + C > A ->
    A + B + C;

%% Case 2: 不满足不等式，丢弃头部最大的元素 A，继续递归检查 [B, C | Rest]
find_largest([_A, B, C | Rest]) ->
    find_largest([B, C | Rest]);

%% Case 3: 列表元素不足 3 个，无法组成三角形
find_largest(_) ->
    0.