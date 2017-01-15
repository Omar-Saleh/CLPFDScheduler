var http = require('http');
var parse = require('csv-parse');
var fs = require('fs');
var express = require('express');
var multer = require('multer');
var pug = require('pug');
var app = express();
var routes = express.Router();
var upload = multer({ dest: './uploads' });

app.set('view engine', 'pug')

app.listen(3000);

app.get('/', function (req, res) {
  res.render('index', { title: 'Hey', message: 'Hello there!' })
})

app.post('/uploadSchedule', function(req, res) {
  console.dir(req.files);
  res.redirect('/compiledSchedule');
});




// Parsing THE UPLOADED CSV File.
var seen = 1;
var groupNumber = 1;
var courseMap = {};
tutorialMap = {};
lectureMap = {};
labMap = {};
groupMap = {};

fs.readFile('courses.csv', 'utf8', function (err,data) {
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
    var currentCourseNumber = courseMap[listOfCourses[i]['course_code']];
    var group = listOfCourses[i]['group'].replace(/[^\d]/g, '');

    if(!groupMap[group])
      groupMap[group] = groupNumber++;

    switch (listOfCourses[i]['type']) {
      case 'Lab':
        labMap[courseMap[listOfCourses[i]['course_code']]].push([group, (listOfCourses[i]['day'] - 1) * 5 + parseInt(listOfCourses[i]['slot'])]);
        break;
      case 'Tut':
        tutorialMap[courseMap[listOfCourses[i]['course_code']]].push([group,(listOfCourses[i]['day']- 1) * 5 + parseInt(listOfCourses[i]['slot'])]);
        break;
      case 'Lecture':
        lectureMap[courseMap[listOfCourses[i]['course_code']]].push([group, (listOfCourses[i]['day'] - 1) * 5 + parseInt(listOfCourses[i]['slot'])]);
        break;
      default:
        break;
    }
  }

  // var a = listOfCourses



  // console.log(listOfCourses.length);
  // console.log(courseMap);
  // console.log(lectureMap);
  // console.log(labMap[4]);
  // console.log(tutorialMap[4]);
  // console.log(groupMap);
  // console.log(listOfCourses[0]['group']);
  // console.log(listOfCourses[0]['group'].replace(/[^\d]/g, ''));
  var textToWrite = "";

  for(var i = 1; i < Object.keys(courseMap).length + 1; i++)
  {
    var lecs = lectureMap[i];
    var tuts = tutorialMap[i];
    var labs = labMap[i];


    tuts1 = [];
    tuts2 = [];
    lecs1 = [];
    lecs2 = [];
    labs1 = [];
    labs2 = [];

    // console.log(lecs);
// if(i == 4){
//           // console.log("hiii");
//           console.log(tuts);
//           console.log(labs);
//         }


  if(tuts.length != 0)
  {
     if(tuts[0][0] != tuts[1][0])
      {
        for(var j = 0; j < tuts.length; j++)
        {
          tuts1 = tuts1.concat([tuts[j][1]]);
        }
      }
      else
      {
        for(var j = 0; j < tuts.length; j++)
        {
          if(j % 2 == 0)
          {
            tuts1 = tuts1.concat([tuts[j][1]]);
          }
          else
          {
            tuts2 = tuts2.concat([tuts[j][1]]);
          }
        }
      }
  }

  if(labs.length != 0)
  {

     if(labs[0][0] != labs[1][0])
      {
        for(var j = 0; j < labs.length; j++)
        {
          labs1 = labs1.concat([labs[j][1]]);
        }
      }
      else
      {
        for(var j = 0; j < labs.length; j++)
        {
          if(j % 2 == 0)
          {
            labs1 = labs1.concat([labs[j][1]]);
          }
          else
          {
            labs2 = labs2.concat([labs[j][1]]);
          }
        }
      }
  }

  if(lecs.length != 0)
  {

     if( lecs.length > 1 && lecs[0][0] != lecs[1][0])
      {
        for(var j = 0; j < lecs.length; j++)
        {
          lecs1 = lecs1.concat([lecs[j][1]]);
        }
      }
      else
      {
        for(var j = 0; j < lecs.length; j++)
        {
          if(j % 2 == 0)
          {
            lecs1 = lecs1.concat([lecs[j][1]]);
          }
          else
          {
            lecs2 = lecs2.concat([lecs[j][1]]);
          }
        }
      }
  }

  if(lecs1.length == 0)
  {
    lecs1 = [0];
    lecs2 = [0];
  }
  else if(lecs2.length == 0)
  {
    for(var j = 0; j < lecs1.length; j++)
    {
      lecs2 = lecs2.concat([0]);
    }
  }

  if(tuts1.length == 0)
  {
    tuts1 = [0];
    tuts2 = [0];
  }
  else if(tuts2.length == 0)
  {
    for(var j = 0; j < tuts1.length; j++)
    {
      tuts2 =tuts2.concat([0]);
    }
  }

  if(labs1.length == 0)
  {
    labs1 = [0];
    labs2 = [0];
  }
  else if(labs2.length == 0)
  {
    for(var j = 0; j <labs1.length; j++)
    {
      labs2 = labs2.concat([0]);
    }
  }
    // console.log(courseMap);
    // console.log("lecture1(" + i + ", [" + lecs1 + "]).");
    // console.log("lecture2(" + i + ", [" + lecs2 + "]).");
    // console.log("tutorial1(" + i + ", [" + tuts1 + "]).");
    // console.log("tutorial2(" + i + ", [" + tuts2 + "]).");
    // console.log("labs1(" + i + ", [" + labs1 + "]).");
    // console.log("labs2(" + i + ", [" + labs2 + "]).");
    textToWrite += "lecture1(" + i + ",[" + lecs1 + "])." + '\n';
    textToWrite += "lecture2(" + i + ",[" + lecs2 + "])." + '\n';
    textToWrite += "tutorial1(" + i + ",[" + tuts1 + "])." + '\n';
    textToWrite += "tutorial2(" + i + ",[" + tuts2 + "])." + '\n';
    textToWrite += "lab1(" + i + ",[" + labs1 + "])."  + '\n';
    textToWrite += "lab2(" + i + ",[" + labs2 + "])."  + '\n';
  }


  fs.writeFileSync('kb1.pl', textToWrite, 'utf8');



  // var file = new File("facts.txt");
  // file.open("w");
  // file.writeln("hello!");
  // file.close();


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
