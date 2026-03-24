-spec find_rotation(Mat :: [[integer()]], Target :: [[integer()]]) -> boolean().
find_rotation(Mat, Target) ->
    check_rotations(Mat, Target, 4).

check_rotations(_, _, 0) -> 
    false;
check_rotations(Mat, Target, N) ->
    case Mat == Target of
        true -> true;
        false -> check_rotations(rotate(Mat), Target, N - 1)
    end.

rotate(Mat) ->
    [lists:reverse(Col) || Col <- transpose(Mat)].

transpose([[] | _]) -> 
    [];
transpose(Mat) ->
    [lists:map(fun hd/1, Mat) | transpose(lists:map(fun tl/1, Mat))].