const Repo = require("gry");
let myRepo = new Repo(".");
myRepo.pull("test; touch gry; #", function () {});
