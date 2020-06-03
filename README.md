# Answer set planner for consequentialist ethics
An implementation of an ASP planner that takes into account utilities to compute ethically permissible plans.

## Running the program

1. Install [clingo](https://github.com/potassco/clingo).

2. Clone or download this repo.

3. Navigate to folder with terminal.

4. Execute: 
    
    > clingo domains/[domain-file.lp] planner.lp --models 0 
    
    **Note**: feel free to remove *--models 0* option, which forces the solver to find all plans.
    
5. Replace [domain-file.lp] with a domain file, like the following:

   - 1-trivial-trolley.lp
   - 2-classic-trolley.lp
   - 3-two-step-trolley.lp

## Planning domain format

### Predicates to specify the domain

- fluent(F) : F is a fluent/state variable.
- contains(F, V): V is a value in the domain of fluent F. 
- action(A): A is an action.
- precondition(A, F, V): F=V is a precondition to execute action A.
- effect(A, F, V): executing action A causes F=V.
- initialState(F, V): in the initial state, F=V.
- goal(F, V): in a terminal state F=V should hold.
- utility(F, V, U) : F=V has utility U.

### Example

```asp
% Fluents
fluent(train_at).
fluent(alive(1..2)).
% fluent domains

contains(train_at, start). 
contains(train_at, end).
contains(alive(1..2), true).
contains(alive(1..2), false).

% Actions, preconditions and effects
action(do_nothing).
precondition(do_nothing, train_at, start).
effect(do_nothing, train_at, end).
effect(do_nothing, alive(1..2), false).
action(turn_switch).
precondition(turn_switch, train_at, start).
effect(turn_switch, train_at, end).

% Initial state
initialState(train_at, start).
initialState(alive(1..2), true).

% Goals
goal(train_at, end).

% Utilities
utility(train_at, C, 0) :- contains(train_at, C).
utility(alive(1..2), true, 1).
utility(alive(1..2), false, -1).
```