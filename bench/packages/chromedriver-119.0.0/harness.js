const esl = require("esl_symbolic");
require.cache[require.resolve('tcp-port-used')] = { exports: esl.lazy_object() };

const chromedriver = require('chromedriver');

const args = [ esl.string("arg") ];
const returnPromise = false;

chromedriver.path = esl.string("path");

// This creates a local 'exploited.txt' file.
chromedriver.start(args, returnPromise);
