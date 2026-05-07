const esl = require("esl_symbolic");
let config = {
  iOS: {
    images: []
  },
  android: {
    images: [
      {
        baseRatio: esl.string("baseRatio"),
        folder: "drawable-mdpi",
      }
    ]
  }
}

exports = module.exports = config;
