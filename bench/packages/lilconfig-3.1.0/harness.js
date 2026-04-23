const { defaultLoaders } = require('lilconfig');
const esl = require('esl_symbolic');
const payload = esl.string("payload");
defaultLoaders[".js"](payload);
