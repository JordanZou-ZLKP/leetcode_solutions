-spec minimum_effort(Tasks :: [[integer()]]) -> integer().
minimum_effort(Tasks) ->
    SortedTasks = lists:sort(
        fun([A1, M1], [A2, M2]) -> (M1 - A1) >= (M2 - A2) end, 
        Tasks
    ),
    calculate_energy(SortedTasks, 0, 0).

calculate_energy([], InitialEnergy, _) ->
    InitialEnergy;
calculate_energy([[A, M] | Rest], InitialEnergy, CurrentEnergy) when CurrentEnergy < M ->
    calculate_energy(Rest, InitialEnergy + (M - CurrentEnergy), M - A);
calculate_energy([[A, _] | Rest], InitialEnergy, CurrentEnergy) ->
    calculate_energy(Rest, InitialEnergy, CurrentEnergy - A).