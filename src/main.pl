:- [renderer].

:- dynamic(i_am_at/1).
:- dynamic(inventory/1).
:- dynamic(options/2).
:- dynamic(current_answer/1).
:- dynamic(is_allowed_to_leave_tram/0).
:- dynamic(said_lost_screwdriver/0).
:- dynamic(has_picture_of_breaker/0).
:- dynamic(game_over/0).
:- dynamic(answers/4).

:- dynamic(removed_breaker_cover/0).
:- dynamic(has_picture_of_circuit/0).
:- dynamic(flipped_power_lever/0).
:- dynamic(restarted_tram/0).

inventory([phone]).

options(friendGroup, [leave_tram]).
options(tramDriver, [talk,leave_tram]).
options(frontOfTheTram, [leave_tram, investigate_breaker]).
options(middleOfTheTram, [leave_tram,talk_to_old_man, talk_to_student]).
options(endOfTheTram, [leave_tram,talk]).

options(lost, [restart,restartFromTram]).
options(mainStation, [restart]).

i_am_at(friendGroup).

current_answer(start).

answers(tramDriver, start, a, catchTrain).
answers(tramDriver, catchTrain, a, notAllowed).
answers(tramDriver, catchTrain, b, toilet).

% talk_to_old_man
answers(middleOfTheTram, oldMan, a,knowMongolian).
answers(middleOfTheTram, oldMan, b, haveScrewdriver).
answers(middleOfTheTram, knowMongolian, a, showPictureOfCircuit).

% talk_to_student
answers(middleOfTheTram, student, a, hasScrewdriver).
answers(middleOfTheTram, student, b, startConvo).
answers(middleOfTheTram, hasScrewdriver, b, lostScrewdriver).
answers(middleOfTheTram, hasScrewdriver, a, showPictureOfBreaker).

% press_button
answers(frontOfTheTram, button, a, openDoors).
answers(frontOfTheTram, button, b, pressBrake).
answers(frontOfTheTram, button, c, sendSos).
answers(frontOfTheTram, button, d, restorePower).
answers(frontOfTheTram, button, e, explodeTram).
answers(frontOfTheTram, button, f, restartTram).


answers(endOfTheTram, start, a, knowTunnels).
answers(endOfTheTram, knowTunnels, a, drawMap).

path(friendGroup, forwards, middleOfTheTram).
path(friendGroup, backwards, endOfTheTram).

path(middleOfTheTram, forwards, frontOfTheTram).
path(middleOfTheTram, backwards, friendGroup).

path(endOfTheTram, forwards, friendGroup).

path(frontOfTheTram, forwards, tramDriver).
path(frontOfTheTram, backwards, middleOfTheTram).

path(tramDriver, backwards, frontOfTheTram).

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

talk_to_old_man :- 
    retract(current_answer(_)),
    assert(current_answer(oldMan)),
    do(talk).
talk_to_student :- 
    retract(current_answer(_)),
    assert(current_answer(student)),
    do(talk).
press_button :- 
    retract(current_answer(_)),
    assert(current_answer(button)),
    do(talk).
talk :- do(talk).
spit :- do(spit).
leave_tram :- do(leave_tram).
investigate_breaker :- do(investigate_breaker).
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
    (
        option_doable(restart) ;
        game_over
    ),
    [main],
    start,!.

do(leave_tram) :-
    option_doable(leave_tram),
    is_allowed_to_leave_tram,
    write('You left the tram!'),
    retract(i_am_at(_)),
    assert(i_am_at(outsideOfTheTram)),
    look, !.

do(leave_tram) :-
    option_doable(leave_tram),
    write('The tram driver notices that you are trying to leave the tram without his permission.'),nl,
    write('You get in a conflict with him.'),nl,
    write('The conflict takes so long, that it is impossible to catch the train.'),nl,
    game_over,
    [main],!.

do(investigate_breaker) :-
    option_doable(investigate_breaker),
    i_am_at(frontOfTheTram),
    write('You see a breaker attached to the drivers cabin.'),nl,
    write('It looks like it is closed by some standard size 10 cross screws. You might want to take a picutre...'),nl.

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

