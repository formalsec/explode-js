"use strict"
const esl = require("esl_symbolic");
const gitlog = require('gitlogplus');
const options =
{
  repo: __dirname,
  number: esl.string("number")
};
let commits = gitlog(options);
console.log(commits);
