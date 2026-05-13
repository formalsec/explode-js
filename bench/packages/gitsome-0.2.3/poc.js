const gitSome = require('gitsome')
const payload = `2020-01-01; touch success; #`
const result = gitSome({ path: '/tmp', format: ['%H'], date: payload })
console.log('commits count:', result.commits.length)
