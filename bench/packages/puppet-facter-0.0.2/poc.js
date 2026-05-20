var root = require("puppet-facter")
root.getFact("& touch JHU", function () { }, {})
