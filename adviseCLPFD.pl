:-use_module(library(clpfd)).

% Tested so far courses of (lectures, tutorials), (lectures, tutorials, labs), (labs).
% ------------ Facts ------------ %
% 1 -> Math, 2 -> CS 1, 3 -> Advanced

% lecture(CourseNum, Slot, Group)
lecture1(1, [1,5]).
lecture2(1, [2, 8]).

% lecture1(1, 5, 2).
% lecture2(1, 8, 2).

lecture1(2, [10, 1]).
lecture2(2, [0, 0]).

% lecture1(2, 1, 2).
% lecture2(2, 0, 2).

lecture1(3, [0, 0]).
lecture2(3, [0, 0]).

% ------------ %

% Tutorial(CourseNum, Slot, TutorialGroup)
tutorial1(1, [7, 8]).
tutorial2(1, [25, 12]).

% tutorial1(1, 6, 2).
% tutorial2(1, 12, 2).

tutorial1(2, [13, 26]).
tutorial2(2, [0, 0]).

% tutorial1(2, 26, 2).
% tutorial2(2, 0, 2).

tutorial1(3, [0, 0]).
tutorial2(3, [0, 0]).

% ------------ %

% Lab(CourseNum, Slot, TutorialGroup)
lab1(1, [0, 0]).
lab2(1, [0, 0]).

% lab1(1, 0, 2).
% lab2(1, 0, 2).

lab1(2, [17, 30]).
lab2(2, [0, 0]).

% lab1(2, 30, 2).
% lab2(2, 0, 2).

lab1(3, [5]).
lab2(3, [6]).

% ------------ Main Perdicates ------------ %

scheduleCourse([], [], [], 0).

% Score is calculated in the case that the course consists of a tutorial and a lab, it is calculated as the absloute difference between the tutorial Group
% And the lab Group.
scheduleCourse(CourseList, L, Schedule, Score):-
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
  calculateScore(Y2, Y3, Execute, CurrentScore),
  scheduleCourse(T, L2, RestOfSchedule, NewScore),
  Score #= NewScore + CurrentScore,
  parseSchedule(H, Y1, [X1, X2], LectureSchedule, 'Lecture'),
  parseSchedule(H, Y2, [X3, X4], TutorialSchedule, 'Tutorial'),
  parseSchedule(H, Y3, [X5, X6], LabSchedule, 'Lab'),
  flatten([LectureSchedule, TutorialSchedule, LabSchedule], CurrentSchedule),
  append(CurrentSchedule, RestOfSchedule, Schedule),
  append(L1, L2, L).

scheduleCourses(L, Schedule):-
  scheduleCourse([1 , 2, 3], L1, Schedule, Score),
  delete(L1, 0, L),
  all_different(L),
  labeling([min(Score)], L).
%  findall(L, labeling([min(Score)], L), L2),
%  print(L2).

generateScheduleConfigurations(L2, Probation):-
  CourseHours = [0, 8, 4, 10],
  Ob = [4],
  length(Ob, N1),
  N2 #= 8 - N1,
  obligatoryCourses(ObligatoryCourseList, N1),
  optionalCourses(OptionalCourseList, N2),
  append(OptionalCourseList, ObligatoryCourseList, L1),
  L1 = [X1, X2, X3, X4, X5, X6, X7, X8],
  element(X1, CourseHours, Y1),
  element(X2, CourseHours, Y2),
  element(X3, CourseHours, Y3),
  element(X4, CourseHours, Y4),
  element(X5, CourseHours, Y5),
  element(X6, CourseHours, Y6),
  element(X7, CourseHours, Y7),
  element(X8, CourseHours, Y8),
  SemesterHours #= Y1 + Y2 + Y3 + Y4 + Y5 + Y6 + Y7 + Y8,
  Probation #= 0 #==> SemesterHours #< 34,
  Probation #= 1 #==> SemesterHours #< 31,
  SemesterHours #> 0,
  labeling([max(SemesterHours)], L1),
  delete(L1, 1, L),
  all_different(L),
  sort(L, L2).
%  setof(L, (labeling([max(SemesterHours)], L1), delete(L1, 1, L), all_different(L)) , Ls).
% findall(L1, (labeling([max(SemesterHours)], L1), delete(L1, 1, L), all_different(L)) , L2).

generateAllowedCoursesList(L):-
  X in 1..101,
  filterCourses(X, 1),
  findall(X, labeling([], [X]), L).

% ------------ Supporting Perdicates ------------ %

calculateScore(_, _, 0, 0).

calculateScore(Y2, Y3, 1, Score):-
  abs(Y2 - Y3) #= Score.


countUnique([], _, 0).

countUnique([H|T], AlreadySeen, Num):-
  not(element(_, AlreadySeen, H)),
  append(AlreadySeen, [H], UpdatedSeen),
  countUnique(T, UpdatedSeen, NewNum),
  Num #= 1 + NewNum.

countUnique([H | T], AlreadySeen, Num):-
  element(_, AlreadySeen, H),
  countUnique(T, AlreadySeen, Num).

obligatoryCourses([], 0).

obligatoryCourses(ConstraintVars, N):-
  N #> 0,
  AllowedCourses = [4],
  element(_, AllowedCourses, X),
  N1 #= N - 1,
  obligatoryCourses(RestOfConstraintVars, N1),
  append([X], RestOfConstraintVars, ConstraintVars).

optionalCourses([], 0).

optionalCourses(ConstraintVars, N):-
  N #> 0,
  AllowedCourses = [1, 2, 3],
  element(_, AllowedCourses, X),
  N1 #= N - 1,
  optionalCourses(RestOfConstraintVars, N1),
  append([X], RestOfConstraintVars, ConstraintVars).

preq(1, [4]).
preq(2, [1]).
preq(3, [1,2,3]).
passedCourses([1,2,3]).

filterCourses(_, 4).

filterCourses(X, Y):-
  Y #< 4,
  passedCourses(P),
  Y1 #= Y + 1,
  preq(Y, L),
  length(L, Length),
  intersection(L, P, I),
  length(I, IntersectionLength),
  Length #\= IntersectionLength #==> X #\= Y,
  filterCourses(X, Y1).

% Slot is in the form slot(Subject, Type, Slot, Group).
parseSchedule(_, _, [], [], _).

parseSchedule(X1, Group, [A | B], Schedule, Type):-
  A #= 0,
  parseSchedule(X1, Group, B, RestOfSchedule, Type),
  Schedule = RestOfSchedule.

parseSchedule(X1, Group, [A | B], Schedule, Type):-
  A #> 0,
	parseSchedule(X1, Group, B, RestOfSchedule, Type),
	append([slot(X1, Type, A, Group)], RestOfSchedule, Schedule).
