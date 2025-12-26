-spec get_no_zero_integers(N :: integer()) -> [integer()].
get_no_zero_integers(N) ->
    find_solution(1, N).

%% 递归查找函数
%% 从 A = 1 开始尝试，直到找到符合条件的 A 和 B
find_solution(A, N) ->
    B = N - A,
    %% 检查 A 和 B 是否都不包含 '0'
    case (not has_zero(A)) andalso (not has_zero(B)) of
        true -> 
            [A, B];
        false -> 
            find_solution(A + 1, N)
    end.

%% 辅助函数：检查数字是否包含 '0'
%% 通过数学取模运算检查，比将数字转换为字符串更高效
has_zero(0) -> false; % 递归基：如果除到了0且之前没有返回true，说明原数字不含0
has_zero(X) ->
    case X rem 10 of
        0 -> true;            % 发现个位是 0
        _ -> has_zero(X div 10) % 递归检查下一位
    end.