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

lecture1(1,[9,9,22,22,28,28,27,27,6,6]).
lecture2(1,[0,0,0,0,0,0,0,0,0,0]).
tutorial1(1,[16,11,16,12,13,13,11,11,11,19,3,3,19,19,12,20,18,18,6,4,4,6,6,22,22,6,7,21,21,1,1,1,26,26,8,8,7,5,5,9,8,28,28,7,7]).
tutorial2(1,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).
lab1(1,[17,18,17,18,18,28,28,12,12,24,14,14,20,20,14,24,24,24,22,22,22,27,7,27,27,7,10,23,23,2,2,2,29,29,21,23,8,21,21,21,9,30,30,8,8]).
lab2(1,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).
lecture1(2,[24,23]).
lecture2(2,[0,0]).
tutorial1(2,[22,22,9,10,10,29,17,13,9,10,25,24,7,14,8,18,18,18,14]).
tutorial2(2,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).
lab1(2,[29,29,29,22,13,30,30,30,13,14,28,28,8,18,14,19,22,25,22]).
lab2(2,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).
lecture1(3,[27,26]).
lecture2(3,[0,0]).
tutorial1(3,[13,16,23,29,14,13,13,9,14,17,24,22,24,27,27,22,7,27,25]).
tutorial2(3,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).
lab1(3,[30,30,16,16,9,10,29,29,17,9,14,14,25,19,22,25,19,22,24]).
lab2(3,[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]).

% lecture(CourseNum, Slot, Group)

scheduleCourse([], [], [], [], []).

% Score is calculated in the case that the course consists of a tutorial and a lab, it is calculated as the absloute difference between the tutorial Group
% And the lab Group.
scheduleCourse(CourseList, L, Schedule, Groups, LectureGroup):-
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
  scheduleCourse(T, L2, RestOfSchedule, RestOfGroups, RestOfLectureGroups),
  Score #= NewScore + CurrentScore,
  parseSchedule(H, Y1, [X1, X2], LectureSchedule, 'Lecture'),
  parseSchedule(H, Y2, [X3, X4], TutorialSchedule, 'Tutorial'),
  parseSchedule(H, Y2, [X5, X6], LabSchedule, 'Lab'),
  flatten([LectureSchedule, TutorialSchedule, LabSchedule], CurrentSchedule),
  append(CurrentSchedule, RestOfSchedule, Schedule),
  % print('Here'),
  % nl,
  append([Y2], RestOfGroups, Groups),
  append([Y1], RestOfLectureGroups, LectureGroup),
  append(L1, L2, L).

scheduleCourses(CollectiveList, BestConfig):-
    findall(
    (Schedule, L),
    (
      % [1, 2, 3]
      scheduleCourse(BestConfig, L1, Schedule, Groups, LectureGroup),
      delete(L1, 0, L),
      all_different(L),
      countUniqueGroups(Groups, Score),
      append(L, Groups, ToBeLabeled),
      append(ToBeLabeled, LectureGroup, FinalLabeling),
      % print('Heree'),
      % nl,
      % print(L),
      % nl,
      % countGaps(1, L, TotalGaps),
      differenceBetweenStartAndFinish(L, Difference),
      labeling([ff, max(Score), min(Difference)], FinalLabeling)
      % ( countDaysOff(L, 1, 5) ;
      %   countDaysOff(L, 6, 10) ;
      %   countDaysOff(L, 11, 15) ;
      %   countDaysOff(L, 16, 20) ;
      %   countDaysOff(L, 21, 25) ;
      %   countDaysOff(L, 26, 30)
      % )
    ),
    CollectiveList).
  % print(L),

oldSchedule(L, Schedule, TotalGaps, Difference, Score):-
  scheduleCourse([1,2,3], L1, Schedule, Groups, LectureGroup),
  delete(L1, 0, L),
  all_different(L),
  countUniqueGroups(Groups, Score),
  append(L, Groups, ToBeLabeled),
  append(ToBeLabeled, LectureGroup, FinalLabeling),
  print(L),
  nl,
  generateBooleanSchedule(L, BoolSchedule, 1),
  testGaps(1, BoolSchedule, TotalGaps),
  print(TotalGaps),
  print(L),
  differenceBetweenStartAndFinish(L, Difference),
  labeling([ff, max(Score), min(Difference)], FinalLabeling).


