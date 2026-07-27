-spec max_product(Nums :: [integer()]) -> integer().
max_product(Nums) ->
    find_max(Nums, 0, 0).

find_max([], Max1, Max2) ->
    (Max1 - 1) * (Max2 - 1);
find_max([H | T], Max1, _Max2) when H > Max1 ->
    find_max(T, H, Max1);
find_max([H | T], Max1, Max2) when H > Max2 ->
    find_max(T, Max1, H);
find_max([_ | T], Max1, Max2) ->
    find_max(T, Max1, Max2).