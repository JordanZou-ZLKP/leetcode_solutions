-spec replace_non_coprimes(Nums :: [integer()]) -> [integer()].
replace_non_coprimes(Nums) ->
    %% 使用 foldl 模拟遍历过程，Acc 作为栈使用
    FinalStack = lists:foldl(fun(X, Stack) -> push_and_merge(X, Stack) end, [], Nums),
    %% 栈是倒序的，最后需要反转
    lists:reverse(FinalStack).

%% @doc 尝试将元素 X 压入栈中，如果与栈顶非互质则递归合并
push_and_merge(X, []) ->
    [X];
push_and_merge(X, [Top | RestStack]) ->
    G = gcd(X, Top),
    if
        G > 1 ->
            %% 发现非互质，合并为 LCM
            Lcm = (X * Top) div G,
            %% 递归调用，尝试将新的 LCM 继续与下层栈顶合并
            push_and_merge(Lcm, RestStack);
        true ->
            %% 互质，停止合并，直接入栈
            [X, Top | RestStack]
    end.

%% @doc 计算最大公约数 (Greatest Common Divisor)
gcd(A, 0) -> A;
gcd(A, B) -> gcd(B, A rem B).