const getLockfile = require('npm-lockfile/getLockfile');
const esl = require('esl_symbolic');
const packageFile = path.resolve(__dirname, 'package.json');
getLockfile(packageFile, undefined, { only: esl.string('payload') });