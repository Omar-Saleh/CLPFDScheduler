var http = require('http');
var parse = require('csv-parse');
var fs = require('fs');

var seen = 1;
var courseMap = {};
tutorialMap = {};
lectureMap = {};
labMap = {};


fs.readFile('C:/Users/Omar/github/CLPFDScheduler/courses.csv', 'utf8', function (err,data) {
  if (err) {
    return console.log(err);
  }
  // console.log(data);
  parse(data, {columns: true}, function(err, output) {
    mapScheduleToUniqueNumbers(output);
  });
  // console.log(records)
});

function mapScheduleToUniqueNumbers(listOfCourses) {
  for(var i = 0; i < listOfCourses.length; i++) {
    // console.log(listOfCourses[i]);
    if(!courseMap[listOfCourses[i]['course_code']]) {
      courseMap[listOfCourses[i]['course_code']] = seen;
      tutorialMap[seen] = [];
      labMap[seen] = [];
      lectureMap[seen++] = [];
    }
      // console.log(tutorialMap);
    switch (listOfCourses[i]['type']) {
      case 'Lab':
        labMap[courseMap[listOfCourses[i]['course_code']]].push([listOfCourses[i]['day'], listOfCourses[i]['slot']]);
        break;
      case 'Tut':
        tutorialMap[courseMap[listOfCourses[i]['course_code']]].push([listOfCourses[i]['day'], listOfCourses[i]['slot']]);
        break;
      case 'Lec':
        lectureMap[courseMap[listOfCourses[i]['course_code']]].push([listOfCourses[i]['day'], listOfCourses[i]['slot']]);
        break;
      default:
        break;
    }
  }
  console.log(listOfCourses.length);
  console.log(courseMap);
  console.log(lectureMap);
  console.log(labMap);
  console.log(tutorialMap);
}

//The url we want is: 'www.random.org/integers/?num=1&min=1&max=10&col=1&base=10&format=plain&rnd=new'
// var options = {
//   host: '127.0.0.1',
//   // path: '/api',
//   port: '8000'
// };
//
// callback = function(response) {
//   var str = '';
//
//   //another chunk of data has been recieved, so append it to `str`
//   response.on('data', function (chunk) {
//     str += chunk;
//   });
//
//   //the whole response has been recieved, so we just print it out here
//   response.on('end', function () {
//     console.log(str);
//   });
// }
//
// http.request(options, callback).end();
