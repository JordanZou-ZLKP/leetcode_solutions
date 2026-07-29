-spec smallest_palindrome(S :: unicode:unicode_binary(), K :: integer()) -> unicode:unicode_binary().
smallest_palindrome(S, K) ->
    Freqs = count_freqs(S, #{}),
    {HalfCounts, MidChar, N} = lists:foldl(
        fun(Char, {HC, Mid, Total}) ->
            case maps:get(Char, Freqs, 0) of
                0 -> {HC, Mid, Total};
                Count ->
                    NewHC = if Count >= 2 -> [{Char, Count div 2} | HC]; true -> HC end,
                    NewMid = if Count rem 2 =:= 1 -> <<Char/utf8>>; true -> Mid end,
                    {NewHC, NewMid, Total + (Count div 2)}
            end
        end,
        {[], <<>>, 0},
        lists:reverse(lists:seq($a, $z))
    ),
    TotalPerms = fact(N) div lists:foldl(fun({_, C}, Acc) -> Acc * fact(C) end, 1, HalfCounts),
    if
        K > TotalPerms -> <<>>;
        true ->
            HalfList = build_half(N, HalfCounts, K, TotalPerms, []),
            HalfBin = unicode:characters_to_binary(HalfList),
            RevHalfBin = unicode:characters_to_binary(lists:reverse(HalfList)),
            <<HalfBin/binary, MidChar/binary, RevHalfBin/binary>>
    end.

count_freqs(<<Char/utf8, Rest/binary>>, Map) ->
    count_freqs(Rest, maps:update_with(Char, fun(V) -> V + 1 end, 1, Map));
count_freqs(<<>>, Map) -> Map.

fact(0) -> 1;
fact(N) -> fact(N, 1).
fact(0, Acc) -> Acc;
fact(N, Acc) -> fact(N - 1, N * Acc).

build_half(0, _Counts, _K, _Perms, Acc) -> lists:reverse(Acc);
build_half(N, Counts, K, Perms, Acc) ->
    {Char, NewCounts, NewK, NewPerms} = find_char(Counts, N, K, Perms, []),
    build_half(N - 1, NewCounts, NewK, NewPerms, [Char | Acc]).

find_char([{Char, C} | Rest], N, K, Perms, Prev) ->
    BranchPerms = (Perms * C) div N,
    if
        K =< BranchPerms ->
            NewCounts = if C =:= 1 -> lists:reverse(Prev) ++ Rest;
                           true -> lists:reverse(Prev) ++ [{Char, C - 1} | Rest]
                        end,
            {Char, NewCounts, K, BranchPerms};
        true ->
            find_char(Rest, N, K - BranchPerms, Perms, [{Char, C} | Prev])
    end.