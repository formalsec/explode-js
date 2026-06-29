const Symbolic = require("esl_symbolic");

require.cache[require.resolve("bluebird")] = { exports: Promise };

require.cache[require.resolve("mssql")] = {
  exports: Symbolic.lazy_object()
};

require.cache[require.resolve("mssql/lib/base")] = {
  exports: Symbolic.lazy_object()
};

const knexFactory = require("knex");

function knexCfg() {
  return {
    client: "mssql",
    connection: {
      host: process.env.MSSQL_HOST || "127.0.0.1",
      port: Number(process.env.MSSQL_PORT || 14333),
      user: process.env.MSSQL_USER || "sa",
      password: process.env.MSSQL_PASSWORD || "YourStrong!Passw0rd",
      database: process.env.MSSQL_DB || "knex_sqli",
      options: { encrypt: false, trustServerCertificate: true },
    },
    pool: { min: 0, max: 0 },
  };
}

async function run() {
  console.log("PROBE knexFactory");
  const knex = knexFactory(knexCfg());

  console.log("PROBE injectedOrderColumn");
  const injectedOrderColumn =
    "id] ; EXEC('DELETE FROM users WHERE username = ''admin''') ; --\n";

  console.log("PROBE knex");
  const sql = knex("dbo.users")
    .where(injectedOrderColumn, 1);

  // const sql = knex("dbo.users")
  //   .where({ username: "victim" })
  //   .select("id", "username")
  //   .orderBy(injectedOrderColumn, "asc")
  //   .toSQL();

  console.log("PROBE sinkCall");
  /* This package is a query builder, just check if the query is tainted */
  Symbolic.sinkCall("sql-injection", "query", sql.sql);
}

run();
