toRad(X, Y) :- Y is X * pi / 180.

addVectors([X0, Y0, Z0], [X1, Y1, Z1], [X2, Y2, Z2]) :-
    X2 is X0 + X1,
    Y2 is Y0 + Y1,
    Z2 is Z0 + Z1.

fullTransformMatrix(TransformMatrix, RotationMatrix, ScaleMatrix, TRS) :-
    multiplyMatrices(TransformMatrix, RotationMatrix, TR),
    multiplyMatrices(TR, ScaleMatrix, TRS).

scaleMatrix([X, Y, Z], [
    [A, B, C, D],
    [E, F, G, H],
    [I, J, K, L],
    [M, N, O, P]
    ]) :-
    A is X, B is 0, C is 0, D is 0,
    E is 0, F is Y, G is 0, H is 0,
    I is 0, J is 0, K is Z, L is 0,
    M is 0, N is 0, O is 0, P is 1.

transformMatrix([X, Y, Z], [
    [A, B, C, D],
    [E, F, G, H],
    [I, J, K, L],
    [M, N, O, P]
    ]) :-
    A is 1, B is 0, C is 0, D is X,
    E is 0, F is 1, G is 0, H is Y,
    I is 0, J is 0, K is 1, L is Z,
    M is 0, N is 0, O is 0, P is 1.

rotationMatrixDegrees([X, Y, Z], Matrix) :-
    toRad(X, RadX),
    toRad(Y, RadY),
    toRad(Z, RadZ),
    rotationMatrix(RadX, RadY, RadZ, Matrix).

rotationMatrix(X, Y, Z, Matrix) :-
    A is cos(X), B is -sin(X), C is sin(X), D is cos(X),
    E is cos(Y), F is sin(Y), G is -sin(Y), H is cos(Y),
    multiplyMatrices([
        [1, 0, 0, 0],
        [0, A, B, 0],
        [0, C, D, 0],
        [0, 0, 0, 1]
    ],[
        [E, 0, F, 0],
        [0, 1, 0, 0],
        [G, 0, H, 0],
        [0, 0, 0, 1]
    ], RotationXY),
    I is cos(Z), J is -sin(Z), K is sin(Z), L is cos(Z),
    multiplyMatrices(RotationXY, [
        [I, J, 0, 0],
        [K, L, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ], Matrix).

perspectiveMatrix(Aspect, FOV, Near, Far, [
    [A, B, C, D],
    [E, F, G, H],
    [I, J, K, L],
    [M, N, O, P]
    ]) :-
    toRad(FOV, FOVRad),
    Tangent is tan(FOVRad/2),
    A is 1 / (Aspect * Tangent), B is 0, C is 0, D is 0,
    E is 0, F is 1 / Tangent, G is 0, H is 0,
    I is 0, J is 0, K is (Far + Near) / (Near - Far), L is (2 * Far * Near) / (Near - Far),
    M is 0, N is 0, O is -1, P is 0.

viewMatrix([X, Y, Z], [Rx, Ry, Rz], ViewMatrix) :-
    XInverted is -X,
    YInverted is -Y,
    ZInverted is -Z,
    RxInverted is -Rx,
    RyInverted is -Ry,
    RzInverted is Rz,

    transformMatrix([XInverted, YInverted, ZInverted], T),
    rotationMatrixDegrees([RxInverted, RyInverted, RzInverted], R),
    multiplyMatrices(R, T, ViewMatrix).

multiplyVector([X0,Y0], [X1,Y1], [X2,Y2]) :-
    X2 is X0 * X1,
    Y2 is Y0 * Y1.

multiplyVector([X0,Y0], Factor, [X1,Y1]) :-
    X1 is X0 * Factor,
    Y1 is Y0 * Factor.

multiplyMatrixWithVector([
    [A,B,C,D],
    [E,F,G,H],
    [I,J,K,L],
    [M,N,O,P]
    ],
    [X,Y,Z,W],
    [ResultX,ResultY,ResultZ,ResultW]) :-
    ResultX is X*A + Y*B + Z*C + W*D,
    ResultY is X*E + Y*F + Z*G + W*H,
    ResultZ is X*I + Y*J + Z*K + W*L,
    ResultW is X*M + Y*N + Z*O + W*P.

multiplyMatrices([
    [X0,Y0,Z0,W0],
    [X1,Y1,Z1,W1],
    [X2,Y2,Z2,W2],
    [X3,Y3,Z3,W3]],
    [
    [A0,B0,C0,D0],
    [A1,B1,C1,D1],
    [A2,B2,C2,D2],
    [A3,B3,C3,D3]
    ],[
    [ResultX0,ResultY0,ResultZ0,ResultW0],
    [ResultX1,ResultY1,ResultZ1,ResultW1],
    [ResultX2,ResultY2,ResultZ2,ResultW2],
    [ResultX3,ResultY3,ResultZ3,ResultW3]]) :-
    ResultX0 is X0*A0 + Y0*A1 + Z0*A2 + W0*A3,
    ResultY0 is X0*B0 + Y0*B1 + Z0*B2 + W0*B3,
    ResultZ0 is X0*C0 + Y0*C1 + Z0*C2 + W0*C3,
    ResultW0 is X0*D0 + Y0*D1 + Z0*D2 + W0*D3,

    ResultX1 is X1*A0 + Y1*A1 + Z1*A2 + W1*A3,
    ResultY1 is X1*B0 + Y1*B1 + Z1*B2 + W1*B3,
    ResultZ1 is X1*C0 + Y1*C1 + Z1*C2 + W1*C3,
    ResultW1 is X1*D0 + Y1*D1 + Z1*D2 + W1*D3,

    ResultX2 is X2*A0 + Y2*A1 + Z2*A2 + W2*A3,
    ResultY2 is X2*B0 + Y2*B1 + Z2*B2 + W2*B3,
    ResultZ2 is X2*C0 + Y2*C1 + Z2*C2 + W2*C3,
    ResultW2 is X2*D0 + Y2*D1 + Z2*D2 + W2*D3,

    ResultX3 is X3*A0 + Y3*A1 + Z3*A2 + W3*A3,
    ResultY3 is X3*B0 + Y3*B1 + Z3*B2 + W3*B3,
    ResultZ3 is X3*C0 + Y3*C1 + Z3*C2 + W3*C3,
    ResultW3 is X3*D0 + Y3*D1 + Z3*D2 + W3*D3.