-spec smallest_palindrome(S :: unicode:unicode_binary()) -> unicode:unicode_binary().
smallest_palindrome(S) ->
    Counts = count_freq(S, #{}),
    {RightHalf, Mid} = build_parts($a, Counts, [], []),
    list_to_binary(lists:reverse(RightHalf) ++ Mid ++ RightHalf).

count_freq(<<>>, Map) ->
    Map;
count_freq(<<C, Rest/binary>>, Map) ->
    count_freq(Rest, maps:update_with(C, fun(V) -> V + 1 end, 1, Map)).

build_parts(Char, _Map, Right, Mid) when Char > $z ->
    {Right, Mid};
build_parts(Char, Map, Right, Mid) ->
    case maps:find(Char, Map) of
        {ok, Count} ->
            Half = Count div 2,
            NewRight = add_chars(Char, Half, Right),
            NewMid = if Count rem 2 =:= 1 -> [Char]; true -> Mid end,
            build_parts(Char + 1, Map, NewRight, NewMid);
        error ->
            build_parts(Char + 1, Map, Right, Mid)
    end.

add_chars(_C, 0, Acc) ->
    Acc;
add_chars(C, N, Acc) ->
    add_chars(C, N - 1, [C | Acc]).