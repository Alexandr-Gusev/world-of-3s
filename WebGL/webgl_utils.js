function create_shader(gl, type, source) {
	var shader = gl.createShader(type);
	gl.shaderSource(shader, source);
	gl.compileShader(shader);
	if (gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
		return shader;
	}
	console.log(gl.getShaderInfoLog(shader));
	gl.deleteShader(shader);
}

function create_program(gl, vs, fs) {
	var program = gl.createProgram();
	gl.attachShader(program, vs);
	gl.attachShader(program, fs);
	gl.linkProgram(program);
	if (gl.getProgramParameter(program, gl.LINK_STATUS)) {
		return program;
	}
	console.log(gl.getProgramInfoLog(program));
	gl.deleteProgram(program);
}
