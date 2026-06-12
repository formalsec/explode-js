const Symbolic = require("esl_symbolic");

const squel = require("squel");
const mysql = require("mysql");

function openDb(cfg) {
  return mysql.createConnection(cfg);
}

function execP(db, sql) {
  return new Promise((resolve, reject) => {
    db.query(sql, (err) => (err ? reject(err) : resolve()));
  });
}


async function run() {
  const db = openDb({
    host: process.env.MYSQL_HOST || "127.0.0.1",
    port: Number(process.env.MYSQL_PORT || 3308),
    user: process.env.MYSQL_USER || "sqliuser",
    password: process.env.MYSQL_PASSWORD || "",
    database: process.env.MYSQL_DATABASE || "mysql_object_key_sqli",
    multipleStatements: true,
  });

  // Schema + seed
  await execP(
    db,
    `
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          role TEXT NOT NULL
        );
        INSERT INTO users (username, role) VALUES ('victim', 'user');
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foo TEXT NOT NULL
        );
        `
  );

  // const payload = `x'); UPDATE users SET role='admin' WHERE username='victim'; --`;
  const payload = Symbolic.string("payload");

  const injectedSql = squel
    .insert()
    .into("notes")
    .setFields({ foo: payload })
    .toString();

  await execP(db, injectedSql);
}

run();
