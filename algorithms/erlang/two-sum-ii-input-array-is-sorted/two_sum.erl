-spec two_sum(Numbers :: [integer()], Target :: integer()) -> [integer()].
two_sum(Numbers, Target) ->
    T = list_to_tuple(Numbers),
    find(T, 1, tuple_size(T), Target).

find(T, L, R, Target) ->
    Sum = element(L, T) + element(R, T),
    if
        Sum == Target -> [L, R];
        Sum < Target -> find(T, L + 1, R, Target);
        true -> find(T, L, R - 1, Target)
    end.