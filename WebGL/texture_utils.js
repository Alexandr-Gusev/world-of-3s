function load_images(sources, on_result, on_complete) {
	var count = 0;
	for (var i = 0; i < sources.length; i++) {
		var item = {};
		item.index = i;
		item.image = new Image();
		item.image.onload = function(item) {
			return function() {
				count++;
				on_result(item);
				if (count === sources.length) {
					on_complete();
				}
			};
		}(item);
		item.image.src = sources[i];
	}
}

function load_images_on_result(item) {
	item.texture = gl.createTexture();
	gl.activeTexture(gl.TEXTURE0 + item.index);
	gl.bindTexture(gl.TEXTURE_2D, item.texture);

	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

	gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, item.image);
}
