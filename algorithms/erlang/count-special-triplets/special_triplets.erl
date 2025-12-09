-spec special_triplets(Nums :: [integer()]) -> integer().
-define(MOD, 1000000007).
-define(MAX_VAL, 100000).

special_triplets(Nums) when is_list(Nums) ->
    N = length(Nums),
    if N < 3 -> 0;
       true ->
           FreqMap = calculate_frequency(Nums, N),

           InitialPrevMap = maps:new(),
           [FirstNum | RestNums] = Nums,
           InitialPrevMap1 = update_map(InitialPrevMap, FirstNum, 1),

           ListToIterate = lists:sublist(RestNums, 1, N - 2),
           
           Count = iterate_and_count(ListToIterate, FreqMap, InitialPrevMap1, 0),
           
           Count rem ?MOD
    end.

calculate_frequency(List, N) ->
    calculate_frequency_acc(List, N, maps:new()).

calculate_frequency_acc([], _N, FreqMap) -> FreqMap;
calculate_frequency_acc([H | T], N, FreqMap) ->
    FreqMap1 = update_map(FreqMap, H, 1),
    calculate_frequency_acc(T, N, FreqMap1).

update_map(Map, Key, Delta) ->
    maps:update_with(Key, fun(V) -> V + Delta end, Delta, Map).

iterate_and_count([], _FreqMap, _PrevMap, CurrentCount) ->
    CurrentCount;

iterate_and_count([X | T], FreqMap, PrevMap, CurrentCount) ->
    X2 = X * 2,
    CountToAdd = 
        if X2 =< ?MAX_VAL ->
            Count_i = maps:get(X2, PrevMap, 0),

            Total_X2 = maps:get(X2, FreqMap, 0),

            Adjustment = if X == 0 -> 1;
                           true -> 0
                        end,

            Count_k = Total_X2 - Count_i - Adjustment,
            
            Valid_Count_k = max(0, Count_k),
            
            Count_i * Valid_Count_k;
            
           true ->
            0
        end,

    NewTotalCount = CurrentCount + CountToAdd,
    
    NewPrevMap = update_map(PrevMap, X, 1),

    iterate_and_count(T, FreqMap, NewPrevMap, NewTotalCount).