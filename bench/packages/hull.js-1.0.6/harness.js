const hull = require("hull.js");
const esl_symbolic = require("esl_symbolic");

pointset = [{ x: 1, y: 2}]
format = [ esl_symbolic.string("x"), esl_symbolic.string("y") ];
hull(pointset, 20, format);