generateBooleanSchedule(_, [], 31).

generateBooleanSchedule(L, BoolSchedule):-
  length(BoolSchedule, 30),
  BoolSchedule ins 0..1,
  element(L, BoolSchedule, 1).


chooseScheduleWithMinGaps(CollectiveList, GapList, Schedule):-
  countAllScheduleGaps(CollectiveList, GapList),
  findAcceptableSchedule(CollectiveList, GapList, Schedule).

%  findall(L, labeling([min(Score)], L), L2),
%  print(L2).
findAcceptableSchedule(CollectiveList, GapList, Schedule):-
  min_list(GapList, Min),
  nth1(Min, CollectiveList, CollectiveList),
  CollectiveEntry = (Schedule, Candidate),
  ( countDaysOff(Candidate, 1, 5) ;
    countDaysOff(Candidate, 6, 10) ;
    countDaysOff(Candidate, 11, 15) ;
    countDaysOff(Candidate, 16, 20) ;
    countDaysOff(Candidate, 21, 25) ;
    countDaysOff(Candidate, 26, 30)
  ).

findAcceptableSchedule(CollectiveList, GapList, Schedule):-
  min_list(GapList, Min),
  nth1(Min, CollectiveList, CollectiveList),
  CollectiveEntry = (_, Candidate),
  \+( countDaysOff(Candidate, 1, 5) ;
    countDaysOff(Candidate, 6, 10) ;
    countDaysOff(Candidate, 11, 15) ;
    countDaysOff(Candidate, 16, 20) ;
    countDaysOff(Candidate, 21, 25) ;
    countDaysOff(Candidate, 26, 30)
  ),
  delete(Min, GapList, NewGapList),
  delete(CollectiveEntry, CollectiveList, NewCollectiveList),
  findAcceptableSchedule(NewCollectiveList, NewGapList, Schedule).



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
  % findall(L3, (labeling([max(SemesterHours)], L1),
  %           delete(L1, 1, L),
  %           all_different(L),
  %           sort(L, L3)),
  %       L2).
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

% countGaps(Slot, Schedule, Vars, TotalGaps):-
%   Slot #< 31,
%   element(_, Schedule, AnySlot),
%   print(Slot),
%   nl,
%   Start #= ((Slot // 5) * 5) + 1,
%   Finish #= ((Slot // 5) + 1) * 5,
%   RightBefore #= Slot - 1,
%   RightAfter #= Slot + 1,
%   findASlotBetween(Start, RightBefore, Schedule, Res1),
%   findASlotBetween(RightAfter, Finish, Schedule, Res2),
%   countGaps(RightAfter, Schedule, RestOfVars, RestOfGaps),
%   append([AnySlot], RestOfVars, Vars),
%   AnySlot #\= Slot #==> TotalGaps #= RestOfGaps,
%   AnySlot #= Slot #/\ Res1 #= 1 #/\ Res2 #= 1 #==> TotalGaps #= 1 + RestOfGaps,
%   AnySlot #= Slot #/\ Res1 #= 1 #/\ Res2 #= 0 #==> TotalGaps #= RestOfGaps,
%   AnySlot #= Slot #/\ Res1 #= 0 #/\ Res2 #= 1 #==> TotalGaps #= RestOfGaps,
%   AnySlot #= Slot #/\ Res1 #= 0 #/\ Res2 #= 0 #==> TotalGaps #= RestOfGaps.

countGaps(Slot, Schedule, TotalGaps):-
  Slot #< 31,
  element(_, Schedule, Slot),
  % print(Slot),
  % nl,
  % print(Schedule),
  % nl,
  % print('----!'),
  % nl,
  NewSlot #= Slot + 1,
  countGaps(NewSlot, Schedule, RestOfGaps),
  TotalGaps #= RestOfGaps.

