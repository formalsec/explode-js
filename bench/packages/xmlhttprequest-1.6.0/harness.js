const { XMLHttpRequest } = require("xmlhttprequest");
const esl = require("esl_symbolic");
const xhr = new XMLHttpRequest();
xhr.open("POST", "http://localhost.invalid/", false /* use synchronize request */);
xhr.send(esl.string("payload"));
