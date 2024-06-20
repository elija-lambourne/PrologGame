:- [renderer].

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