countGaps(Slot, Schedule, TotalGaps):-
  Slot #< 31,
  % \+element(_, Schedule, Slot),
  % print(Slot),
  % nl,
  % print(Schedule),
  % nl,
  % print('----!'),
  % nl,
  Start #= ((Slot // 5) * 5) + 1,
  Finish #= ((Slot // 5) + 1) * 5,
  RightBefore #= Slot - 1,
  RightAfter #= Slot + 1,
  findASlotBetween(Start, RightBefore, Schedule, Res1),
  findASlotBetween(RightAfter, Finish, Schedule, Res2),
  Res1 #= 1 #/\ Res2 #= 1 #==> TotalGaps #= RestOfGaps + 1,
  Res1 #\= 1 #\/ Res2 #\= 1 #==> TotalGaps #= RestOfGaps,
  countGaps(RightAfter, Schedule, RestOfGaps).

countAllScheduleGaps([], 0).

countAllScheduleGaps([H | T], GapList):-
  H = (A, B),
  countGaps(1, B, CurrentGaps),
  countAllScheduleGaps(T, RestOfGapList),
  append([CurrentGaps], RestOfGapList, GapList).


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

%
countDaysOff(Schedule, Start, Finish):-
  Start #> Finish.

countDaysOff(Schedule, Start, Finish):-
  Start #=< Finish,
  \+element(_, Schedule, Start),
  NewStart #= Start + 1,
  countDaysOff(Schedule, NewStart, Finish).


  testGaps(31, _, 0).

  testGaps(Slot, Schedule, TotalGaps):-
    Slot #< 31,
    element(Slot, Schedule, BoolAssigned),
    Start #= (((Slot - 1) // 5) * 5) + 1,
    Finish #= (((Slot - 1) // 5) + 1) * 5,
    RightBefore #= Slot - 1,
    RightAfter #= Slot + 1,
    testGaps(RightAfter, Schedule, RestOfGaps),
    % print(RightBefore),
    % print(RightAfter),
    % print(Start),
    % print(Finish),
    % print('---'),
    % nl,
    testSlots(Start, RightBefore, Schedule, Res1),
    testSlots(RightAfter, Finish, Schedule, Res2),
    % print(Res1),
    % nl,
    % print(Res2),
    % nl,
    % print('----'),
    % nl,
    BoolAssigned #= 0 #/\ Res1 #= 1 #/\ Res2 #= 1 #==> TotalGaps #= 1 + RestOfGaps,
    BoolAssigned #= 0 #/\ Res1 #= 1 #/\ Res2 #= 0 #==> TotalGaps #= RestOfGaps,
    BoolAssigned #= 0 #/\ Res1 #= 0 #/\ Res2 #= 1 #==> TotalGaps #= RestOfGaps,
    BoolAssigned #= 0 #/\ Res1 #= 0 #/\ Res2 #= 0 #==> TotalGaps #= RestOfGaps,
    BoolAssigned #= 1 #==> TotalGaps #= RestOfGaps.
% [1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

testSlots(Current, Max, _, 0):-
  Current #> Max.

testSlots(Current, Max, Schedule, Res):-
  % print('Here'),
  % nl,
  Current #=< Max,
  element(Current, Schedule, 1),
  Res #= 1.

testSlots(Current, Max, Schedule, Res):-
  % print('Here'),
  % nl,
  Current #=< Max,
  element(Current, Schedule, 0),
  NewCurrent #= Current + 1,
  findASlotBetween(NewCurrent, Max, Schedule, Res).

%%%%%% Server Perdicates

handle_api(Request) :-
        % http_read_json_dict(Request, Query),
        format('Content-type: text/plain~n~n'),
        % print(Request),
        consult(kb1),
        once(generateScheduleConfigurations(BestConfig, 1)),
        scheduleCourses(BestConfig, CollectiveList),
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
