:- use_module(library(clpfd)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/html_write)).
:- http_handler('/api', handle_api, []).

:- multifile http_json/1.

http_json:json_type('application/x-javascript').
http_json:json_type('text/javascript').
http_json:json_type('text/x-javascript').
http_json:json_type('text/x-json').

% Tested so far courses of (lectures, tutorials), (lectures, tutorials, labs), (labs).

% ------------ Main Perdicates ------------ %

% ------------ Facts ------------ %
% 1 -> Math, 2 -> CS 1, 3 -> Advanced

% lecture(CourseNum, Slot, Group)

scheduleCourse([], [], [], []).

% Score is calculated in the case that the course consists of a tutorial and a lab, it is calculated as the absloute difference between the tutorial Group
% And the lab Group.
scheduleCourse(CourseList, L, Schedule, Groups):-
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
  X5 #\= 0 #==> (X5 #> X3 #/\ X5 #\= X6),
  (X5 #\= 0 #/\ X3 #\= 0) #==> Y2 #= Y3,
  X6 #\= 0 #==> X6 #= X5 + 1,
  X5 #\= 0 #/\ X3 #\= 0 #==> Execute #= 1,
  X5 #= 0 #\/ X3 #= 0 #==> Execute #= 0,
  calculateScore(Y2, Y3, Execute, CurrentScore),
  scheduleCourse(T, L2, RestOfSchedule, RestOfGroups),
  Score #= NewScore + CurrentScore,
  parseSchedule(H, Y1, [X1, X2], LectureSchedule, 'Lecture'),
  parseSchedule(H, Y2, [X3, X4], TutorialSchedule, 'Tutorial'),
  parseSchedule(H, Y2, [X5, X6], LabSchedule, 'Lab'),
  flatten([LectureSchedule, TutorialSchedule, LabSchedule], CurrentSchedule),
  append(CurrentSchedule, RestOfSchedule, Schedule),
  % print('Here'),
  % nl,
  append([Y2], RestOfGroups, Groups),
  append(L1, L2, L).

scheduleCourses(L, Schedule, TotalGaps, Score ,Difference, Groups):-
  scheduleCourse([1, 2, 3, 4], L1, Schedule, Groups),
  delete(L1, 0, L),
  all_different(L),
  countUniqueGroups(Groups, Score),
  append(L, Groups, ToBeLabeled),
  % countGaps(1, L, TotalGaps),
  differenceBetweenStartAndFinish(L, Difference),
  labeling([max(Score), min(Difference)], ToBeLabeled).
  % print(L),

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
  % labeling([max(SemesterHours)], L1),
  % delete(L1, 1, L),
  % all_different(L),
  % sort(L, L2).
  findall(L3, (labeling([max(SemesterHours)], L1),
            delete(L1, 1, L),
            all_different(L),
            sort(L, L3)),
        L2).
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


countGaps(31, _, 0).

countGaps(Slot, Schedule, TotalGaps):-
  Slot #< 31,
  element(_, Schedule, AnySlot),
  print(AnySlot),
  nl,
  print(Slot),
  nl,
  print(Schedule),
  nl,
  Start #= ((Slot // 5) * 5) + 1,
  Finish #= ((Slot // 5) + 1) * 5,
  RightBefore #= Slot - 1,
  RightAfter #= Slot + 1,
  findASlotBetween(Start, RightBefore, Schedule, Res1),
  findASlotBetween(RightAfter, Finish, Schedule, Res2),
  (AnySlot #\= Slot #/\ Res1 #= 1 #/\ Res2 #= 0) #==> TotalGaps #= RestOfGaps,
  (AnySlot #\= Slot #/\ Res1 #= 0 #/\ Res2 #= 1) #==> TotalGaps #= RestOfGaps,
  (AnySlot #\= Slot #/\ Res1 #= 0 #/\ Res2 #= 0) #==> TotalGaps #= RestOfGaps,
  (AnySlot #\= Slot #/\ Res1 #= 1 #/\ Res2 #= 1) #==> TotalGaps #= RestOfGaps + 1,
  AnySlot #= Slot  #==> TotalGaps #= RestOfGaps,
  NewSlot #= Slot + 1,
  countGaps(NewSlot, Schedule, RestOfGaps).

% countGaps(Slot, Schedule, TotalGaps):-
%   Slot #< 31,
%   \+element(_, Schedule, Slot),
%   print(Slot),
%   nl,
%   print(Schedule),
%   nl,
%   Start #= ((Slot // 5) * 5) + 1,
%   Finish #= ((Slot // 5) + 1) * 5,
%   RightBefore #= Slot - 1,
%   RightAfter #= Slot + 1,
%   findASlotBetween(Start, RightBefore, Schedule, Res1),
%   findASlotBetween(RightAfter, Finish, Schedule, Res2),
%   Res1 #= 1 #/\ Res2 #= 1 #==> TotalGaps #= RestOfGaps + 1,
%   Res1 #\= 1 #\/ Res2 #\= 1 #==> TotalGaps #= RestOfGaps,
%   countGaps(RightAfter, Schedule, RestOfGaps).

findASlotBetween(Current, Max, _, 0):-
  Current #> Max.

findASlotBetween(Current, Max, Schedule, Res):-
  Current #=< Max,
  element(_, Schedule, Current),
  Res #= 1.

findASlotBetween(Current, Max, Schedule, Res):-
  Current #=< Max,
  \+element(_, Schedule, Current),
  NewCurrent #= Current + 1,
  findASlotBetween(NewCurrent, Max, Schedule, Res).


differenceBetweenStartAndFinish(Schedule, Difference):-
  findMin(Schedule, 31, Start),
  findMax(Schedule, 0, Finish),
  Difference #= Finish - Start.

findMin([], Current, Current).

findMin([H|T], Current, Best):-
  Current #< H,
  findMin(T, Current, Best).

findMin([H|T], Current, Best):-
  Current #> H,
  findMin(T, H, Best).


findMax([], Current, Current).

findMax([H|T], Current, Best):-
  Current #> H,
  findMax(T, Current, Best).

findMax([H|T], Current, Best):-
  Current #< H,
  findMax(T, H, Best).

countUniqueGroups([], 0).

countUniqueGroups([H|T], Res):-
  countUniqueHelper(H, T, CurrentCount),
  countUniqueGroups(T, RestOfRes),
  Res #= CurrentCount + RestOfRes.

countUniqueHelper(_, [], 0).

countUniqueHelper(A, [H|T], Res):-
  countUniqueHelper(A, T, RestOfRes),
  A #= H #==> Res #= RestOfRes + 1,
  A #\= H #==> Res #= RestOfRes.


%%%%%% Server Perdicates

handle_api(Request) :-
        % http_read_json_dict(Request, Query),
        format('Content-type: text/plain~n~n'),
        % print(Request),
        consult(kb1),
        scheduleCourses(L, Schedule, TotalGaps, Score ,Difference, Groups),
        % print(Schedule),
        % prolog_to_json(Schedule, X),
        convertScheduleToJSON(Schedule, X),
        reply_json_dict(X).

server(Port) :-
        http_server(http_dispatch, [port(Port)]).

convertScheduleToJSON([], []).

convertScheduleToJSON([H|T], Res):-
  term_string(H, X),
  convertScheduleToJSON(T, RestOfRes),
  append([X], RestOfRes, Res).
