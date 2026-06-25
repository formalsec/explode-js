const Symbolic = require('esl_symbolic');

// Stub the underlying 'pg' driver so we don't need a real PostgreSQL server.
// Every query is just logged to the console and returns an empty result set.
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
      end(callback) {
        this.ending = true;
        if (callback) callback();
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

const pgp = require('pg-promise')({});

async function run() {
  const db = pgp({
    host: 'postgres',
    user: 'postgres',
    password: 'postgres',
  });

  await db.any('CREATE TABLE IF NOT EXISTS pg_promise_example (result INT, name TEXT)');
  await db.any('CREATE TABLE IF NOT EXISTS pg_promise_secrets (secret TEXT)');
  await db.any('INSERT INTO pg_promise_secrets VALUES ($1)', ['super_secret_123']);

  const attackerControlled1 = -1;
  // const attackerControlled2 = 'foo\n 1 AND 1=0 UNION SELECT 1337, secret FROM pg_promise_secrets; --';
  const attackerControlled2 = Symbolic.string('payload');

  const r = await db.any('SELECT * FROM pg_promise_example WHERE result=-$1 OR name=$2;', [attackerControlled1, attackerControlled2]);
  console.log('Result:', r[0]);
  // Result: { result: 1337, name: 'super_secret_123' }

  db.$pool.end();
}

run();
