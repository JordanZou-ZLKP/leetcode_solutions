-spec count_triples(N :: integer()) -> integer().

count_triples(N) when is_integer(N), N >= 1 ->
    lists:foldl(fun(C, Acc) ->
        Acc + count_for_c(C, N)
    end, 0, lists:seq(1, N)).

count_for_c(C, N) ->
    lists:foldl(fun(A, Acc) ->
        B_squared = C*C - A*A,
        
        B = is_perfect_square(B_squared),
        
        case B of
            0 -> Acc;
            _ when B >= 1, B =< N ->
                Acc + 1;
            _ ->
                Acc
        end
    end, 0, lists:seq(1, C - 1)).

is_perfect_square(Target) when is_integer(Target), Target >= 0 ->
    FloatRoot = math:sqrt(Target),
    
    IntRoot = round(FloatRoot),
    
    case IntRoot * IntRoot == Target of
        true -> IntRoot;
        false -> 0
    end.