-spec score_of_parentheses(S :: unicode:unicode_binary()) -> integer().
score_of_parentheses(S) ->
    score_of_parentheses(S, 0, 0).

score_of_parentheses(<<>>, _Depth, Total) ->
    Total;
score_of_parentheses(<<$(, $), Rest/binary>>, Depth, Total) ->
    score_of_parentheses(Rest, Depth, Total + (1 bsl Depth));
score_of_parentheses(<<$(, Rest/binary>>, Depth, Total) ->
    score_of_parentheses(Rest, Depth + 1, Total);
score_of_parentheses(<<$), Rest/binary>>, Depth, Total) ->
    score_of_parentheses(Rest, Depth - 1, Total).
