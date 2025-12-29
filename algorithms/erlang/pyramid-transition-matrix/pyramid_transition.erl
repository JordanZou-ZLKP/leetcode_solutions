-spec pyramid_transition(Bottom :: unicode:unicode_binary(), Allowed :: [unicode:unicode_binary()]) -> boolean().

-type block() :: char().
-type pattern_map() :: #{{block(), block()} => [block()]}.

%% @doc 主入口函数
%% Bottom: string() (e.g., "BCD")
%% Allowed: [string()] (e.g., ["BCC", "CDE"])

to_list(Ones) ->
    R = [binary_to_list(X) || X <- Ones].

pyramid_transition(One, Two) ->
    Bottom = binary_to_list(One),
    Allowed = to_list(Two),
    % 1. 预处理：将 allowed 列表转化为 Map 以便 O(1) 查找
    Map = parse_allowed(Allowed),
    % 2. 开始 DFS
    solve(Bottom, Map).

%% @doc 解析 allowed 列表为 Map
%% 例如 ["ABC"] -> #{{$A, $B} => "C"}
-spec parse_allowed([string()]) -> pattern_map().
parse_allowed(Allowed) ->
    lists:foldl(fun([L, R, Top], Acc) ->
        Key = {L, R},
        case maps:find(Key, Acc) of
            {ok, Tops} -> Acc#{Key => [Top | Tops]};
            error -> Acc#{Key => [Top]}
        end
    end, #{}, Allowed).

%% @doc 核心 DFS 函数
-spec solve(string(), pattern_map()) -> boolean().
solve(Row, _Map) when length(Row) == 1 ->
    true; % 成功到达金字塔顶端
solve(Row, Map) ->
    % 生成所有可能的上一层（即金字塔的更高一层）
    % 如果某一层无法生成（中间断裂），NextRows 将为空
    NextRows = generate_next_rows(Row, Map),
    % 尝试任何一条路径，如果有一条通向终点，则返回 true
    lists:any(fun(NextRow) -> solve(NextRow, Map) end, NextRows).

%% @doc 给定当前层，生成所有合法的上一层列表
%% 这是一个笛卡尔积过程
-spec generate_next_rows(string(), pattern_map()) -> [string()].
generate_next_rows([_Last], _Map) ->
    [[]]; % 边界：当前层只剩一个元素时，递归结束，返回由空列表组成的列表
generate_next_rows([L, R | Rest], Map) ->
    % 查找当前相邻两个积木 L 和 R 能生成的顶部积木
    PossibleTops = maps:get({L, R}, Map, []),
    
    % 如果没有合法的顶部积木，这层路径就死掉了，直接返回 []
    case PossibleTops of
        [] -> [];
        _ ->
            % 递归生成剩余部分的后缀
            Suffixes = generate_next_rows([R | Rest], Map),
            % 组合当前可能的 Top 和所有可能的后缀
            [ [Top | Suffix] || Top <- PossibleTops, Suffix <- Suffixes ]
    end.  