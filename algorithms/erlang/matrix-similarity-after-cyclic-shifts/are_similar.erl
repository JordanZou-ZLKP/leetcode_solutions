-spec are_similar(Mat :: [[integer()]], K :: integer()) -> boolean().

are_similar([Row | _] = Mat, K) ->
    N = length(Row),
    K1 = K rem N,
    K2 = (N - K1) rem N,
    check_sim(Mat, K1, K2).
check_sim([], _, _) -> 
    true;
check_sim([R1], K1, _) ->
    {L1, T1} = lists:split(K1, R1),
    T1 ++ L1 =:= R1;
check_sim([R1, R2 | Rest], K1, K2) ->
    {L1, T1} = lists:split(K1, R1),
    {L2, T2} = lists:split(K2, R2),
    T1 ++ L1 =:= R1 andalso T2 ++ L2 =:= R2 andalso check_sim(Rest, K1, K2).