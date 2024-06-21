:- [renderer].

:- dynamic(i_am_at/1).
:- dynamic(inventory/1).
:- dynamic(options/2).
:- dynamic(current_answer/1).
:- dynamic(is_allowed_to_leave_tram/0).

inventory([]).

options(friendGroup, [leave_tram]).
options(tramDriver, [talk,leave_tram]).
options(middleOfTheTram, [leave_tram]).
options(endOfTheTram, [leave_tram,talk]).

options(lost, [restart,restartFromTram]).
options(mainStation, [restart]).

i_am_at(friendGroup).

current_answer(start).

answers(tramDriver, start, a, catchTrain).
answers(tramDriver, catchTrain, a, notAllowed).
answers(tramDriver, catchTrain, b, toilet).

answers(endOfTheTram, start, a, knowTunnels).
answers(endOfTheTram, knowTunnels, a, drawMap).

path(friendGroup, forwards, middleOfTheTram).
path(friendGroup, backwards, endOfTheTram).

path(middleOfTheTram, forwards, tramDriver).
path(middleOfTheTram, backwards, friendGroup).

path(endOfTheTram, forwards, friendGroup).

path(tramDriver, backwards, middleOfTheTram).

path(outsideOfTheTram, forwards, firstIntersection).
path(outsideOfTheTram, enter_tram, tramDriver).

path(firstIntersection, forwards, secondIntersection).
path(firstIntersection, left, lost).
path(firstIntersection, right, lost).
path(firstIntersection, backwards, outsideOfTheTram).

path(secondIntersection, forwards, thirdIntersection).
path(secondIntersection, right, lost).
path(secondIntersection, backwards, firstIntersection).

path(thirdIntersection, right, fourthIntersection).
path(thirdIntersection, left, lost).
path(thirdIntersection, backwards, secondIntersection).

path(fourthIntersection, left, fifthIntersection).
path(fourthIntersection, right, lost).
path(fourthIntersection, backwards, thirdIntersection).

path(fifthIntersection, left, mainStation).
path(fifthIntersection, right, lost).
path(fifthIntersection, backwards, fourthIntersection).

start :-
    initRenderer,

    setSymbol('██'),
    setOffset(0, 6),

    setSize(50, 50),
    setFOV(90),
    setRenderDistance(0.1, 10),

    setCameraPosition([0, 0, 0], [0, 0, 0]),

    write('Welcome to our game!'),nl,
    write('--------------------'),nl,nl,

    write('Instructions:'),nl,
    write('w - forwards'),nl,
    write('s - backwards'),nl,
    write('a - left'),nl,
    write('d - right'),nl,nl,

    write('inventory - prints a list of all your items'),nl,
    write('use(Item) - uses an item'),nl,nl,

    write('say(Answer) - chooses an answer'),nl,nl,

    write('You can just type out the options if a location has one'),nl,
    write('-------------------------------------------------------'),nl,nl,

    look.

w :- go(forwards).
s :- go(backwards).
a :- go(left).
d :- go(right).
enter_tram :- go(enter_tram).

go(Direction) :- 
    i_am_at(Location),
    path(Location, Direction, NewLocation),
    retract(current_answer(_)),
    assert(current_answer(start)),
    retract(i_am_at(Location)),
    assert(i_am_at(NewLocation)),!,
    look.

go(_) :-
    write('You can\'t go that way!').

talk :- do(talk).
spit :- do(spit).
leave_tram :- do(leave_tram).
restart :- do(restart).
restartFromTram :- do(restartFromTram).

say(Answer) :-
    i_am_at(Location),
    current_answer(Current),
    answers(Location, Current, Answer, NextAnswer),
    retract(current_answer(Current)),
    assert(current_answer(NextAnswer)),
    do(talk),!.

say(_) :-
    write('You can\'t say that now!').

