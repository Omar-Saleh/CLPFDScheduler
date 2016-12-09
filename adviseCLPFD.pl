:-use_module(library(clpfd)).

% lecture(CourseNum, Slot, Group)
lecture1(1, 1, 1).
lecture2(1, 2, 1).

lecture1(1, 5, 2).
lecture2(1, 8, 2).

% ------------

% Tutorial(CourseNum, Slot, TutorialGroup)
tutorial1(1, 5, 1).
tutorial2(1, 25, 1).

tutorial1(1, 6, 2).
tutorial2(1, 12, 2).

% ------------

% Lab(CourseNum, Slot, TutorialGroup)
lab1(1, 0, 1).
lab2(1, 0, 1).

lab1(1, 0, 2).
lab2(1, 0, 2).

% ------------

% Score is calculated in the case that the course consists of a tutorial and a lab, it is calculated as the absloute difference between the tutorial Group
% And the lab Group.
scheduleCourse(L, Score):-
  L = [X1, X2, X3, X4, X5, X6],
  L ins 0..30,
  lecture1(1, X1, Y1),
  lecture2(1, X2, Y1),
  tutorial1(1, X3, Y2),
  tutorial2(1, X4, Y2),
  lab1(1, X5, Y3),
  lab2(1, X6, Y3),
  X1 #\= 0 #==> X1 #\= X2,
  X3 #\= 0 #==> X3 #\= X4,
  X5 #\= 0 #==> X5 #> X3 #/\ X5 #\= X6,
  X5 #= 0 #\/ X3 #= 0 #==> Y2 #= Y3,
  X6 #\= 0 #==> X6 #= X5 + 1,
  X5 #\= 0 #/\ X3 #\= 0 #==> Execute #= 1,
  X5 #= 0 #\/ X3 #= 0 #==> Execute #= 0,
  calculateScore(Y2, Y3, Execute, Score).

calculateScore(_, _, 0, 0).

calculateScore(Y2, Y3, 1, Score):-
  abs(Y2 - Y3) #= Score.
