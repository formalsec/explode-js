/* eslint-env jest */
/**
 * GHSA-m9jw-237r-gvfv / CVE-2019-10752
 * SQLi via sequelize.json() sub-path formatting.
 *
 * Observable DB effect: time delay via injected SLEEP(2).
 *
 * Affected: sequelize <4.44.3 OR >=5.0.0 <5.15.1. Patched: 4.44.3, 5.15.1.
 */
const Symbolic = require("esl_symbolic");
const EventEmitter = require("events");

class Mysql extends EventEmitter {
  constructor(options) {
    super();
    this.stream = { destroyed: false };
    console.log("[STUB] mysql constructor");
    // Defer the 'connect' event using Promise.then to ensure it's truly async
    // and listeners can be attached first.
    Promise.resolve().then(() => {
      console.log("[STUB] Emitting connect event now...");
      this.emit('connect');
    });
  }

  query(sql, cb) {
    const queryStr = typeof sql === 'object' ? sql.sql : sql;
    console.log("[STUB] mysql query:", queryStr);

    let results = [];
    if (queryStr.includes('SELECT VERSION()')) {
      results = [{ version: '5.7.0' }];
    } else if (queryStr.includes('SHOW INDEX FROM')) {
      results = [];
    } else if (queryStr.includes('DESCRIBE')) {
      results = [];
    } else if (queryStr.includes('INSERT INTO')) {
      results = { affectedRows: 1, insertId: 1 };
    } else if (queryStr.includes('SELECT')) {
      // Return some data for SELECT queries to avoid issues
      results = [];
    } else {
      results = { affectedRows: 0 };
    }

    if (cb) {
      // mysql2 callback is (err, results, fields)
      // Sequelize seems to only use the results part in its promise wrapper
      cb(null, results);
    }

    // Sequelize calls setMaxListeners(100) on the return value of query()
    return { setMaxListeners: () => { } };
  }

  execute(sql, params, cb) {
    return this.query(sql, cb);
  }

  end(cb) {
    if (cb) cb();
  }
}

require.cache[require.resolve("mysql2")] = {
  exports: {
    createConnection: (options) => {
      return new Mysql(options);
    }
  },
};

const Sequelize = require("sequelize");

const cfg = {
  host: process.env.MYSQL_HOST || "127.0.0.1",
  port: Number(process.env.MYSQL_PORT || 3310),
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "password",
  database: process.env.MYSQL_DB || "sequelize_json_10752",
};

async function run() {
  console.log('Setting up database ...');

  let sequelize = new Sequelize(cfg.database, cfg.user, cfg.password, {
    host: cfg.host,
    port: cfg.port,
    dialect: "mysql",
    logging: false,
  });

  console.log('Defining "User" model ...');

  let User = sequelize.define(
    "User",
    {
      name: Sequelize.DataTypes.STRING,
      data: Sequelize.DataTypes.JSON,
    },
    { tableName: "users", timestamps: false }
  );

  console.log("authenticate");
  await sequelize.authenticate();

  console.log("sync");
  await sequelize.sync({ force: true });

  console.log("bulkCreate");
  await User.bulkCreate([
    { name: "victim", data: { id: 1 } },
    { name: "control", data: { id: 2 } },
  ]);

  console.log('Exucuting vulnerable API ...');

  // const injectedPath = "data.id' = 1 OR SLEEP(2) -- ";
  const injectedPath = Symbolic.string("payload");
  // Symbolic.assume(injectedPath.length < 28);

  const result = sequelize.json(injectedPath, 1);

  await User.findAll({
    where: result, // vulnerable API
    attributes: ["name"],
    raw: true,
  });
}

run()
