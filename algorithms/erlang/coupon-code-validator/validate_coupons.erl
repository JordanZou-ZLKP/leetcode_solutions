-spec validate_coupons(Code :: [unicode:unicode_binary()], BusinessLine :: [unicode:unicode_binary()], IsActive :: [boolean()]) -> [unicode:unicode_binary()].

validate_coupons(Ones, Twos, IsActiveList) ->
    Codes = to_list(Ones),
    BusinessLines = to_list(Twos),
    %IsActiveList = binary_to_list(Three),
    Combined = lists:zip3(Codes, BusinessLines, IsActiveList),
    ValidList = [ {Code, BL} || {Code, BL, Active} <- Combined,
                              Active =:= true,
                              valid_code(Code),
                              valid_business_line(BL) ],
    Electronics = [Code || {Code, "electronics"} <- ValidList],
    Grocery = [Code || {Code, "grocery"} <- ValidList],
    Pharmacy = [Code || {Code, "pharmacy"} <- ValidList],
    Restaurant = [Code || {Code, "restaurant"} <- ValidList],
    SortedElectronics = lists:sort(Electronics),
    SortedGrocery = lists:sort(Grocery),
    SortedPharmacy = lists:sort(Pharmacy),
    SortedRestaurant = lists:sort(Restaurant),
    Rone = SortedElectronics ++ SortedGrocery ++ SortedPharmacy ++ SortedRestaurant,
    R = to_binary(Rone).

to_list(Ones) ->
    R = [binary_to_list(One) || One <- Ones].

to_binary(Ones) ->
    R = [list_to_binary(One) || One <- Ones].

valid_business_line("electronics") -> true;
valid_business_line("grocery") -> true;
valid_business_line("pharmacy") -> true;
valid_business_line("restaurant") -> true;
valid_business_line(_) -> false.

valid_code([]) -> false;
valid_code(Code) when is_list(Code) ->
    lists:all(fun(Char) ->
        (Char >= $a andalso Char =< $z) orelse
        (Char >= $A andalso Char =< $Z) orelse
        (Char >= $0 andalso Char =< $9) orelse
        Char == $_
    end, Code).