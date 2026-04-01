-spec can_be_equal(S1 :: unicode:unicode_binary(), S2 :: unicode:unicode_binary()) -> boolean().
can_be_equal(<<A1, B1, C1, D1>>, <<A2, B2, C2, D2>>) ->
    ((A1 =:= A2 andalso C1 =:= C2) orelse (A1 =:= C2 andalso C1 =:= A2)) andalso
    ((B1 =:= B2 andalso D1 =:= D2) orelse (B1 =:= D2 andalso D1 =:= B2)).