const esl = require("esl_symbolic");
const root = require("codecov");
let args = {
  options: {
    "gcov-root": esl.string("gcov-root"),
    "gcov-exec": " ",
    "gcov-args": " ",
  },
};
root.handleInput.upload(
  args,
  function () {
    console.log("success");
  },
  function () {
    console.log("Fail!");
  }
);

