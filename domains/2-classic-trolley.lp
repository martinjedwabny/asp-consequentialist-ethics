% Fluents
fluent(train_at).
fluent(alive(1..6)).

% fluent domains
contains(train_at, start). 
contains(train_at, end).
contains(alive(1..6), true).
contains(alive(1..6), false).

% Actions, preconditions and effects
action(do_nothing).
precondition(do_nothing, train_at, start).
effect(do_nothing, train_at, end).
effect(do_nothing, alive(1..5), false).
action(turn_switch).
precondition(turn_switch, train_at, start).
effect(turn_switch, train_at, end).
effect(turn_switch, alive(6), false).

% Initial state
initialState(train_at, start).
initialState(alive(1..6), true).

% Goals
goal(train_at, end).

% Utilities
utility(train_at, C, 0) :- contains(train_at, C).
utility(alive(1..6), true, 1).
utility(alive(1..6), false, -1).