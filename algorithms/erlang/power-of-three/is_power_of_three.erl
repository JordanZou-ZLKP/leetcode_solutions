-spec is_power_of_three(N :: integer()) -> boolean().

is_power_of_three(N) when N > 0 ->
    %% 32位有符号整数范围内，最大的3的幂是 3^19 = 1162261467
    MaxPowerOfThree = 1162261467,
    
    %% 如果 N 是 3 的幂，它一定能被 MaxPowerOfThree 整除
    MaxPowerOfThree rem N == 0;

%% 处理 N <= 0 的情况
is_power_of_three(_) ->
    false.