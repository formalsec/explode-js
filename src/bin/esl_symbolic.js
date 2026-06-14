const fs = require('fs');

const modelPath = process.env.EXPLODE_JS_WITNESS || process.argv[2];

function createLazyModel() {
  let isLoaded = false;
  let target = {};

  const ensureLoaded = () => {
    if (!isLoaded) {
      try {
        const contents = fs.readFileSync(modelPath, 'utf8');
        target = JSON.parse(contents).model;
      } catch (err) {
        console.error(`Failed to load config from ${modelPath}`, err);
        target = {};
      }
      isLoaded = true;
    }
  }

  return new Proxy({}, {
    get(_, prop) {
      ensureLoaded();
      return target[prop];
    }
  });
}

let symbolic_map = createLazyModel();

function getSymbol(x) {
  let symbol = symbolic_map[x];
  return (symbol === undefined) ? undefined : symbol.value;
}

function ignore(_) { }

function is_symbolic(_) { return false }

function lazy_object() { return {}; }

function polluted_object(depth) {
  switch (depth) {
    case 1:
      return { ["__proto__"]: { "polluted": "yes" } }
    case 2:
      return { ["__proto__"]: { "toString": "polluted" } }
    case 3:
      return { "constructor": { "prototype": { "polluted": "yes" } } }
    default:
  }
  return {}
}

module.exports = {
  any: getSymbol,
  number: getSymbol,
  string: getSymbol,
  boolean: getSymbol,
  function: function (_x) { return function () { }; },
  lazy_object: lazy_object,
  assume: ignore,
  assert: ignore,
  is_symbolic: is_symbolic,
  sealProperties: ignore,
  polluted_object: polluted_object
};
