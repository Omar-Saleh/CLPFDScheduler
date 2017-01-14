% ------------ Facts ------------ %
% 1 -> Math, 2 -> CS 1, 3 -> Advanced

% lecture(CourseNum, Slot, Group)
lecture1(1, [3,5]).
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

% ------------ %

preq(1, [4]).
preq(2, [1]).
preq(3, [1,2,3]).

passedCourses([1,2,3]).
