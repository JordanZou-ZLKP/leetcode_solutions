-spec num_water_bottles(NumBottles :: integer(), NumExchange :: integer()) -> integer().
num_water_bottles(NumBottles, NumExchange) ->
    %% 初始调用：NumBottles是满的，0个空瓶，已喝0瓶
    solve(NumBottles, 0, NumExchange, 0).

%% @doc 尾递归辅助函数
%% CurrentFull: 当前手里的满瓶
%% CurrentEmpty: 当前手里的空瓶
%% ExchangeRate: 兑换单价
%% TotalDrank: 累计喝掉的数量 (累加器)
solve(0, _CurrentEmpty, _ExchangeRate, TotalDrank) ->
    %% Base Case: 如果没有满瓶水了，停止，返回总数
    TotalDrank;

solve(CurrentFull, CurrentEmpty, ExchangeRate, TotalDrank) ->
    %% 1. 喝掉当前所有的满瓶水
    NewTotalDrank = TotalDrank + CurrentFull,
    
    %% 2. 喝完后变成空瓶，加上原本手里剩下的空瓶
    TotalEmpty = CurrentEmpty + CurrentFull,
    
    %% 3. 计算可以兑换多少新满瓶
    NewFull = TotalEmpty div ExchangeRate,
    
    %% 4. 计算兑换后剩下的空瓶 (不够兑换的部分)
    RemainingEmpty = TotalEmpty rem ExchangeRate,
    
    %% 5. 递归下一轮
    solve(NewFull, RemainingEmpty, ExchangeRate, NewTotalDrank).