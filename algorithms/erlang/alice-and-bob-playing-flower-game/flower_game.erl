-spec flower_game(N :: integer(), M :: integer()) -> integer().
flower_game(N, M) ->
    % 计算 [1, N] 中奇数和偶数的数量
    EvenX = N div 2,
    OddX = (N + 1) div 2,

    % 计算 [1, M] 中奇数和偶数的数量
    EvenY = M div 2,
    OddY = (M + 1) div 2,

    % Alice 获胜的情况有两种组合：
    % 1. X 是偶数，Y 是奇数
    % 2. X 是奇数，Y 是偶数
    (EvenX * OddY) + (OddX * EvenY).