  var http = require('http');
var parse = require('csv-parse');
var fs = require('fs');

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
        labMap[courseMap[listOfCourses[i]['course_code']]].push([group, (listOfCourses[i]['day'] - 1) * 6 + parseInt(listOfCourses[i]['slot'])]);
        break;
      case 'Tut':
        tutorialMap[courseMap[listOfCourses[i]['course_code']]].push([group,(listOfCourses[i]['day']- 1) * 6 + parseInt(listOfCourses[i]['slot'])]);
        break;
      case 'Lecture':
        lectureMap[courseMap[listOfCourses[i]['course_code']]].push([group, (listOfCourses[i]['day'] - 1) * 6 + parseInt(listOfCourses[i]['slot'])]);
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
          lecs1 = labs1.concat([lecs[j][1]]);
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

  

  console.log("lecture1(" + i + ", [" + lecs1 + "]).");
    console.log("lecture2(" + i + ", [" + lecs2 + "]).");
    console.log("tutorial1(" + i + ", [" + tuts1 + "]).");
    console.log("tutorial2(" + i + ", [" + tuts2 + "]).");
    console.log("labs1(" + i + ", [" + labs1 + "]).");
    console.log("labs2(" + i + ", [" + labs2 + "]).");



    // if(tuts.length != 0 && labs.length != 0)
    // {
    //   // console.log(tuts);
    //     for(var j = 0; j < tuts.length; j++)
    //     {
    //       tuts1 = tuts1.concat([tuts[j][1]]);
    //       labs1 = labs1.concat([labs[j][1]]);
    //     }
    // }
    // else if(tuts.length != 0 && labs.length == 0)
    // {
      
    //   if(tuts[0][0] != tuts[1][0])
    //   {
    //     for(var j = 0; j < tuts.length; j++)
    //     {
    //       tuts1 = tuts1.concat([tuts[j][1]]);
    //     }
    //   }
    //   else
    //   {
    //     for(var j = 0; j < tuts.length; j++)
    //     {
    //       if(j % 2 == 0)
    //       {
    //         tuts1 = tuts1.concat([tuts[j][1]]);
    //       }
    //       else
    //       {
    //         tuts2 = tuts2.concat([tuts[j][1]]);
    //       } 
    //     }
    //   }
    // }
    // else if(labs.length != 0 && tuts.length == 0)
    // {

    //   if(labs[0][0] != labs[1][0])
    //   {

    //     for(var j = 0; j < labs.length; j++)
    //     {
    //       labs1 = labs1.concat([labs[j][1]]);
    //     }
    //   }
    //   else
    //   {

    //    for(var j = 0; j < labs.length; j++)
    //     {
    //       if(j % 2 == 0)
    //       {
    //         labs1 = labs1.concat([labs[j][1]]);
    //       }
    //       else
    //       {
    //         labs2 = labs2.concat([labs[j][1]]);
    //       } 
    //     }
    //   }
    // }
    // else
    // {
    //   console.log("hello");
    // }



    








  }





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


