-spec num_of_strings(Patterns :: [unicode:unicode_binary()], Word :: unicode:unicode_binary()) -> integer().
num_of_strings(Patterns, Word) ->
    do_count(Patterns, Word, 0).

do_count([], _, Count) ->
    Count;
do_count([Pattern | Tail], Word, Count) ->
    case binary:match(Word, Pattern) of
        nomatch ->
            do_count(Tail, Word, Count);
        _ ->
            do_count(Tail, Word, Count + 1)
    end.