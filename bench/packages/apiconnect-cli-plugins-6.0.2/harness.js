const root = require("apiconnect-cli-plugins");
const esl = require('esl_symbolic');
const payload = [esl.string('payload')];
root.pluginLoader.installPlugin(
    [esl.string('payload')], 
    ""
).catch( () => {
    // empty callback 
}); 
