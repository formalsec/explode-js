const esl = require('esl_symbolic');
'use strict';

const Pullit = require('pullit');

const p = Object.create(Pullit.prototype);
p.owner = 'some-owner';
p.repo  = 'some-repo';
// Payload flows from the stubbed API response's `ref` field into execSync;
// p.fetch(1) takes a numeric id, so the symbolic string is placed at the actual sink-bound value.
p.github = {
  pullRequests: {
    get: function () {
      return Promise.resolve({
        data: {
          head: {
            ref: esl.string('payload')
          }
        }
      });
    }
  }
};

try {
  p.fetch(1);
} catch (e) {}
