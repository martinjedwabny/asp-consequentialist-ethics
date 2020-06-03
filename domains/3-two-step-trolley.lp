% Fluents
fluent(train_at).
fluent(alive(1..6)).

% fluent domains
contains(train_at, start). 
contains(train_at, middle). 
contains(train_at, end).
contains(alive(1..6), true).
contains(alive(1..6), false).

% Actions, preconditions and effects
action(do_nothing_1).
precondition(do_nothing_1, train_at, start).
effect(do_nothing_1, train_at, end).
effect(do_nothing_1, alive(1..2), false).
action(turn_switch_1).
precondition(turn_switch_1, train_at, start).
effect(turn_switch_1, train_at, middle).
effect(turn_switch_1, alive(3), false).
action(do_nothing_2).
precondition(do_nothing_2, train_at, middle).
effect(do_nothing_2, train_at, end).
effect(do_nothing_2, alive(4..6), false).
action(turn_switch_2).
precondition(turn_switch_2, train_at, middle).
effect(turn_switch_2, train_at, end).
effect(turn_switch_2, alive(1..2), false).

% Initial state
initialState(train_at, start).
initialState(alive(1..6), true).

% Goals
goal(train_at, end).

% Utilities
utility(train_at, C, 0) :- contains(train_at, C).
utility(alive(1..6), true, 1).
utility(alive(1..6), false, -1).