:- module(recognize, [recognize_gestures/1]).
/** <module> The recognizer engine

*/

%%	recognize_gestures(+State) is det
%
%	all all recognizers on the current state
%

%debug clause
recognize_gestures(State) :-
	recognizer(R),
	once(phrase(R, State)),
	writeln(R),
	fail.
recognize_gestures(_).


recognizer(cur_pose(both_hands_pose)).
recognizer(cur_pose(left_hand_pose)).
recognizer(cur_pose(right_hand_pose)).
recognizer(cur_pose(any_skel_pose)).

recognizer(boop).

cur_pose(X) -->
	pose(X),
	anything,
	eos.

boop -->
	[frame([0])],
	pose_plus(left_hand_pose),
	empty,
	eos.

tick(X) --> [],
	{
	    writeln(X)
	}.

pose_plus(Pose) -->
	pose(Pose),
	pose_star(100, Pose).

pose_star(_, _) --> [].
pose_star(N, Pose) -->
	{
	    NN is N - 1
	},
	pose(Pose),
	pose_star(NN, Pose).

empty -->
	[frame([0])],
	empty_star.

empty_star --> [].
empty_star -->
	[frame([0])],
	empty_star.

:- meta_predicate pose(1).
pose(Pose) -->
	[frame(Frame)],
	{
	    call(Pose, Frame)
	}.

anything --> [].
anything -->
	[_],
	anything.

both_hands_pose(Frame) :-
	hand_in_frame(left, Frame),
	hand_in_frame(right, Frame).

% hand detection is terrible
hand_in_frame(left, Frame) :-
	member(geo_node(GN), Frame),
	member(node_id(ID), GN),
	ID /\ 0x00040000 =\= 0,!.
hand_in_frame(right, Frame) :-
	member(geo_node(GN), Frame),
	member(node_id(ID), GN),
	ID /\ 0x00080000 =\= 0,!.

left_hand_pose(Frame) :-
	hand_in_frame(left, Frame).

right_hand_pose(Frame) :-
	hand_in_frame(right, Frame).

any_skel_pose(Frame) :-
	member(skel(_,_,_,_,_,_,_), Frame).

%%	eos//
%
%	True if at end of input list.

eos([], []).
