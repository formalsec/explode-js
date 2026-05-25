const esl = require('esl_symbolic');
require.cache[require.resolve("mongodb")] = { exports: esl.lazy_object() };

const bsonLib = require('./node_modules/mongo-express/lib/bson');

const payload = esl.string('payload');
bsonLib.toBSON(payload);

