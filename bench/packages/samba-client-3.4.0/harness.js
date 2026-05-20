const esl = require("esl_symbolic");
const SambaClient = require('samba-client');

let client = new SambaClient({
  address: esl.string("address"),
  username: 'test',
  password: 'test',
  domain: 'WORKGROUP',
  maxProtocol: 'SMB3',
  maskCmd: true,
});
client.mkdir("test");
