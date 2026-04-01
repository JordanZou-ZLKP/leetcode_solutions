-spec find_the_string(Lcp :: [[integer()]]) -> unicode:unicode_binary().
find_the_string(Lcp) ->
    N = length(Lcp),
    LcpT = list_to_tuple([list_to_tuple(Row) || Row <- Lcp]),
    case build_string(1, N, $a, LcpT, #{}) of
        error -> <<>>;
        {ok, WordMap} ->
            WordTuple = list_to_tuple([maps:get(K, WordMap) || K <- lists:seq(1, N)]),
            case validate(N, N, WordTuple, LcpT, {}) of
                true -> list_to_binary(tuple_to_list(WordTuple));
                false -> <<>>
            end
    end.

build_string(I, N, _C, _LcpT, WordMap) when I > N ->
    {ok, WordMap};
build_string(I, N, C, LcpT, WordMap) ->
    case maps:is_key(I, WordMap) of
        true ->
            build_string(I + 1, N, C, LcpT, WordMap);
        false ->
            if C > $z ->
                   error;
               true ->
                   RowT = element(I, LcpT),
                   case assign_chars(I, N, C, RowT, WordMap) of
                       error -> error;
                       NewWordMap ->
                           case maps:is_key(I, NewWordMap) of
                               true -> build_string(I + 1, N, C + 1, LcpT, NewWordMap);
                               false -> error
                           end
                   end
            end
    end.

assign_chars(J, N, _C, _RowT, WordMap) when J > N ->
    WordMap;
assign_chars(J, N, C, RowT, WordMap) ->
    Val = element(J, RowT),
    if Val > 0 ->
           case maps:find(J, WordMap) of
               {ok, C} -> assign_chars(J + 1, N, C, RowT, WordMap);
               {ok, _} -> error;
               error -> assign_chars(J + 1, N, C, RowT, WordMap#{J => C})
           end;
       true ->
           assign_chars(J + 1, N, C, RowT, WordMap)
    end.

validate(0, _N, _WordTuple, _LcpT, _NextRowDP) ->
    true;
validate(I, N, WordTuple, LcpT, NextRowDP) ->
    RowT = element(I, LcpT),
    case validate_row(I, N, N, WordTuple, RowT, NextRowDP, []) of
        error -> false;
        NewRowDP -> validate(I - 1, N, WordTuple, LcpT, NewRowDP)
    end.

validate_row(_I, 0, _N, _WordTuple, _RowT, _NextRowDP, Acc) ->
    list_to_tuple(Acc);
validate_row(I, J, N, WordTuple, RowT, NextRowDP, Acc) ->
    CharI = element(I, WordTuple),
    CharJ = element(J, WordTuple),
    Expected = if CharI =:= CharJ ->
                      if I =:= N orelse J =:= N -> 1;
                         true -> element(J + 1, NextRowDP) + 1
                      end;
                  true -> 0
               end,
    Actual = element(J, RowT),
    if Expected =:= Actual ->
           validate_row(I, J - 1, N, WordTuple, RowT, NextRowDP, [Expected | Acc]);
       true ->
           error
    end.