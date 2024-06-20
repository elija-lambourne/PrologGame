:- [math].
:- [file_util].

:- dynamic(perspectiveMatrix/1).
:- dynamic(pvMatrix/1).

:- dynamic(symbol/1).
:- dynamic(size/2).
:- dynamic(offset/2).
:- dynamic(renderDistance/2).
:- dynamic(fov/1).

symbol('██').
offset(0, 6).

size(100,100).
renderDistance(0.1,10).
fov(90).

initRenderer :-
    size(Height, Width),
    Aspect is Width / Height,
    fov(FOV),
    renderDistance(Near, Far),

    perspectiveMatrix(Aspect, FOV, Near, Far, PerspectiveMatrix),

    viewMatrix([0, 0, 0], [0, 0, 0], ViewMatrix),

    multiplyMatrices(PerspectiveMatrix, ViewMatrix, PVMatrix),

    assertz(perspectiveMatrix(PerspectiveMatrix)),
    assertz(pvMatrix(PVMatrix)).

setSymbol(Symbol) :-
    retract(symbol(_)),
    assertz(symbol(Symbol)).

setOffset(X, Y) :-
    retract(offset(_,_)),
    assertz(offset(X, Y)).

setSize(Height, Width) :-
    retract(size(_,_)),
    retract(perspectiveMatrix(_)),

    Aspect is Width / Height,
    fov(FOV),
    renderDistance(Near, Far),

    perspectiveMatrix(Aspect, FOV, Near, Far, PM),

    assertz(perspectiveMatrix(PM)),
    assertz(size(Height, Width)).

setRenderDistance(Near, Far) :-
    retract(renderDistance(_,_)),
    retract(perspectiveMatrix(_)),

    size(Height, Width),
    Aspect is Width / Height,
    fov(FOV),

    perspectiveMatrix(Aspect, FOV, Near, Far, PM),

    assertz(perspectiveMatrix(PM)),
    assertz(renderDistance(Near, Far)).

setFOV(FOV) :-
    retract(fov(_)),
    retract(perspectiveMatrix(_)),

    size(Height, Width),
    Aspect is Width / Height,
    renderDistance(Near, Far),

    perspectiveMatrix(Aspect, FOV, Near, Far, PM),

    assertz(perspectiveMatrix(PM)),
    assertz(fov(FOV)).

setCameraPosition(Position, Rotation) :-
    retract(pvMatrix(_)),

    viewMatrix(Position, Rotation, ViewMatrix),
    perspectiveMatrix(PerspectiveMatrix),

    multiplyMatrices(PerspectiveMatrix, ViewMatrix, PVMatrix),

    assertz(pvMatrix(PVMatrix)).

drawObjectInstances([], _) :- setCursorPosition(0, 0).
drawObjectInstances(
    [[Position, Rotation, Scale] | OtherTransforms],
    [Vertices, Indices]) :-

    transformMatrix(Position, T),
    scaleMatrix(Scale, S),
    rotationMatrixDegrees(Rotation, R),

    fullTransformMatrix(T, R, S, TransformMatrix),

    pvMatrix(PVMatrix),
    multiplyMatrices(PVMatrix, TransformMatrix, PT),

    drawTriangles(Vertices, Indices, PT),
    drawObjectInstances(OtherTransforms, [Vertices, Indices]).

resetText :- write("\033[0").
clear :-
    write("\033[2J"),
    setCursorPosition(0,0).
setForegroundColor(R,G,B) :- format("\033[38;2;~w;~w;~wm", [R,G,B]).
setBackgroundColor(R,G,B) :- format("\033[48;2;~w;~w;~wm", [R,G,B]).
setCursorPosition(X, Y) :- format("\033[~w;~wH", [Y,X]).

drawPixel([X, Y], Symbol) :-
    X2 is X * 2,
    setCursorPosition(X2, Y),
    format("~w", [Symbol]).

