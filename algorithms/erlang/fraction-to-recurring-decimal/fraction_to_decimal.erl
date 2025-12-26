-spec fraction_to_decimal(Numerator :: integer(), Denominator :: integer()) -> unicode:unicode_binary().
fraction_to_decimal(Numerator, Denominator) ->
    if
        Numerator == 0 -> 
            R =  "0";
        true ->
            % 1. 处理符号
            Sign = if (Numerator < 0) xor (Denominator < 0) -> "-"; true -> "" end,
            
            % 2. 取绝对值防止负数取模的差异
            AbsNum = abs(Numerator),
            AbsDen = abs(Denominator),
            
            % 3. 计算整数部分
            IntPart = integer_to_list(AbsNum div AbsDen),
            Remainder = AbsNum rem AbsDen,
            
            % 4. 计算小数部分
            if
                Remainder == 0 ->
                    R = Sign ++ IntPart;
                true ->
                    FractionPart = solve_fraction(Remainder, AbsDen, 0, #{}, []),
                    R = Sign ++ IntPart ++ "." ++ FractionPart
            end
    end,
    One = list_to_binary(R).
%% @private
%% Rem: 当前余数
%% Den: 分母
%% Index: 当前小数位的索引
%% Map: 存储 {余数 => 索引} 用于检测循环
%% Acc: 累积的结果字符列表 (逆序存储)
solve_fraction(0, _Den, _Index, _Map, Acc) ->
    % Base Case 1: 余数为0，除尽了，直接返回反转后的字符串
    lists:reverse(Acc);

solve_fraction(Rem, Den, Index, Map, Acc) ->
    case maps:find(Rem, Map) of
        {ok, StartIndex} ->
            % Base Case 2: 发现重复的余数，说明出现了循环节
            % 此时 Acc 是逆序的数字字符列表，我们需要先将其反转回正序
            Digits = lists:reverse(Acc),
            
            % 将列表拆分为 [不循环部分, 循环部分]
            % StartIndex 是循环开始的位置
            {NonRepeating, Repeating} = lists:split(StartIndex, Digits),
            
            % 拼接结果
            NonRepeating ++ "(" ++ Repeating ++ ")";
        
        error ->
            % Recursive Step: 继续长除法
            % 记录当前余数及其索引
            NewMap = maps:put(Rem, Index, Map),
            
            % 模拟长除法的一步：余数 * 10 / 分母
            Num = Rem * 10,
            Digit = Num div Den,
            NewRem = Num rem Den,
            
            % 将数字转换为字符 ($0 是字符 '0' 的 ASCII 码)
            Char = Digit + $0,
            
            % 递归调用
            solve_fraction(NewRem, Den, Index + 1, NewMap, [Char | Acc])
    end.