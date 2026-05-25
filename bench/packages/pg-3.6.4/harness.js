const esl = require("esl_symbolic");
const pg = require("pg");

const Query = pg.Client.Query;

const payload = esl.string("payload");

const query = new Query({ text: "SELECT 1", rowMode: undefined });

query.handleRowDescription({
  fields: [{ name: payload, dataTypeID: 23, format: "text" }],
});

query.handleDataRow({ fields: ["1"] });

