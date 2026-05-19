var root = require("promise-probe");

root.ffprobe("& touch JHU");
root.createMuteOgg("123", { seconds: "& touch JHU &" });
root.createMuteOgg("& touch JHU", {});
