const esl = require("esl_symbolic");
const Repo = require("gry");
let myRepo = new Repo(".");
myRepo.pull(esl.string("payload"), function () {});
