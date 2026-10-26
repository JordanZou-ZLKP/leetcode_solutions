-spec count_days_together(ArriveAlice :: unicode:unicode_binary(), LeaveAlice :: unicode:unicode_binary(), ArriveBob :: unicode:unicode_binary(), LeaveBob :: unicode:unicode_binary()) -> integer().
count_days_together(ArriveAlice, LeaveAlice, ArriveBob, LeaveBob) ->
    A1 = to_day(ArriveAlice),
    A2 = to_day(LeaveAlice),
    B1 = to_day(ArriveBob),
    B2 = to_day(LeaveBob),
    Start = max(A1, B1),
    End = min(A2, B2),
    max(0, End - Start + 1).

to_day(<<M1, M2, "-", D1, D2>>) ->
    Month = (M1 - $0) * 10 + (M2 - $0),
    Day = (D1 - $0) * 10 + (D2 - $0),
    DaysBefore = element(Month, {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334}),
    DaysBefore + Day.

