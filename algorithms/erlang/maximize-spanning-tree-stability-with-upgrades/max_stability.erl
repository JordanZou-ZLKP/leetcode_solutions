-spec max_stability(N :: integer(), Edges :: [[integer()]], K :: integer()) -> integer().
max_stability(N, Edges, K) ->
    BaseRef = counters:new(N, []),
    {Cycle, Must1Min} = build_base(Edges, BaseRef, infinity, false),
    if Cycle -> -1;
       true ->
           BaseRoots = [find(BaseRef, I) || I <- lists:seq(1, N)],
           UniqueRoots = lists:usort(BaseRoots),
           Nrem = length(UniqueRoots),
           if Nrem =:= 1 -> Must1Min;
              true ->
                  RootMap = maps:from_list(lists:zip(UniqueRoots, lists:seq(1, Nrem))),
                  M0 = filter_m0(Edges, BaseRef, RootMap),
                  case check_connectivity(M0, Nrem) of
                      false -> -1;
                      true ->
                          MaxM0 = lists:max([W || [_, _, W] <- M0] ++ [0]),
                          UpperBound = erlang:min(Must1Min, MaxM0 * 2),
                          if UpperBound < 1 -> -1;
                             true -> bs(1, UpperBound, -1, M0, Nrem, K)
                          end
                  end
           end
    end.

build_base([], _, MinW, Cycle) -> 
    {Cycle, MinW};
build_base([[U, V, W, 1] | Rest], Ref, MinW, Cycle) ->
    if Cycle -> {true, MinW};
       true ->
           case union(Ref, U + 1, V + 1) of
               true -> build_base(Rest, Ref, erlang:min(MinW, W), Cycle);
               false -> build_base(Rest, Ref, MinW, true)
           end
    end;
build_base([_ | Rest], Ref, MinW, Cycle) ->
    build_base(Rest, Ref, MinW, Cycle).

filter_m0([], _, _) -> 
    [];
filter_m0([[U, V, W, 0] | Rest], Ref, RootMap) ->
    RU = maps:get(find(Ref, U + 1), RootMap),
    RV = maps:get(find(Ref, V + 1), RootMap),
    if RU =:= RV -> filter_m0(Rest, Ref, RootMap);
       true -> [[RU, RV, W] | filter_m0(Rest, Ref, RootMap)]
    end;
filter_m0([_ | Rest], Ref, RootMap) ->
    filter_m0(Rest, Ref, RootMap).

check_connectivity(M0, Nrem) ->
    Ref = counters:new(Nrem, []),
    Comps = lists:foldl(fun([U, V, _], Acc) ->
        case union(Ref, U, V) of
            true -> Acc - 1;
            false -> Acc
        end
    end, Nrem, M0),
    Comps =:= 1.

bs(Low, High, Best, _, _, _) when Low > High -> 
    Best;
bs(Low, High, Best, M0, Nrem, K) ->
    Mid = Low + (High - Low) div 2,
    case check(Mid, M0, Nrem, K) of
        true -> bs(Mid + 1, High, Mid, M0, Nrem, K);
        false -> bs(Low, Mid - 1, Best, M0, Nrem, K)
    end.

check(Mid, M0, Nrem, K) ->
    Ref = counters:new(Nrem, []),
    C0 = lists:foldl(fun
        ([U, V, W], Acc) when W >= Mid ->
            case union(Ref, U, V) of
                true -> Acc - 1;
                false -> Acc
            end;
        (_, Acc) -> Acc
    end, Nrem, M0),
    C1 = lists:foldl(fun
        ([U, V, W], Acc) when W < Mid andalso W * 2 >= Mid ->
            case union(Ref, U, V) of
                true -> Acc - 1;
                false -> Acc
            end;
        (_, Acc) -> Acc
    end, C0, M0),
    (C1 =:= 1) andalso ((C0 - 1) =< K).

find(Ref, I) ->
    case counters:get(Ref, I) of
        0 -> I;
        P ->
            Root = find(Ref, P),
            counters:put(Ref, I, Root),
            Root
    end.

union(Ref, I, J) ->
    RootI = find(Ref, I),
    RootJ = find(Ref, J),
    if RootI =:= RootJ -> false;
       true -> counters:put(Ref, RootI, RootJ), true
    end.