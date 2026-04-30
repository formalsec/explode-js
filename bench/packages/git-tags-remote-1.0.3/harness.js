const esl = require('esl_symbolic');
const gtr = require('git-tags-remote');
(async () => {
  try {
    const payload = esl.string('payload');
    await gtr.get(payload);
  } catch (err) {
  }
})();
