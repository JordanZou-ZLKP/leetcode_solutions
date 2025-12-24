-spec reordered_power_of2(N :: integer()) -> boolean().

reordered_power_of2(N) ->
    % 1. 获取输入 N 的数字指纹（排序后的数字列表）
    NSignature = get_signature(N),
    
    % 2. 检查 2^0 到 2^29 之间是否有指纹匹配的数字
    % 1 bsl 29 是 536,870,912 (小于 10^9 的最大 2 的幂)
    check_powers(0, 29, NSignature).

%% ====================================================================
%% Internal Functions
%% ====================================================================

%% 递归检查 2 的幂次方
check_powers(CurrentExp, MaxExp, _TargetSig) when CurrentExp > MaxExp ->
    false;
check_powers(CurrentExp, MaxExp, TargetSig) ->
    PowerOfTwo = 1 bsl CurrentExp, % 计算 2^CurrentExp
    PowerSig = get_signature(PowerOfTwo),
    
    case PowerSig =:= TargetSig of
        true  -> true;
        false -> check_powers(CurrentExp + 1, MaxExp, TargetSig)
    end.

%% 将数字转换为排序后的字符串 (例如: 46 -> "46", 64 -> "46")
%% 这里的复杂度极低，因为数字长度最大仅为 10
get_signature(Num) ->
    lists:sort(integer_to_list(Num)).