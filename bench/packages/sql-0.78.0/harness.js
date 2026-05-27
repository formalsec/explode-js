var esl = require("esl_symbolic");

class Database {
  constructor(type) {
  }

  exec(queryStr, cb) {
    console.log("Database.exec")
    esl.sinkCall("sql-injection", "exec", queryStr);
  }

  all(queryStr, cb) {
    console.log("Database.all")
    esl.sinkCall("sql-injection", "all", queryStr);
  }

}

require.cache[require.resolve("sqlite3")] = {
  exports: {
    Database: Database
  }
};

const sqlite3 = require("sqlite3");

function openDb() {
  return new sqlite3.Database(":memory:");
}

function execP(db, text) {
  return new Promise((resolve, reject) => {
    db.exec(text, (err) => (err ? reject(err) : resolve()));
  });
}

function allP(db, text) {
  return new Promise((resolve, reject) => {
    db.all(text, (err, rows) => (err ? reject(err) : resolve(rows)));
  });
}

const sql = require("sql");

sql.setDialect("sqlite");

const db = openDb();
execP(
  db,
  `
  CREATE TABLE credentials (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
  );
  INSERT INTO credentials (id, name) VALUES (1, 'victim');
  INSERT INTO credentials (id, name) VALUES (2, 'admin');
  `
);

// Define table in node-sql style (from README examples). :contentReference[oaicite:3]{index=3}
const credentials = sql.define({
  name: "credentials",
  columns: ["id", "name"],
});

// Baseline: safe limit
const safeQ = credentials.select(credentials.star()).from(credentials).limit(1).toQuery();
const safeRows = allP(db, safeQ.text);
// expect(safeRows.length).toBe(1);

// Injection via LIMIT (public PoC pattern: LIMIT '1; drop table ...'). :contentReference[oaicite:4]{index=4}
const payload = esl.string("payload");
esl.assume(payload !== "CREATE VIEW")

const injQ = credentials
  .select(credentials.star())
  .from(credentials)
  .limit(payload)
  .toQuery();

// Execute generated SQL. In sqlite3, exec() can execute multiple statements.
execP(db, injQ.text);
