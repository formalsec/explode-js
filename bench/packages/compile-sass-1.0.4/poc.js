function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}
async function main(){
    var a = require('compile-sass');
    a.setupCleanupOnExit('& touch JHU.txt');
    console.log('Press Ctrl-C in 3 seconds...')
    await sleep(3000);
}
main();
