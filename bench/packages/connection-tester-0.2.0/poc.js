const a = require("connection-tester");
try {
  a.test("& touch connection-tester", 123, 1000);
} catch (error) {}
