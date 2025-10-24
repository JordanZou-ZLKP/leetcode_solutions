-spec next_beautiful_number(N :: integer()) -> integer().
next_beautiful_number(N) ->
    AllBalanced = generate_all(),
    %AllBalanced = all_map(),
    %io:format("show me base num ~p~n",[AllBalanced]),
    Sorted = lists:sort(AllBalanced),
    find_first_greater(N, Sorted).

all_map() ->
    R = [666666,555551,55555,555515,555155,551555,515555,444422,
                  44441,4444,444242,444224,44414,442442,442424,442244,44144,
                  424442,424424,424244,422444,41444,333221,33322,333212,
                  333122,3331,333,332321,33232,332312,332231,33223,332213,
                  332132,332123,331322,3313,331232,331223,323321,32332,323312,
                  323231,32323,323213,323132,323123,322331,32233,322313,
                  322133,321332,321323,321233,313322,3133,313232,313223,
                  312332,312323,312233,244442,244424,244244,242444,233321,
                  23332,233312,233231,23323,233213,233132,233123,232331,23233,
                  232313,232133,231332,231323,231233,224444,223331,22333,
                  223313,223133,221333,221,22,213332,213323,213233,212333,212,
                  155555,14444,133322,1333,133232,133223,132332,132323,132233,
                  123332,123323,123233,1224444,122333,122,1].

find_first_greater(N, [H|_]) when H > N -> H;
find_first_greater(N, [_|T]) -> find_first_greater(N, T).

generate_all() ->
    Count = maps:new(),
    generate(0, Count, []).

generate(Num, Count, List) when Num > 1224444 ->
    List;
generate(Num, Count, List) when Num > 0 ->
    Flag = is_beautiful(maps:to_list(Count)),
    case Flag of
        true ->
            generate_loop(Num * 10, Count, [Num | List]);
        _ ->
            generate_loop(Num * 10, Count, List)
    end;
generate(Num, Count, List) ->
    generate_loop(Num * 10, Count, List).

generate_loop(BaseNum, Count, List) ->
    %io:format("show me base num ~p~n",[BaseNum]),
    lists:foldl(
        fun(D, AccList) ->
            case maps:get(D, Count, 0) of
                N when N < D ->
                    NewCount = maps:put(D, N + 1, Count),
                    generate(BaseNum + D, NewCount, AccList);
                _ ->
                    AccList
            end
        end,
        List,
        lists:seq(1, 7)
    ).

is_beautiful([]) ->
    true;
is_beautiful([{D, C} | Rest]) when D >= 1, D =< 7 ->
    (C == 0 orelse C == D) andalso is_beautiful(Rest);
is_beautiful([_ | Rest]) ->
    is_beautiful(Rest).
