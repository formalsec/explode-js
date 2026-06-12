const Symbolic = require("esl_symbolic");
const mysql = require("mysql");

function dbCfg() {
  return {
    host: process.env.MYSQL_HOST || "127.0.0.1",
    port: Number(process.env.MYSQL_PORT || 3308),
    user: process.env.MYSQL_USER || "sqliuser",
    password: process.env.MYSQL_PASSWORD || "",
    database: process.env.MYSQL_DATABASE || "mysql_object_key_sqli",
    multipleStatements: true,
  };
}

function makeConn() {
  const cfg = dbCfg();

  console.log("[test] cfg", {
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password === "" ? "<empty>" : "<set>",
    database: cfg.database,
    multipleStatements: cfg.multipleStatements,
  });

  return mysql.createConnection(cfg);
}

function connectP(conn) {
  return new Promise((resolve, reject) => {
    conn.connect((err) => {
      if (err) {
        return reject(
          new Error(
            [
              "[connect failed]",
              `code=${err.code}`,
              `errno=${err.errno}`,
              `sqlState=${err.sqlState}`,
              `sqlMessage=${err.sqlMessage}`,
              `fatal=${err.fatal}`,
            ].join("\n")
          )
        );
      }

      resolve();
    });
  });
}

function queryP(conn, sql, values) {
  return new Promise((resolve, reject) => {
    let q;

    q = conn.query(sql, values, (err, rows) => {
      if (err) {
        return reject(
          new Error(
            [
              "[query failed]",
              `code=${err.code}`,
              `errno=${err.errno}`,
              `sqlState=${err.sqlState}`,
              `sqlMessage=${err.sqlMessage}`,
              `generatedSql=${q && q.sql}`,
            ].join("\n")
          )
        );
      }
      resolve({ rows, sql: q.sql });
    });

    console.log("[generated sql]", q.sql);
  });
}

async function withConn(fn) {
  const conn = makeConn();
  await connectP(conn);

  try {
    return await fn(conn);
  } finally {
    conn.end();
  }
}

async function resetRows(conn) {
  await queryP(conn, `TRUNCATE TABLE test_inject`);
}

async function valuesInTable(conn) {
  const { rows } = await queryP(
    conn,
    `SELECT a FROM test_inject ORDER BY id ASC`
  );

  return rows.map((r) => r.a);
}

async function run() {
  await withConn(async (conn) => {
    await resetRows(conn);

    const safeObj = { a: 1 };

    const safe = await queryP(
      conn,
      `INSERT INTO test_inject SET ?`,
      safeObj
    );

    console.log("[safe sql]", safe.sql);

    await resetRows(conn);

    // Original mysqljs/mysql#342 payload shape.
    // Vulnerable objectToValues manually builds:
    //   `key` = escapedValue
    //
    // This key breaks out of the backtick identifier and injects
    // a second INSERT statement.
    const maliciousObj = {
      [Symbolic.string("payload")]: 1,
    };

    await queryP(
      conn,
      `INSERT INTO test_inject SET ?`,
      maliciousObj
    );
  });
}

run();
