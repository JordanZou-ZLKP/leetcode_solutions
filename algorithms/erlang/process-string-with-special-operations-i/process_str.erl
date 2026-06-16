-spec process_str(S :: unicode:unicode_binary()) -> unicode:unicode_binary().
process_str(S) ->
    process(S, []).

process(<<>>, RevAcc) ->
    unicode:characters_to_binary(lists:reverse(RevAcc));
process(<<"*", Rest/binary>>, [_ | RevAcc]) ->
    process(Rest, RevAcc);
process(<<"*", Rest/binary>>, []) ->
    process(Rest, []);
process(<<"#", Rest/binary>>, RevAcc) ->
    process(Rest, RevAcc ++ RevAcc);
process(<<"%", Rest/binary>>, RevAcc) ->
    process(Rest, lists:reverse(RevAcc));
process(<<C/utf8, Rest/binary>>, RevAcc) ->
    process(Rest, [C | RevAcc]).