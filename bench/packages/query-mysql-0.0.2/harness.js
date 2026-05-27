const esl = require('esl_symbolic');
const queryMysql = require("query-mysql");

function createClient() {
  // Create a fresh query-mysql instance + connection for each call
  function newQm() {
    queryMysql.configure({});
    return queryMysql;
  }

  function fetchById(table, id, name_id) {
    return new Promise((resolve, reject) => {
      const qm = newQm();
      qm.base.fetchById(table, id, name_id, (status, rows) => {
        if (status !== "success") {
          return reject(new Error(`query-mysql status: ${status}`));
        }
        resolve(rows);
      });
    });
  }

  return { fetchById };
}

client = createClient()
client.fetchById("users", esl.string("payload"), "username");
