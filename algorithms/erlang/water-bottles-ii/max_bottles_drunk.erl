-spec max_bottles_drunk(NumBottles :: integer(), NumExchange :: integer()) -> integer().
max_bottles_drunk(NumBottles, NumExchange) ->
    % 初始状态：
    % 1. 先把所有满瓶都喝掉，总饮用量 = NumBottles
    % 2. 手里剩下的空瓶 = NumBottles
    % 3. 当前兑换成本 = NumExchange
    solve(NumBottles, NumBottles, NumExchange).

%% 尾递归辅助函数
solve(Drunk, Empty, ExchangeCost) ->
    if
        Empty >= ExchangeCost ->
            % 执行兑换操作：
            % 1. 消耗 ExchangeCost 个空瓶
            % 2. 得到 1 个满瓶，立即喝掉 (Drunk + 1)
            % 3. 喝完后产生 1 个空瓶，所以空瓶净变化为 (- ExchangeCost + 1)
            % 4. 下一次兑换成本增加 1 (ExchangeCost + 1)
            solve(Drunk + 1, Empty - ExchangeCost + 1, ExchangeCost + 1);
        true ->
            % 空瓶不足以兑换，返回总数
            Drunk
    end.