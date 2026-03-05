-spec find_kth_bit(N :: integer(), K :: integer()) -> char().
find_kth_bit(N, K) ->
    find_kth_bit(N, K, 0).

find_kth_bit(1, _, 0) -> 
    $0;
find_kth_bit(1, _, 1) -> 
    $1;
find_kth_bit(N, K, Inv) ->
    Mid = 1 bsl (N - 1),
    if
        K =:= Mid ->
            if 
                Inv =:= 0 -> $1; 
                true -> $0 
            end;
        K < Mid ->
            find_kth_bit(N - 1, K, Inv);
        true ->
            find_kth_bit(N - 1, (1 bsl N) - K, 1 - Inv)
    end.