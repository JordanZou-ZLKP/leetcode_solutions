-spec check_ones_segment(S :: unicode:unicode_binary()) -> boolean().
check_ones_segment(S) ->
    case binary:match(S, <<"01">>) of
        nomatch -> true;
        _ -> false
    end.