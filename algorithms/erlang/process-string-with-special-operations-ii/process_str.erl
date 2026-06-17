-spec process_str(S :: unicode:unicode_binary(), K :: integer()) -> char().
process_str(S, K) ->
    {FinalL, History} = build_history(S, 0, []),
    if
        K >= FinalL -> $.;
        true -> find_char(History, K)
    end.

build_history(<<>>, L, Acc) ->
    {L, Acc};
build_history(<<C/utf8, Rest/binary>>, L, Acc) ->
    case C of
        $* ->
            NewL = max(0, L - 1),
            build_history(Rest, NewL, [{C, L} | Acc]);
        $# ->
            NewL = L * 2,
            build_history(Rest, NewL, [{C, L} | Acc]);
        $% ->
            build_history(Rest, L, [{C, L} | Acc]);
        _ ->
            NewL = L + 1,
            build_history(Rest, NewL, [{C, L} | Acc])
    end.

find_char([], _) ->
    $.;
find_char([{C, PrevL} | Rest], T) ->
    case C of
        $* ->
            find_char(Rest, T);
        $# ->
            if
                T >= PrevL -> find_char(Rest, T - PrevL);
                true -> find_char(Rest, T)
            end;
        $% ->
            find_char(Rest, PrevL - 1 - T);
        _ ->
            if
                T =:= PrevL -> C;
                true -> find_char(Rest, T)
            end
    end.