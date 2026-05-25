const Realm = require("realms-shim");
const esl = require("esl_symbolic");

const r = Realm.makeRootRealm();
r.evaluate(esl.string("payload"));