drawLine([X,Y,Z], [X,Y,_], Symbol) :- drawFragmentIfNeeded([X, Y, Z], Symbol),!.
drawLine([X0,Y0,Z], [X1,Y1,_], Symbol) :-
    RoundedX0 is round(X0),
    RoundedY0 is round(Y0),
    drawFragmentIfNeeded([RoundedX0, RoundedY0, Z], Symbol),
    DistanceX is X1 - X0,
    DistanceY is Y1 - Y0,
    Distance is max(abs(DistanceX), abs(DistanceY)),
    NewX is X0 + DistanceX / Distance,
    NewY is Y0 + DistanceY / Distance,
    roundSmallFloatingPoint(NewX, RoundedNewX),
    roundSmallFloatingPoint(NewY, RoundedNewY),
    drawLine([RoundedNewX,RoundedNewY,Z], [X1,Y1,Z], Symbol).

drawFragmentIfNeeded([X,Y,Z], Symbol) :-
    (
    size(Height, Width),
    offset(OffsetX, OffsetY),

    X >= OffsetX, X =< Width + OffsetX,
    Y >= OffsetY, Y =< Height + OffsetY,
    Z >= -1, Z =< 1,

    drawPixel([X, Y], Symbol)
    ),!.

roundSmallFloatingPoint(X, Result) :-
    (abs(X - floor(X)) < 0.01,
    Result is floor(X),!);
    Result is X.

drawTriangles(_, [], _).
drawTriangles(Vertices, [X,Y,Z|Tail], Matrix) :-
    symbol(Symbol),

    getElement(Vertices, X, Vertex1),
    getElement(Vertices, Y, Vertex2),
    getElement(Vertices, Z, Vertex3),

    vertexShader(Matrix, Vertex1, NewVertex1),
    vertexShader(Matrix, Vertex2, NewVertex2),
    vertexShader(Matrix, Vertex3, NewVertex3),

    projectionDivision(NewVertex1, NormalizedVertex1),
    projectionDivision(NewVertex2, NormalizedVertex2),
    projectionDivision(NewVertex3, NormalizedVertex3),

    drawTriangleIfNeeded(NormalizedVertex1, NormalizedVertex2, NormalizedVertex3, Symbol),

    drawTriangles(Vertices, Tail, Matrix).

drawTriangleIfNeeded(Vertex1, Vertex2, Vertex3, Symbol) :-
    (
    shouldShow(Vertex1, Vertex2, Vertex3),

    scaleToScreen(Vertex1, ScreenVertex1),
    scaleToScreen(Vertex2, ScreenVertex2),
    scaleToScreen(Vertex3, ScreenVertex3),

    drawLine(ScreenVertex1, ScreenVertex2, Symbol),
    drawLine(ScreenVertex2, ScreenVertex3, Symbol),
    drawLine(ScreenVertex3, ScreenVertex1, Symbol));!.

shouldShow([X0, Y0, _], [X1, Y1, _], [X2, Y2, _]) :-
    A is X0*Y1 - X1*Y0 + X1*Y2 - X2*Y1 + X2*Y0 - X0*Y2,
    A >= 0.

getElement([Head|_], 0, Head).
getElement([_|Tail], Index, Result) :-
    NextIndex is Index - 1,
    getElement(Tail, NextIndex, Result).

projectionDivision([X,Y,Z,W], [NewX,NewY,NewZ]) :-
    NewX is X / W,
    NewY is Y / W,
    NewZ is Z / -W.

scaleToScreen([X,Y,Z], [NewX,NewY,Z]) :-
    size(Height, Width),
    offset(OffsetX, OffsetY),
    NewX is round((X + 1) / 2 * Width + OffsetX),
    NewY is round(Height - (Y + 1) / 2 * Height + OffsetY).

vertexShader(Matrix, [X,Y,Z], [NewX,NewY,NewZ,W]) :-
    multiplyMatrixWithVector(Matrix, [X,Y,Z,1], [NewX,NewY,NewZ,W]).