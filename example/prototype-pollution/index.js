var hasOwnProp = Object.prototype.hasOwnProperty;

module.exports = deep;

function deep (obj, path, value) {
  if (arguments.length === 3) return set(obj, path, value);
  return get(obj, path);
}

function get (obj, path) {
  var keys = Array.isArray(path) ? path : path.split('.');
  for (var i = 0; i < keys.length; i++) {
    var key = keys[i];
    if (!obj || !hasOwnProp.call(obj, key)) {
      obj = undefined;
      break;
    }
    obj = obj[key];
  }
  return obj;
}

function set (obj, path, value) {
  var keys = Array.isArray(path) ? path : path.split('.');
  for (var i = 0; i < keys.length - 1; i++) {
    var key = keys[i];
    if (deep.p && !hasOwnProp.call(obj, key)) obj[key] = {};
    obj = obj[key];
  }
  obj[keys[i]] = value;
  return value;
}
