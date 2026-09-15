-spec max_palindromes(S :: unicode:unicode_binary(), K :: integer()) -> integer().
max_palindromes(S, 1) ->
    byte_size(S);
max_palindromes(S, K) ->
    Len = byte_size(S),
    L1 = [{I + K - 1, I} || I <- seq(1, Len - K + 1), is_pal(S, I - 1, I + K - 2)],
    L2 = [{I + K, I} || I <- seq(1, Len - K), is_pal(S, I - 1, I + K - 1)],
    greedy(lists:sort(L1 ++ L2), 0, 0).

seq(A, B) when A =< B -> lists:seq(A, B);
seq(_, _) -> [].

is_pal(_S, Left, Right) when Left >= Right -> true;
is_pal(S, Left, Right) ->
    case binary:at(S, Left) =:= binary:at(S, Right) of
        true -> is_pal(S, Left + 1, Right - 1);
        false -> false
    end.

greedy([{End, Start} | T], LastEnd, Count) ->
    case Start > LastEnd of
        true -> greedy(T, End, Count + 1);
        false -> greedy(T, LastEnd, Count)
    end;
greedy([], _, Count) ->
    Count.
