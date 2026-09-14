-spec is_rectangle_overlap(Rec1 :: [integer()], Rec2 :: [integer()]) -> boolean().
is_rectangle_overlap([X1, Y1, X2, Y2], [X3, Y3, X4, Y4]) ->
    (X2 > X3) andalso (X1 < X4) andalso (Y2 > Y3) andalso (Y1 < Y4).
