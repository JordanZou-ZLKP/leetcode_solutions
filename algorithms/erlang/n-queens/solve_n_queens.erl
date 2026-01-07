-spec solve_n_queens(N :: integer()) -> [[unicode:unicode_binary()]].

to_binary(Ones) ->
    R = [list_to_binary(X) || X <- Ones].

solve_n_queens(N) ->
    % 1. 计算所有解的列索引配置，例如 [[1, 3, 0, 2], ...]
    RawSolutions = solve(N, 0, []),
    % 2. 将数字配置转换为题目要求的 ".Q.." 字符串格式
    Rone = format_solutions(RawSolutions, N),
    R = [to_binary(X) || X <- Rone].

%% 核心回溯逻辑
%% N: 棋盘大小
%% Row: 当前正在处理的行号
%% Placements: 之前放置好的皇后位置列表（倒序，Head是上一行的列索引）
solve(N, Row, Placements) when Row == N ->
    % 这里的 Placements 是倒序的，即 [最后一行的列, ..., 第0行的列]
    % 我们先不反转，留给 formatting 阶段处理，或者直接返回
    [Placements];
solve(N, Row, Placements) ->
    % 尝试当前行的所有列 (0 到 N-1)
    lists:flatmap(fun(Col) ->
        case is_safe(Col, 1, Placements) of
            true -> 
                % 如果当前位置安全，继续递归下一行
                solve(N, Row + 1, [Col | Placements]);
            false -> 
                % 如果不安全，返回空列表（剪枝）
                []
        end
    end, lists:seq(0, N-1)).

%% 安全性检查
%% Col: 当前尝试放置的列
%% Dist: 当前行与正在检查的历史行的行距 (垂直距离)
%% Rest: 之前放置的皇后列索引列表
is_safe(_Col, _Dist, []) -> 
    true;
is_safe(Col, Dist, [PrevCol | Rest]) ->
    % 1. 列冲突检查: Col == PrevCol
    % 2. 对角线冲突检查: |Col - PrevCol| == Dist
    Col =/= PrevCol andalso 
    abs(Col - PrevCol) =/= Dist andalso 
    is_safe(Col, Dist + 1, Rest).

%% --- 格式化输出辅助函数 ---

format_solutions(Solutions, N) ->
    [ format_board(lists:reverse(Sol), N) || Sol <- Solutions ].

format_board(Cols, N) ->
    [ format_row(C, N) || C <- Cols ].

format_row(QCol, N) ->
    % 构建一行字符串，例如 ".Q.."
    % 左边的 '.' 个数 = QCol
    % 右边的 '.' 个数 = N - 1 - QCol
    lists:flatten([
        lists:duplicate(QCol, $.),
        $Q,
        lists:duplicate(N - QCol - 1, $.)
    ]).

