const jscover = require('jscover');

const source = 'src';
const target = 'outdir';

// The injected element breaks out of the java command via semicolons.
// The shell executes `touch /tmp/os_cmd_success` as a separate command.
const options = ['; touch ' + TMP_FILE + ';'];

jscover(source, target, options, function (err, output) {
  if (err) {
    console.log('Callback err (expected - java not present):', err.message || err);
  } else {
    console.log('Callback success, output:', output);
  }
});


