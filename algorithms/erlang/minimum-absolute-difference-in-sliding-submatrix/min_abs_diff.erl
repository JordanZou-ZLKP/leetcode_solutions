-spec min_abs_diff(Grid :: [[integer()]], K :: integer()) -> [[integer()]].
min_abs_diff(Grid, K) ->
    [process_row_window(RW, K) || RW <- windows(Grid, K)].

windows(List, K) ->
    case length(List) >= K of
        true -> [lists:sublist(List, K) | windows(tl(List), K)];
        false -> []
    end.

process_row_window(RW, K) ->
    [min_diff(CW) || CW <- windows(transpose(RW), K)].

transpose([[] | _]) -> 
    [];
transpose(M) ->
    [[hd(R) || R <- M] | transpose([tl(R) || R <- M])].

min_diff(List) ->
    case lists:usort(lists:flatten(List)) of
        [] -> 0;
        [_] -> 0;
        [H1, H2 | T] -> find_min_diff(T, H2, H2 - H1)
    end.

find_min_diff([], _, Min) -> 
    Min;
find_min_diff([H | T], Prev, Min) ->
    Diff = H - Prev,
    if Diff < Min -> find_min_diff(T, H, Diff);
       true -> find_min_diff(T, H, Min)
    end.