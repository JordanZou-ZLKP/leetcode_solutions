-spec min_operations(S :: unicode:unicode_binary()) -> integer().
min_operations(S) ->
    case is_sorted(S) of
        true -> 0;
        false ->
            N = byte_size(S),
            if
                N == 2 -> -1;
                true ->
                    {MinChar, MaxChar} = find_min_max(S),
                    FirstChar = binary:at(S, 0),
                    LastChar = binary:at(S, N - 1),
                    if
                        FirstChar == MinChar orelse LastChar == MaxChar -> 1;
                        true ->
                            MinCount = count_char(S, MinChar, 0),
                            MaxCount = count_char(S, MaxChar, 0),
                            if
                                FirstChar == MaxChar, LastChar == MinChar, MaxCount == 1, MinCount == 1 -> 3;
                                true -> 2
                            end
                    end
            end
    end.

is_sorted(<<>>) -> true;
is_sorted(<<_>>) -> true;
is_sorted(<<A, B, Rest/binary>>) when A =< B -> is_sorted(<<B, Rest/binary>>);
is_sorted(_) -> false.

find_min_max(<<H, T/binary>>) ->
    find_min_max(T, H, H).

find_min_max(<<H, T/binary>>, Min, Max) when H < Min ->
    find_min_max(T, H, Max);
find_min_max(<<H, T/binary>>, Min, Max) when H > Max ->
    find_min_max(T, Min, H);
find_min_max(<<_, T/binary>>, Min, Max) ->
    find_min_max(T, Min, Max);
find_min_max(<<>>, Min, Max) ->
    {Min, Max}.

count_char(<<C, Rest/binary>>, Char, Count) when C =:= Char ->
    count_char(Rest, Char, Count + 1);
count_char(<<_, Rest/binary>>, Char, Count) ->
    count_char(Rest, Char, Count);
count_char(<<>>, _, Count) ->
    Count.

