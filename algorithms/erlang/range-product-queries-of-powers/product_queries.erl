-spec product_queries(N :: integer(), Queries :: [[integer()]]) -> [integer()].
-define(MOD, 1000000007).

product_queries(N, Queries) ->

    % 1. 将 N 分解为 2 的幂的列表
    PowersList = get_powers(N, 1, []),
    
    % 2. 转换为 Tuple 以便实现 O(1) 的随机访问
    PowersTuple = list_to_tuple(PowersList),
    
    % 3. 处理每一个查询
    [solve_query(L, R, PowersTuple) || [L, R] <- Queries].

%% @doc 将 N 分解为二进制对应的数值列表 (2^k)
%% Val: 当前位的权值 (1, 2, 4, 8...)
%% Acc: 累加器
get_powers(0, _, Acc) ->
    % 结果需要反转以保持非递减顺序 (因为我们是把小的放在头部 cons 进去的，
    % 但实际上二进制从低位到高位处理，最后 lists:reverse 即可得到从小到大)
    lists:reverse(Acc);
get_powers(N, Val, Acc) ->
    NewAcc = case N band 1 of
        1 -> [Val | Acc];
        0 -> Acc
    end,
    % 递归处理下一位，Val 乘以 2
    get_powers(N bsr 1, Val bsl 1, NewAcc).

%% @doc 计算单个查询区间 [L, R] 的乘积
solve_query(L, R, PowersTuple) ->
    calc_product(L, R, PowersTuple, 1).

%% @doc 递归计算乘积，带有 Modulo
%% 注意：题目 Query 是 0-indexed，但 Erlang tuple 是 1-indexed，
%% 所以 element 取值时使用 Index + 1
calc_product(Index, R, _, Acc) when Index > R ->
    Acc;
calc_product(Index, R, Tuple, Acc) ->
    % 获取第 Index 个 power (注意 +1)
    Val = element(Index + 1, Tuple),
    % 计算 (Acc * Val) % MOD
    NewAcc = (Acc * Val) rem ?MOD,
    calc_product(Index + 1, R, Tuple, NewAcc).