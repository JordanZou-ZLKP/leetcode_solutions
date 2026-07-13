-spec array_rank_transform(Arr :: [integer()]) -> [integer()].
array_rank_transform(Arr) ->
    UniqueSorted = lists:usort(Arr),
    RankMap = build_rank_map(UniqueSorted, 1, #{}),
    [maps:get(X, RankMap) || X <- Arr].

build_rank_map([], _Rank, Map) ->
    Map;
build_rank_map([H | T], Rank, Map) ->
    build_rank_map(T, Rank + 1, Map#{H => Rank}).