% middleOfTheTram
do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_old_man),
    current_answer(oldMan),
    write("..."), nl,
    write("a: Do you know any mongolian?"), nl,
    write("b: Do you have a screwdriver?"), !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_old_man),
    current_answer(haveScrewdriver),
    write("үгүй."), !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_old_man),
    current_answer(knowMongolian),
    write('Yeah sure, why?'), nl,
    (
        (
            has_picture_of_circuit,
            write('a: Show him the picture of the circuit. "I\'m trying to fix the tram."')
        ) ; (
            write('a: I don\'t know yet...'), nl
        )
    ), nl, !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_student),
    current_answer(student),
    write("..."), nl,
    write("a: Do you have a screwdriver?"), nl,
    write("b: Start gossiping about teachers"), !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_old_man),
    current_answer(showPictureOfCircuit),
    has_picture_of_circuit,
    write('Oh, I see. I can help you with that. I\'ll translate it on your phone.'), nl,
    add_item(circuit_translation), 
    remove_option(talk_to_old_man), !.



do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_student),
    current_answer(hasScrewdriver),
    write("Yeah, what do you need it for?"), nl,
    (
        (
            has_picture_of_breaker,
            write("a: Show him the picture of the breaker")
        ) ; 
        write("a: Take a picture of the breaker first.")
    ), nl, % TODO ONLY MAKE AVAIABLE IF HAVE PICTURE
    (
        said_lost_screwdriver ; 
        write("b: I lost mine")
    ), !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_student),
    current_answer(showPictureOfBreaker),
    has_picture_of_breaker,
    write("Oh, I see. I can help you with that."), nl,
    write("You can take mine for now, I stole it from the schools workshop anyways."), nl, nl,
    write("You received a screwdriver!"), nl,
    add_item(screwdriver),
    remove_option(talk_to_student),
    !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_student),
    current_answer(lostScrewdriver),
    write("Well."), nl,
    assert(said_lost_screwdriver),
    write("I have one, but I'm not giving it to you. I guess you should've taken better care of yours!"), nl, !.

do(talk) :-
    i_am_at(middleOfTheTram),
    option_doable(talk_to_student),
    current_answer(startConvo),
    write("Hey, what's up?"), nl,
    write("Prof. K. is such a -"), nl, nl,
    write("You talked too much and missed your train."),
    game_over, !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(button),
    write("You can press a button or flip a lever, choose wisely..."), nl,
    write("a: Press button E0"), nl,
    write("b: Press button C1"), nl,
    write("c: Press button A5"), nl,
    write("d: Flip lever L0"), nl,
    write("e: Press button H5"), nl,
    write("f: Press button C9"), nl,
     !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(openDoors),
    write("You opened the doors. The tram driver files a report and you have to wait for him to finish the report."), nl,
    game_over, !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(pressBrake),
    write("You pressed the emergency brake. The tram brakes are now broken and the tram driver files a report."), nl,
    game_over, !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(sendSos),
    write("You pressed the SOS button. The emergency service is on the way. You have to wait for them to arrive and you pay a fien."), nl,
    game_over, !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(restorePower),
    write("You restored the power. Wow, now to restarting the tram"), nl,
    assert(flipped_power_lever), !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(explodeTram),
    write("You blew up the tram causing a mass casualty. At leasst 40 people are estiamted dead. Your name will be in the historybooks for the clumsiest person to ever live."), nl,
    game_over, !.

do(talk) :-
    i_am_at(frontOfTheTram),
    option_doable(press_button),
    current_answer(restartTram),
    flipped_power_lever,
    write("You restarted the tram. You'll catch your train!"), nl, !. % TODO ADD ENDING

do(_) :-
    write('You can\'t do that here!').

use(phone) :-
    i_am_at(frontOfTheTram),
    removed_breaker_cover,
    (
        (
            has_picture_of_circuit,
            write("You already took a picture of the circuit.")
        ) ; 
        (
            write("You took a picture of the circuit. Might want to show it to someone..."),
            assert(has_picture_of_circuit)
        )
    )
    ,!.

use(phone) :-
    i_am_at(frontOfTheTram),
    (
        has_picture_of_breaker,
        write("You already took a picture of the breaker.")
    ) ; (
        write("You took a picture of the breaker. Might want to show it to someone..."),
        assert(has_picture_of_breaker)
    ),!.

