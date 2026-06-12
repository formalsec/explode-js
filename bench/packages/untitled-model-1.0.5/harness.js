const Symbolic = require("esl_symbolic");
const model = require("untitled-model");

function setup() {
  const mysql = require("mysql");
  const host = process.env.MYSQL_HOST || "127.0.0.1";
  const port = Number(process.env.MYSQL_PORT || 3306);
  const user = process.env.MYSQL_USER || "root";
  const password = process.env.MYSQL_PASSWORD || "password";
  const database = process.env.MYSQL_DB || "test";

  const conn = mysql.createConnection({ host, port, user, password, database });

  conn.query(`DROP TABLE IF EXISTS user`);
  conn.query(`
      CREATE TABLE user (
        id INT PRIMARY KEY,
        username VARCHAR(255) NOT NULL
      )
    `);

  conn.query(`INSERT INTO user (id, username) VALUES (1, 'victim')`);
  conn.query(`INSERT INTO user (id, username) VALUES (2, 'admin')`);

  console.log("setup-db complete");
  conn.end()
}

function env(name, fallback) {
  return process.env[name] || fallback;
}

// Promisify User.filter({...}, cb)
function filterP(User, obj) {
  return new Promise((resolve, reject) => {
    User.filter(obj, (err, data) => {
      if (err) return reject(err);
      resolve(data);
    });
  });
}

async function run() {
  setup();

  // This matches the PoC exactly, just parameterized via env vars.
  model.connection({
    host: env("MYSQL_HOST", "127.0.0.1"),
    user: env("MYSQL_USER", "root"),
    password: env("MYSQL_PASSWORD", ""),
    database: env("MYSQL_DB", "test"),
    port: Number(env("MYSQL_PORT", "3306")),
  });

  let User = model.get("user");
  if (!User || typeof User.filter !== "function") {
    throw new Error("model.get('user') did not return an object with .filter()");
  }

  // This is the exact PoC payload:
  // "' or id=2#"
  // which aims to turn the filter into something like:
  // ... WHERE id = '' OR id=2 #'
  // const payload = "' or id=2#";
  const payload = Symbolic.string("payload");

  await filterP(User, { id: payload });
}

run();
