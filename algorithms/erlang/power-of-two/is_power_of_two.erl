-spec is_power_of_two(N :: integer()) -> boolean().
is_power_of_two(N) ->
    %% 逻辑解释:
    %% 1. N > 0: 2的幂必须是正整数 (排除 0 和负数)
    %% 2. (N band (N - 1)) =:= 0: 利用位运算特性去除最低位的 1
    N > 0 andalso (N band (N - 1)) =:= 0.