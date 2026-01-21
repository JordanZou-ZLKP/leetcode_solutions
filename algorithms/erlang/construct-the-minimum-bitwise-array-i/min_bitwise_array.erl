-spec min_bitwise_array(Nums :: [integer()]) -> [integer()].
min_bitwise_array(Nums) ->
    [calc_min_ans(X) || X <- Nums].

%% @doc 针对单个数字计算最小的 ans
%% 情况1: 如果数字是 2，无法满足条件 (2 是偶数，且 ans | (ans+1) >= ans+1 > ans)
%% x | (x+1) 的结果末尾必然是1（除非x是全1序列的变换，但在本题语境下，结果P为质数且P>=2）
%% 对于偶数质数2，二进制是10，没有任何x使得 x | (x+1) = 2。
calc_min_ans(2) -> 
    -1;

%% 情况2: 对于其他质数 (均为奇数)
%% 算法逻辑：
%% 1. P 是奇数，二进制末尾必有一串连续的 1。
%% 2. S = P + 1，S 会导致 P 末尾连续的 1 变为 0，并进位。
%%    例如 P = 11 (1011), S = 12 (1100)。
%% 3. LowBit = S & -S 取出 S 的最低位 1。
%%    12 (1100) 的 LowBit 是 4 (0100)。
%% 4. 我们需要翻转的位是 LowBit 的右边一位，即 LowBit / 2。
%%    4 / 2 = 2。
%% 5. 结果 = P - 2 = 11 - 2 = 9。
calc_min_ans(P) ->
    S = P + 1,
    %% Erlang 中负数补码处理符合 & -X 取 lowbit 的逻辑
    LowBit = S band (-S),
    Mask = LowBit bsr 1,
    P - Mask.