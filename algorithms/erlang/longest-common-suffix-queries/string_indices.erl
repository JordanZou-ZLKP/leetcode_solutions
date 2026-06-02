-spec string_indices(WordsContainer :: [unicode:unicode_binary()], WordsQuery :: [unicode:unicode_binary()]) -> [integer()].
string_indices(WordsContainer, WordsQuery) ->
    Trie = build_trie(WordsContainer, 0, {infinity, infinity, #{}}),
    [search(lists:reverse(binary_to_list(Q)), Trie) || Q <- WordsQuery].

build_trie([], _, Trie) ->
    Trie;
build_trie([W | Rest], Idx, Trie) ->
    Len = byte_size(W),
    RevW = lists:reverse(binary_to_list(W)),
    NewTrie = insert(RevW, Len, Idx, Trie),
    build_trie(Rest, Idx + 1, NewTrie).

insert([], Len, Idx, {CBL, CBI, Children}) ->
    {NBL, NBI} = update_best(Len, Idx, CBL, CBI),
    {NBL, NBI, Children};
insert([C | Rest], Len, Idx, {CBL, CBI, Children}) ->
    {NBL, NBI} = update_best(Len, Idx, CBL, CBI),
    Child = maps:get(C, Children, {infinity, infinity, #{}}),
    NewChild = insert(Rest, Len, Idx, Child),
    {NBL, NBI, Children#{C => NewChild}}.

update_best(L1, I1, L2, _) when L1 < L2 -> 
    {L1, I1};
update_best(L1, I1, L2, I2) when L1 == L2, I1 < I2 -> 
    {L1, I1};
update_best(_, _, L2, I2) -> 
    {L2, I2}.

search([], {_, BestIdx, _}) ->
    BestIdx;
search([C | Rest], {_, BestIdx, Children}) ->
    case maps:find(C, Children) of
        {ok, Child} -> search(Rest, Child);
        error -> BestIdx
    end.