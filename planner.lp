%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Planner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load incremental solving mode
#include <incmode>.

% Set maximum number of plan steps
#const imax=3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BASE PROGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program base.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENFORCE ETHICAL POLICIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

enforce_ethics(overall_utility).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Establish initial state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

holds(Fluent, Value, 0) :- initialState(Fluent, Value).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STEP PROGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program step(t).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform actions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

1 {occurs(Action, t) : action(Action)} 1.

% Check preconditions
possible(Action, t) :- action(Action), not impossible(Action, t).
impossible(Action, t) :- action(Action), precondition(Action, Fluent, Value), not holds(Fluent, Value, t - 1).
:- occurs(Action,t), impossible(Action, t).

% Apply effects
caused(Fluent, Value, t) :-
	occurs(Action,t),
	effect(Action, Fluent, Value).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ethic bases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Action overall, positive and negative utilities
action_overall_utility(Action, Utility) :- action(Action), Utility = #sum { U, Fluent, Value : utility(Fluent, Value, U), effect(Action, Fluent, Value) }.
action_positive_utility(Action, Utility) :- action(Action), Utility = #sum { U, Fluent, Value : U > 0, utility(Fluent, Value, U), effect(Action, Fluent, Value) }.
action_negative_utility(Action, Utility) :- action(Action), Utility = #sum { U, Fluent, Value : U < 0, utility(Fluent, Value, U), effect(Action, Fluent, Value) }.

% Permitted actions: overall utility
permitted(Action, State, overall_utility) :- possible(Action, State), not forbidden(Action, State, overall_utility).
forbidden(Action1, State, overall_utility) :- possible(Action1, State),permitted(Action2, State, overall_utility), action_overall_utility(Action1, Utility1), action_overall_utility(Action2, Utility2), Utility1 < Utility2.

% Permitted actions: least harm
permitted(Action, State, least_harm) :- possible(Action, State), not forbidden(Action, State, least_harm).
forbidden(Action1, State, least_harm) :- possible(Action1, State), permitted(Action2, State, least_harm), action_negative_utility(Action1, Utility1), action_negative_utility(Action2, Utility2), Utility1 < Utility2.
forbidden(Action1, State, least_harm) :- permitted(Action2, State, least_harm), action_negative_utility(Action1, Utility1), action_negative_utility(Action2, Utility2), Utility1 == Utility2, action_positive_utility(Action1, Utility3), action_positive_utility(Action2, Utility4), Utility3 < Utility4.

% Check ethic bases
:- occurs(Action, t), forbidden(Action, t, EthicalBase), enforce_ethics(EthicalBase).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inertia rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modified(Fluent, t) :- caused(Fluent, Value, t).

holds(Fluent, Value, t) :- caused(Fluent, Value, t).
holds(Fluent, Value, t) :- holds(Fluent, Value, t - 1), not modified(Fluent, t).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fluents and mutex groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check that variables have unique values
:- fluent(Fluent), not 1 {holds(Fluent, Value, t) : contains(Fluent, Value)} 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK PROGRAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program check(t).

:- query(t), goal(X,V), not holds(X,V,t).

% Display results

#show occurs/2.
#show holds(X,V,t) : holds(X,V,t), query(t).
#show forbidden(A,t,E) : forbidden(A,t,E), query(t).