-spec generate_string(Str1 :: unicode:unicode_binary(), Str2 :: unicode:unicode_binary()) -> unicode:unicode_binary().
generate_string(Str1, Str2) ->
    N = byte_size(Str1),
    M = byte_size(Str2),
    if
        N == 0 -> <<>>;
        true ->
            L = N + M - 1,
            case apply_t(0, N, M, Str1, Str2, #{}) of
                conflict -> <<>>;
                M1 ->
                    case process_f(0, N, M, Str1, Str2, M1, #{}) of
                        conflict -> <<>>;
                        {M2, FMap} ->
                            case assign_c(0, L, M, Str2, M2, FMap) of
                                conflict -> <<>>;
                                FinalMap ->
                                    << <<(maps:get(Idx, FinalMap))>> || Idx <- lists:seq(0, L - 1) >>
                            end
                    end
            end
    end.

apply_t(I, N, M, Str1, Str2, Map) when I < N ->
    case binary:at(Str1, I) of
        $T ->
            case apply_w(I, 0, M, Str2, Map) of
                conflict -> conflict;
                NewMap -> apply_t(I + 1, N, M, Str1, Str2, NewMap)
            end;
        _ ->
            apply_t(I + 1, N, M, Str1, Str2, Map)
    end;
apply_t(_, _, _, _, _, Map) -> Map.

apply_w(_, J, M, _, Map) when J == M -> Map;
apply_w(I, J, M, Str2, Map) ->
    Pos = I + J,
    C = binary:at(Str2, J),
    case maps:find(Pos, Map) of
        {ok, C} -> apply_w(I, J + 1, M, Str2, Map);
        {ok, _} -> conflict;
        error -> apply_w(I, J + 1, M, Str2, maps:put(Pos, C, Map))
    end.

process_f(I, N, M, Str1, Str2, WordMap, FMap) when I < N ->
    case binary:at(Str1, I) of
        $F ->
            case find_lq(I, M - 1, WordMap) of
                -1 ->
                    case check_fm(I, 0, M, Str2, WordMap) of
                        true -> conflict;
                        false -> process_f(I + 1, N, M, Str1, Str2, WordMap, FMap)
                    end;
                LastQ ->
                    NewFMap = maps:update_with(LastQ, fun(List) -> [I | List] end, [I], FMap),
                    process_f(I + 1, N, M, Str1, Str2, WordMap, NewFMap)
            end;
        _ ->
            process_f(I + 1, N, M, Str1, Str2, WordMap, FMap)
    end;
process_f(_, _, _, _, _, WordMap, FMap) -> {WordMap, FMap}.

find_lq(I, J, WordMap) when J >= 0 ->
    case maps:is_key(I + J, WordMap) of
        true -> find_lq(I, J - 1, WordMap);
        false -> I + J
    end;
find_lq(_, _, _) -> -1.

check_fm(_, J, M, _, _) when J == M -> true;
check_fm(I, J, M, Str2, WordMap) ->
    case maps:get(I + J, WordMap) == binary:at(Str2, J) of
        true -> check_fm(I, J + 1, M, Str2, WordMap);
        false -> false
    end.

assign_c(K, L, M, Str2, WordMap, FMap) when K < L ->
    case maps:is_key(K, WordMap) of
        true -> assign_c(K + 1, L, M, Str2, WordMap, FMap);
        false ->
            Constraints = maps:get(K, FMap, []),
            Forbidden = get_forb(Constraints, K, M, Str2, WordMap, []),
            case pick_s(Forbidden, $a) of
                conflict -> conflict;
                Char ->
                    assign_c(K + 1, L, M, Str2, maps:put(K, Char, WordMap), FMap)
            end
    end;
assign_c(_, _, _, _, WordMap, _) -> WordMap.

get_forb([I | Rest], K, M, Str2, WordMap, Acc) ->
    case match_e(I, 0, M, K, Str2, WordMap) of
        true ->
            FC = binary:at(Str2, K - I),
            get_forb(Rest, K, M, Str2, WordMap, [FC | Acc]);
        false ->
            get_forb(Rest, K, M, Str2, WordMap, Acc)
    end;
get_forb([], _, _, _, _, Acc) -> Acc.

match_e(_, J, M, _, _, _) when J == M -> true;
match_e(I, J, M, K, Str2, WordMap) ->
    Pos = I + J,
    if
        Pos == K -> match_e(I, J + 1, M, K, Str2, WordMap);
        true ->
            case maps:get(Pos, WordMap) == binary:at(Str2, J) of
                true -> match_e(I, J + 1, M, K, Str2, WordMap);
                false -> false
            end
    end.

pick_s(Forbidden, Char) when Char =< $z ->
    case lists:member(Char, Forbidden) of
        true -> pick_s(Forbidden, Char + 1);
        false -> Char
    end;
pick_s(_, _) -> conflict.