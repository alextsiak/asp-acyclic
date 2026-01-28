% Please insert the names and email addresses of the group members:

% rule generation %
rule(1).

%idea 1:
1 { rule(R) : R=1..program_max_size} program_max_size. 
% if we have the above, there should also be this for continuity:
:- rule(S), S > 1, not rule(S-1).

%idea 2: but this makes a fixed num of rules and i can't optimize
%rule(1..program_max_size).

%idea 3: takes care of the constraint that rule identifiers must be contiguous
%{ rule(S) : rule(R), S = R+1, S <= program_max_size }. 


% aux atom generation %

aux(1..program_max_size).



% rule heads generation %
head(1,1).

% heads should belong to set of aux atoms X

1 { head(R,H) : aux(H) } 1 :- rule(R), R >= 2.


% rule bodies generation %

%they should be either aux atoms, or attributes existing in the instance

body_atom(A) :- aux(A), A>=2.
body_atom(A) :- attribute(A).

sign(1).
sign(-1).

1 { body(R,S,A) : body_atom(A), sign(S)} body_max_size :- rule(R).

% cannot select the same A for the same R with a different S
:- body(R,1,A), body(R,-1,A).

% cannot have an atom in a rule body without it appearing first in a rule head
:- body(R1,1,A), aux(A), not head(_,A).
:- body(R1,-1,A), aux(A), not head(_,A).




% acyclicity %



%%%%%%%% making an actual graph

edge(A,B) :- head(R,A), body(R,1,B). 
edge(A,B) :- head(R,A), body(R,-1,B). 

reachable(X,Y) :- edge(X,Y).
reachable(X,Y) :- edge(X,Z), reachable(Z,Y).

%no atom should be able to reach itself
:- reachable(X,X).


% positive classification %

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

% simulate rule application (again) %

% for each example, an attribute is true if the example has it
true(E,A) :- has(E,A).

% a body is NOT satisfied when one of the literals is violating it (is this even the right word)

violated(E,R) :- body(R,1,A), not true(E,A), example(E,_).
violated(E,R) :- body(R,-1,A), true(E,A), example(E,_).

% a rule can fire if all literals in the body are satisfied (true)
rule_sat(E,R) :- rule(R), not violated(E,R), example(E,_).

true(E,H) :- head(R,H), rule_sat(E,R).

:- example(E,pos), not true(E,1).

:- example(E,neg), true(E,1).


%% optimization %%


%used(R) :- head(R,_).
%p_body_size(N) :- N=#count{R,S,A: body(R,S,A)}. 


num_rules(S) :- S=#count{R: rule(R)}.
body_size(N,R) :- rule(R), N=#count{A: body(R,S,A)}.
p_body_size(T) :- T=#sum{N,R : body_size(N,R)}.

#minimize{S@2: num_rules(S)}.
#minimize{N@1: p_body_size(N)}.





%% other constraints %%

% it cannot be the case that when A is in the head of a rule, auxes smaller than A don't appear in the heads of previous rules
:- aux(A), head(R1,A), aux(B), B<A, not head(R2, B), R2<R1, rule(R2), rule(R1).

% it cannot be the case that, when A is in the head of a rule, auxes smaller than A appear in the head of any subsequent rule
:- aux(A), head(R1,A), aux(B), B<A, head(R2,B), R2>R1, rule(R2), rule(R1).


%:- head(1,1).

#show head/2.
#show body/3.
%#show body_size/2.
%#show used/1.
%#show num_rules/1.
%#show p_body_size/1.


