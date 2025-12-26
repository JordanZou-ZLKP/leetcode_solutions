-spec triangle_number(Nums :: [integer()]) -> integer().
triangle_number(Nums) when length(Nums) < 3 ->
    0;
triangle_number(Nums) ->
    %% 1. 排序 (O(N log N))
    SortedList = lists:sort(Nums),
    %% 2. 转换为元组以实现 O(1) 访问 (O(N))
    Tuple = list_to_tuple(SortedList),
    N = tuple_size(Tuple),
    %% 3. 开始遍历 (O(N^2))
    %% 从最大的边开始倒序遍历 (索引 N 到 3)
    loop_k(N, Tuple, 0).

%% 外层循环：固定最长边 K
loop_k(K, _Tuple, Count) when K < 3 ->
    Count;
loop_k(K, Tuple, Count) ->
    %% 获取当前最长边
    Target = element(K, Tuple),
    %% 设定双指针：I 指向开始，J 指向 K 的前一个元素
    AddedCount = two_pointers(1, K - 1, Target, Tuple, 0),
    loop_k(K - 1, Tuple, Count + AddedCount).

%% 内层循环：双指针查找符合条件的对
two_pointers(I, J, _Target, _Tuple, Acc) when I >= J ->
    Acc;
two_pointers(I, J, Target, Tuple, Acc) ->
    ValI = element(I, Tuple),
    ValJ = element(J, Tuple),
    if
        %% 如果 nums[i] + nums[j] > nums[k]
        %% 那么对于当前的 j，所有索引在 i 到 j-1 之间的元素 x
        %% 都必然满足 nums[x] + nums[j] > nums[k] (因为数组已排序)
        ValI + ValJ > Target ->
            %% 加上 (J - I) 个有效组合
            NewAcc = Acc + (J - I),
            %% 尝试更小的 nums[j]
            two_pointers(I, J - 1, Target, Tuple, NewAcc);
        true ->
            %% 和不够大，需要更大的 nums[i]
            two_pointers(I + 1, J, Target, Tuple, Acc)
    end.