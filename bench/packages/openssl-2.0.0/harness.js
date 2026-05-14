const esl = require("esl_symbolic");
require.cache["util"] = { exports: esl.lazy_object() };

const openssl = require('openssl');

const opts = {
    verb: esl.string("verb"),
    flags: "",
    tail: ""
};

const r = openssl(opts);
