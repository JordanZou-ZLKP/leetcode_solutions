-spec sum_zero(N :: integer()) -> [integer()].
sum_zero(N) ->
    %% 使用尾递归生成列表
    %% count: 需要生成的对数 (N div 2)
    %% acc: 累加器列表
    %% is_odd: 标记 N 是否为奇数 (N rem 2)
    generate(N div 2, [], N rem 2).

%% 私有辅助函数：尾递归生成
generate(0, Acc, 1) ->
    %% 如果原始 N 是奇数，最后加上 0
    [0 | Acc];
generate(0, Acc, 0) ->
    %% 如果原始 N 是偶数，直接返回结果
    Acc;
generate(I, Acc, Rem) ->
    %% 每次迭代添加一对互为相反数的整数 [I, -I]
    %% I 从 N div 2 递减到 1
    generate(I - 1, [I, -I | Acc], Rem).