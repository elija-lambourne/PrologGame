read_obj_file(File) :-
    open(File, read, Stream),
    read_obj_lines(Stream, Vertices, Faces),
    close(Stream),
    write(Faces),
    write(Vertices).

read_obj_file(File, [Vertices, Faces]) :-
    open(File, read, Stream),
    read_obj_lines(Stream, Vertices, Faces),
    close(Stream).

read_obj_lines(Stream, Vertices, Faces) :-
    read_obj_lines(Stream, [], [], Vertices, Faces).

read_obj_lines(Stream, VTemp, NTemp, Vertices, Faces) :-
    at_end_of_stream(Stream), !,
    Vertices = VTemp,
    Faces = NTemp.

read_obj_lines(Stream, VTemp, NTemp, Vertices, Normals) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, Line),
    split_string(Line, " ", "", [_|LineParts]),
    ( startsWith(Line, 'v') -> filter_vertices(LineParts, VertParts), append(VTemp, [VertParts], VNew), NNew = NTemp;
      startsWith(Line, 'f') -> filter_faces(LineParts,Faces ), append(NTemp, Faces, NNew), VNew = VTemp;
      VNew = VTemp, NNew = NTemp
    ),
    read_obj_lines(Stream, VNew, NNew, Vertices, Normals).

filter_faces([], []).
filter_faces([H|T], [First|Result]) :-
    split_string(H, "/", "", [Temp|_]),
    atom_number(Temp, TempNumber),
    First is TempNumber - 1,
    filter_faces(T, Result).

filter_vertices([], []).
filter_vertices([H|T], [First|Result]) :-
    atom_number(H, First),
    filter_vertices(T, Result).


startsWith(String, Letter) :-
    atom_chars(String, [H|_]),
    H = Letter.