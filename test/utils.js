module.exports = {
  assert: function (cond) {
    if (!cond) {
      throw Error(`Assertion failed: ${cond}`)
    }
  },
};
