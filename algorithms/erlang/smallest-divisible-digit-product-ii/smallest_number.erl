-spec smallest_number(Num :: unicode:unicode_binary(), T :: integer()) -> unicode:unicode_binary().

smallest_number(Num, T) ->
    case factorize(T) of
        invalid -> <<"-1">>;
        T_Req ->
            case check_original(Num, 0, 0, 0, 0, T_Req) of
                true -> Num;
                false ->
                    DPMap = build_dp(),
                    RevPrefixes = build_prefixes(Num, 1, 0, 0, 0, 0, []),
                    N = byte_size(Num),
                    case find_divergence(RevPrefixes, T_Req, DPMap, N) of
                        {Idx, DivergeDigit, A, B, C, D_fact} ->
                            Prefix = binary:part(Num, 0, Idx - 1),
                            {DA, DB, DC, DD} = digit_factors(DivergeDigit),
                            Suffix = greedy_fill(N - Idx, A + DA, B + DB, C + DC, D_fact + DD, T_Req, DPMap, []),
                            <<Prefix/binary, (DivergeDigit + $0):8, (list_to_binary(Suffix))/binary>>;
                        none ->
                            {TA, TB, TC, TD} = T_Req,
                            MinLenReq = TC + TD + get_dp_val(TA, TB, DPMap),
                            TargetLen = max(N + 1, MinLenReq),
                            Suffix = greedy_fill(TargetLen, 0, 0, 0, 0, T_Req, DPMap, []),
                            list_to_binary(Suffix)
                    end
            end
    end.

factorize(T) -> factorize(T, {0, 0, 0, 0}).

factorize(1, Acc) -> Acc;
factorize(T, {A, B, C, D}) when T rem 2 == 0 -> factorize(T div 2, {A + 1, B, C, D});
factorize(T, {A, B, C, D}) when T rem 3 == 0 -> factorize(T div 3, {A, B + 1, C, D});
factorize(T, {A, B, C, D}) when T rem 5 == 0 -> factorize(T div 5, {A, B, C + 1, D});
factorize(T, {A, B, C, D}) when T rem 7 == 0 -> factorize(T div 7, {A, B, C, D + 1});
factorize(_, _) -> invalid.

check_original(<<>>, A, B, C, D, {TA, TB, TC, TD}) ->
    if A == -1 -> false;
       A >= TA, B >= TB, C >= TC, D >= TD -> true;
       true -> false
    end;
check_original(<<Byte:8, Rest/binary>>, A, B, C, D, T_Req) ->
    Digit = Byte - $0,
    if Digit == 0 orelse A == -1 -> false;
       true ->
           {DA, DB, DC, DD} = digit_factors(Digit),
           check_original(Rest, A + DA, B + DB, C + DC, D + DD, T_Req)
    end.

build_dp() ->
    lists:foldl(fun(A, Acc) ->
        lists:foldl(fun(B, Acc2) ->
            compute_dp(A, B, Acc2)
        end, Acc, lists:seq(0, 32))
    end, #{}, lists:seq(0, 48)).

compute_dp(0, 0, Map) -> maps:put({0, 0}, 0, Map);
compute_dp(A, B, Map) ->
    V1 = get_dp_val(A-1, B, Map),
    V2 = get_dp_val(A, B-1, Map),
    V3 = get_dp_val(A-2, B, Map),
    V4 = get_dp_val(A-1, B-1, Map),
    V5 = get_dp_val(A-3, B, Map),
    V6 = get_dp_val(A, B-2, Map),
    Min = 1 + min6(V1, V2, V3, V4, V5, V6),
    maps:put({A, B}, Min, Map).

get_dp_val(A, B, Map) ->
    RealA = max(0, A),
    RealB = max(0, B),
    case maps:find({RealA, RealB}, Map) of
        {ok, Val} -> Val;
        error -> 999999
    end.

min6(V1, V2, V3, V4, V5, V6) ->
    min(V1, min(V2, min(V3, min(V4, min(V5, V6))))).

digit_factors(1) -> {0, 0, 0, 0};
digit_factors(2) -> {1, 0, 0, 0};
digit_factors(3) -> {0, 1, 0, 0};
digit_factors(4) -> {2, 0, 0, 0};
digit_factors(5) -> {0, 0, 1, 0};
digit_factors(6) -> {1, 1, 0, 0};
digit_factors(7) -> {0, 0, 0, 1};
digit_factors(8) -> {3, 0, 0, 0};
digit_factors(9) -> {0, 2, 0, 0};
digit_factors(0) -> {0, 0, 0, 0}.

build_prefixes(<<>>, _Idx, _A, _B, _C, _D, Acc) ->
    Acc;
build_prefixes(<<Byte:8, Rest/binary>>, Idx, A, B, C, D, Acc) ->
    Digit = Byte - $0,
    AccNew = [{Idx, Digit, A, B, C, D} | Acc],
    if A == -1 orelse Digit == 0 ->
           build_prefixes(Rest, Idx + 1, -1, -1, -1, -1, AccNew);
       true ->
           {DA, DB, DC, DD} = digit_factors(Digit),
           build_prefixes(Rest, Idx + 1, A + DA, B + DB, C + DC, D + DD, AccNew)
    end.

find_divergence([], _T_Req, _DPMap, _N) ->
    none;
find_divergence([{Idx, Digit, A, B, C, D_fact} | Rest], T_Req, DPMap, N) ->
    if A == -1 ->
           find_divergence(Rest, T_Req, DPMap, N);
       true ->
           case find_valid_digit(max(1, Digit + 1), 9, A, B, C, D_fact, T_Req, N - Idx, DPMap) of
               none -> find_divergence(Rest, T_Req, DPMap, N);
               DivergeDigit -> {Idx, DivergeDigit, A, B, C, D_fact}
           end
    end.

find_valid_digit(D, MaxD, A, B, C, D_fact, T_Req, LeftLen, DPMap) ->
    if D > MaxD -> none;
       true ->
           {DA, DB, DC, DD} = digit_factors(D),
           {TA, TB, TC, TD} = T_Req,
           ReqA = max(0, TA - (A + DA)),
           ReqB = max(0, TB - (B + DB)),
           ReqC = max(0, TC - (C + DC)),
           ReqD = max(0, TD - (D_fact + DD)),
           MinLen = ReqC + ReqD + get_dp_val(ReqA, ReqB, DPMap),
           if MinLen =< LeftLen -> D;
              true -> find_valid_digit(D + 1, MaxD, A, B, C, D_fact, T_Req, LeftLen, DPMap)
           end
    end.

greedy_fill(0, _A, _B, _C, _D_fact, _T_Req, _DPMap, Acc) ->
    lists:reverse(Acc);
greedy_fill(Len, A, B, C, D_fact, T_Req, DPMap, Acc) ->
    ValidD = find_valid_digit(1, 9, A, B, C, D_fact, T_Req, Len - 1, DPMap),
    {DA, DB, DC, DD} = digit_factors(ValidD),
    greedy_fill(Len - 1, A + DA, B + DB, C + DC, D_fact + DD, T_Req, DPMap, [ValidD + $0 | Acc]).