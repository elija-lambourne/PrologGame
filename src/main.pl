:- [renderer].

:- dynamic(i_am_at/1).

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

options(friendGroup, [talk, spit]).

i_am_at(friendGroup).

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
    retract(i_am_at(Location)),
    assert(i_am_at(NewLocation)), !,
    look.

go(_) :-
    write('You can\'t go that way!').

talk :- do(talk),!.

do(talk) :-
    i_am_at(friendGroup),
    write('Oga Oga').

do(_) :-
    write('You can\'t do that here!').

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