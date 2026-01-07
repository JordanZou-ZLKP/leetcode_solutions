-spec max_profit(Prices :: [integer()]) -> integer().

max_profit([]) -> 0;
max_profit([FirstPrice | Rest]) ->
    %% 初始化：
    %% MinPrice (历史最低价) 设为第一天的价格
    %% MaxProfit (当前最大利润) 设为 0
    max_profit(Rest, FirstPrice, 0).

%% 尾递归函数 (Tail Recursive)
%% Prices: 剩余的价格列表
%% MinPrice: 目前为止见过的最低买入价
%% MaxProfit: 目前为止计算出的最大利润
max_profit([], _MinPrice, MaxProfit) ->
    MaxProfit;

max_profit([CurrentPrice | Rest], MinPrice, MaxProfit) ->
    %% 1. 更新最低买入价
    %% 如果当前价格比记录的最低价还低，更新 MinPrice
    NewMinPrice = min(MinPrice, CurrentPrice),
    
    %% 2. 计算潜在利润
    %% 假设我们在 MinPrice 买入，在 CurrentPrice 卖出
    %% 注意：如果 CurrentPrice 就是 NewMinPrice，这里利润是 0，不会影响结果
    CurrentProfit = CurrentPrice - MinPrice,
    
    %% 3. 更新最大利润
    %% 如果今天的潜在利润比历史最大利润高，更新 MaxProfit
    NewMaxProfit = max(MaxProfit, CurrentProfit),
    
    %% 递归处理剩下的列表
    max_profit(Rest, NewMinPrice, NewMaxProfit).
