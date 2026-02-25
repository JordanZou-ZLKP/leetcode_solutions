-spec make_largest_special(S :: unicode:unicode_binary()) -> unicode:unicode_binary().

make_largest_special(<<>>) ->
    <<>>;
make_largest_special(S) ->
    Parts = collect_parts(S, []),
    SortedParts = lists:sort(fun(A, B) -> A >= B end, Parts),
    erlang:iolist_to_binary(SortedParts).

collect_parts(<<>>, Acc) ->
    Acc;
collect_parts(S, Acc) ->
    {Inner, Rest} = extract_inner(S, 0, 0),
    ProcessedInner = make_largest_special(Inner),
    Part = <<$1, ProcessedInner/binary, $0>>,
    collect_parts(Rest, [Part | Acc]).

extract_inner(S, Index, Count) ->
    <<C, _/binary>> = binary_part(S, Index, 1),
    NextCount = if C =:= $1 -> Count + 1; true -> Count - 1 end,
    NextIndex = Index + 1,
    if
        NextCount =:= 0 ->
            Inner = binary_part(S, 1, NextIndex - 2),
            Rest = binary_part(S, NextIndex, byte_size(S) - NextIndex),
            {Inner, Rest};
        true ->
            extract_inner(S, NextIndex, NextCount)
    end.