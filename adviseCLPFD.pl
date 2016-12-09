:-use_module(library(clpfd)).

% lecture(CourseNum, Slot, Group)
lecture1(1, [1,5]).
lecture2(1, [2, 8]).

% lecture1(1, 5, 2).
% lecture2(1, 8, 2).

lecture1(2, [10, 1]).
lecture2(2, [0, 0]).

% lecture1(2, 1, 2).
% lecture2(2, 0, 2).

% ------------

% Tutorial(CourseNum, Slot, TutorialGroup)
tutorial1(1, [5, 6]).
tutorial2(1, [25, 12]).

% tutorial1(1, 6, 2).
% tutorial2(1, 12, 2).

tutorial1(2, [13, 26]).
tutorial2(2, [0, 0]).

% tutorial1(2, 26, 2).
% tutorial2(2, 0, 2).

% ------------

% Lab(CourseNum, Slot, TutorialGroup)
lab1(1, [0, 0]).
lab2(1, [0, 0]).

% lab1(1, 0, 2).
% lab2(1, 0, 2).

lab1(2, [17, 30]).
lab2(2, [0, 0]).

% lab1(2, 30, 2).
% lab2(2, 0, 2).

% ------------

scheduleCourse([], [], 0).

% Score is calculated in the case that the course consists of a tutorial and a lab, it is calculated as the absloute difference between the tutorial Group
% And the lab Group.
scheduleCourse(CourseList, L, Score):-
  CourseList = [H | T],
  L1 = [X1, X2, X3, X4, X5, X6],
  L1 ins 0..30,
  lecture1(H, Lectures1),
  lecture2(H, Lectures2),
  tutorial1(H, Tutorials1),
  tutorial2(H, Tutorials2),
  lab1(H, Labs1),
  lab2(H, Labs2),
  element(Y1, Lectures1, X1),
  element(Y1, Lectures2, X2),
  element(Y2, Tutorials1, X3),
  element(Y2, Tutorials2, X4),
  element(Y3, Labs1, X5),
  element(Y3, Labs2, X6),
  X1 #\= 0 #==> X1 #\= X2,
  X3 #\= 0 #==> X3 #\= X4,
  X5 #\= 0 #==> X5 #> X3 #/\ X5 #\= X6,
  X5 #= 0 #\/ X3 #= 0 #==> Y2 #= Y3,
  X6 #\= 0 #==> X6 #= X5 + 1,
  X5 #\= 0 #/\ X3 #\= 0 #==> Execute #= 1,
  X5 #= 0 #\/ X3 #= 0 #==> Execute #= 0,
  calculateScore(Y2, Y3, Execute, Score),
  scheduleCourse(T, L2, NewScore),
  append(L1, L2, L).

% ------------

scheduleCourses(L):-
  scheduleCourse([1, 2], L1, Score),
  delete(L1, 0, L),
  all_different(L),
  labeling([], L).

calculateScore(_, _, 0, 0).
calculateScore(Y2, Y3, 1, Score):-
  abs(Y2 - Y3) #= Score.
