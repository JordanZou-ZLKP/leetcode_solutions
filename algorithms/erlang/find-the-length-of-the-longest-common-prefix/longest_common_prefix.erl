-spec longest_common_prefix(Arr1 :: [integer()], Arr2 :: [integer()]) -> integer().
longest_common_prefix(Arr1, Arr2) ->
    find_max(Arr2, build_map(Arr1, #{}), 0).

build_map([], Map) -> 
    Map;
build_map([H|T], Map) -> 
    build_map(T, add_prefixes(H, Map)).

add_prefixes(0, Map) -> 
    Map;
add_prefixes(N, Map) ->
    case is_map_key(N, Map) of
        true -> Map;
        false -> add_prefixes(N div 10, Map#{N => true})
    end.

find_max([], _, Max) -> 
    Max;
find_max([H|T], Map, Max) -> 
    find_max(T, Map, check(H, Map, Max, int_len(H))).

check(_, _, Max, Cur) when Cur =< Max -> 
    Max;
check(N, Map, Max, Cur) ->
    case is_map_key(N, Map) of
        true -> Cur;
        false -> check(N div 10, Map, Max, Cur - 1)
    end.

int_len(N) when N < 10 -> 1;
int_len(N) when N < 100 -> 2;
int_len(N) when N < 1000 -> 3;
int_len(N) when N < 10000 -> 4;
int_len(N) when N < 100000 -> 5;
int_len(N) when N < 1000000 -> 6;
int_len(N) when N < 10000000 -> 7;
int_len(N) when N < 100000000 -> 8;
int_len(N) when N < 1000000000 -> 9;
int_len(_) -> 10.