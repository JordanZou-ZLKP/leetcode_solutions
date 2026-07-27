-spec maximum_product(Nums :: [integer()]) -> integer().
maximum_product(Nums) ->
    find_extremes(Nums, -10000, -10000, -10000, 10000, 10000).

find_extremes([], Max1, Max2, Max3, Min1, Min2) ->
    max(Max1 * Max2 * Max3, Min1 * Min2 * Max1);
find_extremes([H | T], Max1, Max2, Max3, Min1, Min2) ->
    {NewMax1, NewMax2, NewMax3} = update_max(H, Max1, Max2, Max3),
    {NewMin1, NewMin2} = update_min(H, Min1, Min2),
    find_extremes(T, NewMax1, NewMax2, NewMax3, NewMin1, NewMin2).

update_max(H, Max1, Max2, _Max3) when H > Max1 -> 
    {H, Max1, Max2};
update_max(H, Max1, Max2, _Max3) when H > Max2 -> 
    {Max1, H, Max2};
update_max(H, Max1, Max2, Max3) when H > Max3 -> 
    {Max1, Max2, H};
update_max(_H, Max1, Max2, Max3) -> 
    {Max1, Max2, Max3}.

update_min(H, Min1, _Min2) when H < Min1 -> 
    {H, Min1};
update_min(H, Min1, Min2) when H < Min2 -> 
    {Min1, H};
update_min(_H, Min1, Min2) -> 
    {Min1, Min2}.