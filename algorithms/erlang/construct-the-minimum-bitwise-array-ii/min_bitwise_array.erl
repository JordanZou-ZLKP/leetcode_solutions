-spec min_bitwise_array(Nums :: [integer()]) -> [integer()].
min_bitwise_array(Nums) ->
    [calc_ans(N) || N <- Nums].

%% @private 计算单个数字的答案
%% 针对 P=2 的特殊情况，无法满足条件
calc_ans(2) -> -1;
calc_ans(P) ->
    %% 1. 计算末尾连续1的长度 L
    L = count_trailing_ones(P, 0),
    %% 2. 为了使 ans 最小，我们需要翻转连续1序列中最高位的那个1
    %%    即减去 2^(L-1)
    BitToRemove = 1 bsl (L - 1),
    P - BitToRemove.

%% @private 尾递归计算末尾连续1的个数
count_trailing_ones(N, Acc) ->
    case N band 1 of
        1 -> 
            %% 如果当前位是1，继续右移并累加计数
            count_trailing_ones(N bsr 1, Acc + 1);
        0 -> 
            %% 遇到0则停止
            Acc
    end.