-spec has_all_codes(S :: unicode:unicode_binary(), K :: integer()) -> boolean().
has_all_codes(S, K) ->
    Target = 1 bsl K,
    if
        byte_size(S) < Target + K - 1 -> 
            false;
        true ->
            Mask = Target - 1,
            <<First:K/binary, Rest/binary>> = S,
            InitVal = parse_first(First, 0),
            Seen = #{InitVal => true},
            if
                map_size(Seen) =:= Target -> true;
                true -> roll(Rest, Mask, InitVal, Target, Seen)
            end
    end.

parse_first(<<>>, Acc) -> 
    Acc;
parse_first(<<C:8, Rest/binary>>, Acc) ->
    parse_first(Rest, (Acc bsl 1) bor (C - $0)).

roll(<<>>, _, _, _, _) -> 
    false;
roll(<<C:8, Rest/binary>>, Mask, Val, Target, Seen) ->
    NewVal = ((Val bsl 1) band Mask) bor (C - $0),
    NewSeen = Seen#{NewVal => true},
    if
        map_size(NewSeen) =:= Target -> true;
        true -> roll(Rest, Mask, NewVal, Target, NewSeen)
    end.