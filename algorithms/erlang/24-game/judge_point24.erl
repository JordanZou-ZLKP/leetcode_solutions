-spec judge_point24(Cards :: [integer()]) -> boolean().

-define(EPSILON, 1.0e-6).

%% @doc 入口函数
%% Input: Cards 是一个包含4个整数的列表
%% Output: boolean()
judge_point24(Cards) ->
    %% 1. 将整数列表转换为浮点数列表，便于进行实数除法
    FloatList = [float(X) || X <- Cards],
    %% 2. 开始递归求解
    solve(FloatList).

%% @private
%% 基本情况：当列表只剩下一个数字时
solve([Result]) ->
    %% 检查结果是否足够接近 24.0
    abs(Result - 24.0) < ?EPSILON;

%% @private
%% 递归步骤：当列表有多个数字时
solve(List) ->
    Len = length(List),
    Seq = lists:seq(1, Len),
    
    %% 我们需要从列表中选取两个不同的索引 I 和 J
    %% lists:any 只要找到一个 true 就会立即停止并返回 true，起到剪枝作用
    lists:any(fun(I) ->
        lists:any(fun(J) ->
            %% 确保只处理一次组合 (I < J)，我们在 valid_ops 中处理交换律
            if 
                I >= J -> false; 
                true ->
                    %% 获取两个操作数
                    A = lists:nth(I, List),
                    B = lists:nth(J, List),
                    
                    %% 获取剩余的列表（未被选中的数字）
                    %% 注意：这里列表很短，使用 filter 性能损耗可忽略
                    Rest = [X || {X, K} <- lists:zip(List, Seq), K =/= I, K =/= J],
                    
                    %% 计算这两个数所有可能的运算结果
                    NextValues = valid_ops(A, B),
                    
                    %% 对每一个运算结果，将其加入剩余列表，继续递归
                    lists:any(fun(Val) -> 
                        solve([Val | Rest]) 
                    end, NextValues)
            end
        end, Seq)
    end, Seq).

%% @private
%% 给定两个数 A 和 B，生成所有有效的运算结果
valid_ops(A, B) ->
    %% 加法和乘法满足交换律，只需计算一次
    Base = [A + B, A - B, B - A, A * B],
    
    %% 处理除法，必须防止除以零
    %% 因为是浮点数，判断绝对值是否大于极小值
    Div1 = if abs(B) > ?EPSILON -> [A / B]; true -> [] end,
    Div2 = if abs(A) > ?EPSILON -> [B / A]; true -> [] end,
    
    Base ++ Div1 ++ Div2.