do(restartFromTram) :-
    option_doable(restartFromTram),
    
    retract(i_am_at(_)),
    assert(i_am_at(outsideOfTheTram)),
    look,!.

do(restart) :-
    option_doable(restart),
    [main],
    start,!.

do(leave_tram) :-
    option_doable(leave_tram),
    is_allowed_to_leave_tram,
    write('You left the tram!'),
    retract(i_am_at(_)),
    assert(i_am_at(outsideOfTheTram)),!.

do(leave_tram) :-
    option_doable(leave_tram),
    write('The tram driver notices that you are trying to leave the tram without his permission.'),nl,
    write('You get in a conflict with him.'),nl,
    write('The conflict takes so long, that it is impossible to catch the train.'),nl,
    write('GAME OVER'),
    [main],!.

% tramDriver talk

do(talk) :-
    i_am_at(tramDriver),
    option_doable(talk),
    current_answer(start),
    write('What do you want?'),nl,
    write('Answers:'),nl,
    write('a: I want to leave the tram!'),!.

do(talk) :-
    i_am_at(tramDriver),
    option_doable(talk),
    current_answer(catchTrain),
    write('Why would you want to do that?'),nl,
    write('Answers:'),nl,
    write('a: I need to catch my train.'),nl,
    write('b: I need to go to the toilet.'),!.

do(talk) :-
    i_am_at(tramDriver),
    option_doable(talk),
    current_answer(notAllowed),
    write('You can\'t just walk through the tunnels!'),nl,
    write('Just leave me alone.'),!.

do(talk) :-
    i_am_at(tramDriver),
    option_doable(talk),
    current_answer(toilet),
    write('Ok, but be quick the tram could be ready at any moment!'),
    remove_option(talk),
    assert(is_allowed_to_leave_tram),!.

% endOfTheTram talk

do(talk) :-
    i_am_at(endOfTheTram),
    option_doable(talk),
    current_answer(start),
    write('What do you want?'),nl,
    write('Answers:'),nl,
    write('a: You guys look like you know the tram tunnels.'),!.

do(talk) :-
    i_am_at(endOfTheTram),
    option_doable(talk),
    current_answer(knowTunnels),
    write('Yeah we often adventure the tunnels and create some grafities.'),nl,
    write('Answers:'),nl,
    write('a: Can you draw a map for me?'),!.

do(talk) :-
    i_am_at(endOfTheTram),
    option_doable(talk),
    current_answer(drawMap),
    write('Here is a map for you.'),nl,nl,
    write('You received a map of the tunnels!'),
    add_item(map),
    remove_option(talk),!.

do(_) :-
    write('You can\'t do that here!').

use(map) :-
    can_use(map),
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

describe(friendGroup) :-
    write('You are at your friend group.').

describe(middleOfTheTram) :-
    write('You are at your in the middle of the tram.').

describe(endOfTheTram) :-
    write('You are at the end of the tram.'),nl,
    write('Your see a group of greek people with spray cans.').

describe(tramDriver) :-
    write('You are next to the tram driver.').

describe(outsideOfTheTram) :-
    write('Your are outside of the tram.'),nl,
    write('You can go forward through the tunnel.').

describe(lost) :-
    write('You are lost in the tunnels!'),nl,
    write('GAME OVER').

describe(firstIntersection) :-
    write('You are at an intersection.'),nl,
    write('You can go forwards, left or right.').

describe(secondIntersection) :-
    write('You are at an intersection.'),nl,
    write('You can go forwards or right.').

describe(thirdIntersection) :-
write('You are at an intersection.'),nl,
write('You can go left or right.').

describe(fourthIntersection) :-
write('You are at an intersection.'),nl,
write('You can go left or right.').

describe(fifthIntersection) :-
write('You are at an intersection.'),nl,
write('You can go left or right.').

describe(mainStation) :-
    write('You got to the train in time!'),nl,
    write('Thanks for playing!'),nl,nl,
    write('You can try to find other paths to the finish!').

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