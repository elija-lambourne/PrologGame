:- [renderer].

:- dynamic(i_am_at/1).
:- dynamic(inventory/1).
:- dynamic(options/2).
:- dynamic(current_question/1).
:- dynamic(is_allowed_to_leave_tram/0).

inventory([]).

options(friendGroup, [spit,open_doors]).
options(tramDriver, [talk,open_doors]).
options(middleOfTheTram, [open_doors]).
options(endOfTheTram, [open_doors]).

i_am_at(friendGroup).

current_question(start).

answers(tramDriver, start, a, catchTrain).
answers(tramDriver, catchTrain, a, notAllowed).
answers(tramDriver, catchTrain, b, toilet).

path(friendGroup, forwards, middleOfTheTram).
path(friendGroup, backwards, endOfTheTram).

path(middleOfTheTram, forwards, tramDriver).
path(middleOfTheTram, backwards, friendGroup).

path(endOfTheTram, forwards, friendGroup).

path(tramDriver, backwards, middleOfTheTram).

path(outsideOfTheTram, forwards, firstIntersection).

path(firstIntersection, forwards, secondIntersection).
path(firstIntersection, left, lost).
path(firstIntersection, right, lost).
path(firstIntersection, backwards, outsideOfTheTram).

path(secondIntersection, forwards, thirdIntersection).
path(secondIntersection, right, lost).

path(thirdIntersection, forwards, fourthIntersection).
path(thirdIntersection, left, lost).

path(fourthIntersection, left, fifthIntersection).
path(fourthIntersection, right, lost).

path(fifthIntersection, left, mainStation).
path(fifthIntersection, right, lost).

start :-
    initRenderer,

    setSymbol('██'),
    setOffset(0, 6),

    setSize(50, 50),
    setFOV(90),
    setRenderDistance(0.1, 10),

    setCameraPosition([0, 0, 0], [0, 0, 0]),

    read_obj_file('../res/cube.obj', Cube),

    update(Cube, 0).

update(Object, R) :-
    clear,
    drawObjectInstances([[[0, 0, -3], [R, R, R], [1, 1, 1]]], Object),
    NewR is R + 5,
    sleep(0.33),
    update(Object, NewR).

w :- go(forwards).
s :- go(backwards).
a :- go(left).
d :- go(right).

go(Direction) :- 
    i_am_at(Location),
    path(Location, Direction, NewLocation),
    retract(current_question(_)),
    assert(current_question(start)),
    retract(i_am_at(Location)),
    assert(i_am_at(NewLocation)), !,
    look.

go(_) :-
    write('You can\'t go that way!').

talk :- do(talk).
spit :- do(spit).
say(Answer) :-
    i_am_at(Location),
    current_question(Current),
    answers(Location, Current, Answer, NextAnswer),
    retract(current_question(Current)),
    assert(current_question(NextAnswer)),
    do(talk),!.

say(_) :-
    write('You can\'t say that now!').

do(spit) :-
    i_am_at(friendGroup),
    option_doable(spit),
    write('Spit'),
    add_item(oga),
    remove_option(spit),!.

do(talk) :-
    i_am_at(tramDriver),
    current_question(start),
    write('What do you want?'),nl,
    write('Answers:'),nl,
    write('a: I want to leave the tram!'),!.

do(talk) :-
    i_am_at(tramDriver),
    current_question(catchTrain),
    write('Why would you want to do that?'),nl,
    write('Answers:'),nl,
    write('a: I need to catch my train.'),nl,
    write('b: I need to go to the toilet.'),!.

do(talk) :-
    i_am_at(tramDriver),
    current_question(notAllowed),
    write('You can\'t just walk through the tunnels!'),nl,
    write('Just leave me alone.'),!.

do(talk) :-
    i_am_at(tramDriver),
    current_question(toilet),
    write('Ok, but be quick the tram could be ready at any moment!'),
    assert(is_allowed_to_leave_tram),!.

do(_) :-
    write('You can\'t do that here!').

use(oga) :-
    can_use(oga),
    write('
+-------------------------------+
|            +-----             |
|           /                   |
|  --------+                    |
|    ^      \\      +-----       |
|    |       \\    /             |
|Main station \\  /              |
|              +                |
|     \\       /        +-----   |
|      +-----+        /         |
|           /        /          |
| --+       +-------+           |
|    \\      |                   |
|     +-----+------+            |
|           |       \\           |
|    You -> |                   |
|           |                   |
+-------------------------------+
    '),!.

use(_) :-
    write('You can\'t use that item!').

inventory :- 
    inventory(Items),
    print_list(Items).

look :-
    i_am_at(Location),
    look(Location),!.

look(Location) :-
    i_am_at(Location),
    describe(Location), nl,
    (options(Location, [_|_]),
    write('Options:'), nl,
    options(Location, Options),
    print_list(Options));!.

describe(X) :-
    format('Place: ~w', X).

print_list([]).
print_list([Head | Tail]) :-
    format('-> ~w', Head), nl,
    print_list(Tail).

concat([], List, List).
concat([Head|Tail], List, [Head|ExtandedTail]) :- concat(Tail, List, ExtandedTail).

contains([Head|_], Head).
contains([_|Tail], X) :- contains(Tail, X).

remove_element(X, [X|Tail], Tail).
remove_element(X, [Head|Tail], [Head|ShorterTail]) :- remove_element(X, Tail, ShorterTail).

remove_option(Option) :-
    i_am_at(Location),
    options(Location, Options),
    remove_element(Option, Options, NewOptions),
    retract(options(Location, Options)),
    assert(options(Location, NewOptions)).

option_doable(Option) :-
    i_am_at(Location),
    options(Location, Options),
    contains(Options, Option).

can_use(Item) :-
    inventory(Items),
    contains(Items, Item).

add_item(Item) :-
    inventory(Items),
    concat(Items, [Item], NewItems),
    retract(inventory(Items)),
    assert(inventory(NewItems)).