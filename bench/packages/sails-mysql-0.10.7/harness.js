var adapter = require('sails-mysql');
var Symbolic = require('esl_symbolic');

var wlSchema = {
  users: {
    tableName: 'users',
    identity: 'users',
    attributes: {
      id:     { type: 'integer', primaryKey: true, columnName: 'id' },
      name:   { type: 'string',  columnName: 'name' },
      email:  { type: 'string',  columnName: 'email' }
    }
  }
};

// First register a connection so the adapter knows about our collections.
// We set pool:false to avoid real MySQL pool creation.
adapter.registerConnection(
  {
    identity: 'testdb',
    host: '127.0.0.1',
    port: 3306,
    database: 'test',
    pool: false
  },
  {
    users: {
      definition: {
        id:    { type: 'integer', primaryKey: true },
        name:  { type: 'string' },
        email: { type: 'string' }
      },
      schema: {},
      waterline: { schema: wlSchema }
    }
  },
  function(err) {
    if (err) { console.log('registerConnection error:', err); return; }
    runAdapterTests();
  }
);

function runAdapterTests() {

  function mockConnection() {
    return {
      query: function(sqlOrOpts, valuesOrCb, cb) {
        var sql, callback;
        var isCount = false;
        if (typeof valuesOrCb === 'function') {
          sql = sqlOrOpts;
          callback = valuesOrCb;
        } else if (typeof cb === 'function') {
          sql = sqlOrOpts;
          callback = cb;
        } else {
          sql = sqlOrOpts;
          callback = function() {};
        }

        Symbolic.sinkCall('sql-injetion', 'query', sql);
        console.log('-> Intercepted SQL: ' + (typeof sql === 'string' ? sql : JSON.stringify(sql)));

        if (typeof sql === 'string' && /count\(\*\)/i.test(sql)) {
          callback(null, [{ count: 0 }]);
        } else {
          callback(null, []);
        }
      }
    };
  }

  // NOTE: adapter.count() validates that groupBy requires sum/avg/min/max.
  // When both are provided, the injection goes through to sql.countQuery.
  adapter.count('testdb', 'users',
    // { groupBy: ['status; DROP TABLE users; -- '], sum: ['price'] },
    { groupBy: [Symbolic.string('payload')], sum: ['price'] },
    function(err, result) {
      console.log('^^ The groupBy key was raw-concatenated into SQL above!');
      console.log('');
    },
    mockConnection()
  );

}
