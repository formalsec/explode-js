// testing taint from parameter to eval function call
// paremeter passed as argument to process.argv

const process = require('process');
const x = process.argv[2];
eval(x);
