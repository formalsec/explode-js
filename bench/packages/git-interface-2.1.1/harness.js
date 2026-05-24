const esl = require("esl_symbolic");
const { Git } = require('git-interface');

const git = new Git({
    dir: './' //default path is current directory
});

git.clone(esl.string("url"), esl.string("payload"));
