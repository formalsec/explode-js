const esl = require ("esl_symbolic");
const gitlog = require('gitlog').default;
try {
    gitlog({ repo: './', number: esl.string("number") });
} catch (err) {
    console.log('ignore error');
}
