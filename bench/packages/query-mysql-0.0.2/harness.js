const esl = require('esl_symbolic');

class Mysql {
  constructor(options) {
    console.log("mysql constructor");
  }

  connect(cb) {
    console.log("mysql connect");
    // always return a valid connection
    let error = null;
    cb(error)
  }

  query(queryStr, cb) {
    console.log("mysql query", queryStr);
    esl.sinkCall("sql-injection", "query", queryStr);
  }

  end() { }
}

require.cache[require.resolve("mysql")] = {
  exports: {
    createConnection: function (options) {
      return new Mysql(options);
    }
  }
}

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
      console.log("Here")
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