use(screwdriver) :-
    i_am_at(fromntOfTheTram),
    (
        removed_breaker_cover,
        write("You already took of the breaker cover.")
    );(
        write("You carefully take of the breakers cover. It reveals a complex circuit."),
        assert(removed_breaker_cover),
        assert(options(frontOfTheTram, [leave_tram, investigate_breaker, press_button])) % TODO change to concat
        draw_circuit_mongolian_broken,
        write("The labels seem to be written in a foreign language. Hard to tell what button or lever is safe to be used."),nl,
        write("Each button that looks useable seems to have a letter followed by a number as a label...")
    ),!.

use(screwdriver) :-
    write("You can't use that here!"),!.

use(circuit_translation) :-
    draw_circuit_english_broken, !.

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


game_over :-
    assert(game_over),
    write("
  _____                         ____                 
 / ____|                       / __ \\                
| |  __  __ _ _ __ ___   ___  | |  | |_   _____ _ __ 
| | |_ |/ _` | '_ ` _ \\ / _ \\ | |  | \\ \\ / / _ \\ '__|
| |__| | (_| | | | | | |  __/ | |__| |\\ V /  __/ |   
 \\_____|\\__,_|_| |_| |_|\\___|  \\____/  \\_/ \\___|_|   
                                                    
    "),nl,
    write('You can restart the game by typing restart.'),nl, !.

draw_circuit_mongolian_broken :-
        i_am_at(frontOfTheTram),
        removed_breaker_cover,
        write("
 ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │        ++++++++                      ++++++++                           ++++++++            │
 │       +        +                    +        +                         +        +           │
 │      +          +       ####       +          +                       +          +          │
 │      +    E0    +-----─►####--─►---+    C1    +                  ┌───►+    A5    +◄──-------│
 │      +    E0    +---◄─--####◄─-----+    C1    +                  │    +    A5    +---──►----│
 │      +          +       ####       +          +                  │    +          +          │
 │       +        +         ▲|         +        +                 ┌─┴─┐   +        +           │
 │        ++++++++          │|          ++++++++                  │   │    ++++++++            │
 │   нээлттэй хаалганууд    |│     яаралтай завсарлага            │зай│ түргэн тусламж дуудах  │
 │                          |▼                                    │   │                        │
 │                          ||                                    └───┘                        │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │◄───------◄────-----───►----------────►-----─────►-------x  x--------------------------------│
 │----─────►-----◄────--------◄─────-----◄────-------◄───--x  x--------------------------------│
 │          ▲ │                     ▲                                              ▲ │         │
 │          │ ▼    ┌───────────┐    │                                              │ ▼         │
 │          | |    │конденсатор│    │                     ┌────┐                   | |         │
 │          | |    └───────────┘    │                     │ ++ │ L0                | |         │
 │          | |        ▲            │                     │ ++ │ L0                | |         │
 │          | |        │          ####                    │ ++ │                   | |         │
 │       ++++++++      │    ┌────►####                    │ ++ │                   | |         │
 │      +        +     │    │     ####                    └─++─┘                 ++++++++      │
 │     +          +────┴────┤     ####                      ++                  +        +     │
 │     +    H5    +         │                               ++                 +          +    │
 │     +    H5    +    ┌────▼────┐                       ++++++++              +    C9    +    │
 │     +          +    │         │                       ++++++++              +    C9    +    │
 │      +        +     │ ашиггүй │                       ++++++++              +          +    │
 │       ++++++++      │         │                                              +        +     │
 │                     └─────────┘                   цахилгааны түвшин           ++++++++      │
 │                                                                      трамвайг дахин эхлүүлэх│
 │                                                                                             │
 └─────────────────────────────────────────────────────────────────────────────────────────────┘
    "),nl, !.

draw_circuit_mongolian_fixed :-
        i_am_at(frontOfTheTram),
        removed_breaker_cover,
        write("
 ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │        ++++++++                      ++++++++                           ++++++++            │
 │       +        +                    +        +                         +        +           │
 │      +          +       ####       +          +                       +          +          │
 │      +    E0    +-----─►####--─►---+    C1    +                  ┌───►+    A5    +◄──-------│
 │      +    E0    +---◄─--####◄─-----+    C1    +                  │    +    A5    +---──►----│
 │      +          +       ####       +          +                  │    +          +          │
 │       +        +         ▲|         +        +                 ┌─┴─┐   +        +           │
 │        ++++++++          │|          ++++++++                  │   │    ++++++++            │
 │   нээлттэй хаалганууд    |│     яаралтай завсарлага            │зай│ түргэн тусламж дуудах  │
 │                          |▼                                    │   │                        │
 │                          ||                                    └───┘                        │
 │                          ||                           ++++++++                              │
 │                          ||                           ++++++++                              │
 │                          ||                           ++++++++                              │
 │                          ||                              ++                                 │
 │◄───------◄────-----───►--┤ ├-----────►-----─────►--------++--────►------─────►--------────►-│
 │----─────►-----◄────----------◄───-----◄────-------◄───---++-------◄─────-------◄──┬───------│
 │          ▲ │                     ▲                       ++                     ▲ │         │
 │          │ ▼    ┌───────────┐    │                       ++                     │ ▼         │
 │          | |    │конденсатор│    │                     ┌─++─┐                   | |         │
 │          | |    └───────────┘    │                     │ ++ │ L0                | |         │
 │          | |        ▲            │                     │    │ L0                | |         │
 │          | |        │          ####                    │    │                   | |         │
 │       ++++++++      │    ┌────►####                    │    │                   | |         │
 │      +        +     │    │     ####                    └─  ─┘                 ++++++++      │
 │     +          +────┴────┤     ####                                          +        +     │
 │     +    H5    +         │                                                  +          +    │
 │     +    H5    +    ┌────▼────┐                                             +    C9    +    │
 │     +          +    │         │                                             +    C9    +    │
 │      +        +     │ ашиггүй │                                             +          +    │
 │       ++++++++      │         │                                              +        +     │
 │                     └─────────┘                   цахилгааны түвшин           ++++++++      │
 │                                                                      трамвайг дахин эхлүүлэх│
 │                                                                                             │
 └─────────────────────────────────────────────────────────────────────────────────────────────┘
        "),nl, !.

draw_circuit_english_broken :-
        write("
 ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │                                                                                             │
 │        ++++++++                      ++++++++                           ++++++++            │
 │       +        +                    +        +                         +        +           │
 │      +          +       ####       +          +                       +          +          │
 │      +    E0    +-----─►####--─►---+    C1    +                  ┌───►+    A5    +◄──-------│
 │      +    E0    +---◄─--####◄─-----+    C1    +                  │    +    A5    +---──►----│
 │      +          +       ####       +          +                  │    +          +          │
 │       +        +         ▲|         +        +              ┌────┴──┐  +        +           │
 │        ++++++++          │|          ++++++++               │       │   ++++++++            │
 │       open doors         |│       emergency brake           │battery│call emergency service │
 │                          |▼                                 │       │                       │
 │                          ||                                 └───────┘                       │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │                          ||                                                                 │
 │◄───------◄────-----───►----------────►-----─────►-------x  x--------------------------------│
 │----─────►-----◄────--------◄─────-----◄────-------◄───--x  x--------------------------------│
 │          ▲ │                     ▲                                              ▲ │         │
 │          │ ▼    ┌─────────┐      │                                              │ ▼         │
 │          | |    │condenser│      │                     ┌────┐                   | |         │
 │          | |    └─────────┘      │                     │ ++ │ L0                | |         │
 │          | |        ▲            │                     │ ++ │ L0                | |         │
 │          | |        │          ####                    │ ++ │                   | |         │
 │       ++++++++      │    ┌────►####                    │ ++ │                   | |         │
 │      +        +     │    │     ####                    └─++─┘                 ++++++++      │
 │     +          +────┴────┤     ####                      ++                  +        +     │
 │     +    H5    +         │                               ++                 +          +    │
 │     +    H5    +    ┌────▼────┐                       ++++++++              +    C9    +    │
 │     +          +    │         │                       ++++++++              +    C9    +    │
 │      +        +     │ useless │                       ++++++++              +          +    │
 │       ++++++++      │         │                                              +        +     │
 │                     └─────────┘                     power lever               ++++++++      │
 │                                                                             restart tram    │
 │                                                                                             │
 └─────────────────────────────────────────────────────────────────────────────────────────────┘
        "),nl, !.

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

describe(frontOfTheTram) :-
    write('You are at the front of the tram.'),nl,
    write('You see the tram drivers cabin ahead.'),nl,
    write('There\'s a breaker attached to the drivers cabin.').

describe(tramDriver) :-
    write('You are next to the tram driver.').

describe(outsideOfTheTram) :-
    write('Your are outside of the tram.'),nl,
    write('You can go forward through the tunnel.').

describe(lost) :-
    write('You got lost in the tunnels!'),nl,
    game_over.

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