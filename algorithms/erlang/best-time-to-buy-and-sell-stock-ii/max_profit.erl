-spec max_profit(Prices :: [integer()]) -> integer().
max_profit(Prices) ->
    calculate_profit(Prices, 0).

%% @private
%% 基本情况：列表为空或只剩一个元素时，计算结束，返回累加器
calculate_profit([], Acc) -> 
    Acc;
calculate_profit([_], Acc) -> 
    Acc;

%% 递归情况 1：第二天价格 (P2) 大于第一天 (P1)
%% 这是一个获利机会，将差价加入 Acc，并继续处理剩余部分
calculate_profit([P1, P2 | Rest], Acc) when P2 > P1 ->
    calculate_profit([P2 | Rest], Acc + (P2 - P1));

%% 递归情况 2：第二天价格 (P2) 小于或等于第一天
%% 无利可图，跳过 P1，继续处理 P2 和后面的元素
calculate_profit([_P1, P2 | Rest], Acc) ->
    calculate_profit([P2 | Rest], Acc).
