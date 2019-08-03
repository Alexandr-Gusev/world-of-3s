var preset = new URL(window.location).searchParams.get("preset");
if (preset === null) preset = 0;
else preset = parseInt(preset);

var w_const = undefined;
var h_const = undefined;

var universe_L = 100;
var universe_R = universe_L / (2 * Math.PI);

var camera_size = 0.01;
var camera_size_px = 500;

var earth_R = 1;

var distance_min = earth_R + 2 * camera_size;
var distance_max = universe_R > 0 ? universe_L - distance_min : 100;

var distance = 5;
var camera_a1 = 0;
var earth_a0 = 0;
var earth_a1 = 0;
var orbit_a0 = 0;
var orbit_a1 = 0;
var zoom = 1;

var distance_delta = 0.25;
var angle_delta = 1;
var motion_speed_k = 1.25;
var sat_a_delta = 1;
var light_power_delta = 0.25;
var zoom_k = 1.25;
var earth_R_k = 1.25;

var camera;

var fps = 0;
var fps_ts = 0;
var frame_count = 0;

var info_div = document.getElementById("info");
var canvas = document.getElementById("canvas");
var gl = canvas.getContext("webgl");
var vs = {src: "vs.glsl"};
var fs = {src: "fs.glsl"};
var fse_prefix = {src: "fse/fse_prefix.glsl"};
var fse = {src: "fse/fse.glsl"};
var fse_suffix = {src: "fse/fse_suffix.glsl"};
var program;
var loc = {};
var positionBuffer;
var texture_enabled = false;

var info_mode = "all";
var info = {};

function info_append(name, suffix, no_value) {
	var text = name;
	if (suffix) text += " (" + suffix + ")";
	if (!no_value) text += ": ";
	if (info_mode === "all") {
		info_div.appendChild(document.createTextNode(text))
	}
	info[name] = info_div.appendChild(document.createTextNode(""));
	info_div.appendChild(document.createElement("br"));
}

function create_info_block() {
	info_div.innerHTML = "";
	if (info_mode === "all") {
		info_append("w");
		info_append("h");
		info_append("fps");
		info_append("universe_L");
		info_append("universe_R");
		info_append("distance", "W / S");
		info_append("camera_a1", "Up / Dn");
		info_append("earth_a0 & orbit_a0", "Left / Right");
		info_append("earth_a0", "Shift + Left / Right");
		info_append("earth_a1", "Shift + Up / Dn");
		info_append("orbit_a0", "Ctrl + Left / Right");
		info_append("orbit_a1", "Ctrl + Up / Dn");
		info_append("earth_R", "Home / End");
		info_append("sun_H", "Ctrl + Home / End");
		info_append("zoom", "PgUp / PgDn");
		info_append("textures", "T");
		info_append("universe", "U");
		info_append("light_model", "L");
		info_append("S_enabled", "A");
		info_append("WF_enabled", "F");
		info_append("light_power", "Shift + Home / End");
		info_append("motion", "Space");
		info_append("motion_direction", "D");
		info_append("motion_speed", "Alt + Home / End");
		info_append("moon_a", "Alt + Up / Dn");
		info_append("sun_a", "Alt + PgUp / PgDn");
		info_append("eclipse", "E", true);
		info_append("info", "I", true);
		info_append("next / prev preset", "1 / 2", true);
	} else if (info_mode === "d") {
		info_append("distance");
	} else if (info_mode === "a") {
		info_append("angle");
	}
}

var moon_R = 0.1;
var moon_H = 0.5; // высота над Землей
var moon_T = 10; // период [с]
var moon_t = 0;
var moon_dt = -moon_T / 4; // фаза [с]
var moon_t_delta = sat_a_delta / 360 * moon_T;

var sun_R = 0.25;
var sun_H = 1;
var sun_T = 15;
var sun_t = 0;
var sun_dt = -sun_T / 4;
var sun_t_delta = sat_a_delta / 360 * sun_T;

var start_t = undefined;

var light_model = 1;
/*
0: рисуем точку как есть
1: простая - яркость точки поверхности зависит от косинуса угла между внешней нормалью к поверхности и направлением на наблюдателя
2: реалистическая - с выделенным точечным источником света
*/
var S_enabled = false; // учет влияния площади волнового фронта
var WF_enabled = false; // учет особенностей восприятия (закон Вебера - Фехнера)
var light_power = 1;
var ambient_c = 0;

var motion_enabled = true;
var motion_direction = 1;
var motion_speed = 1;

function load_shaders_on_result(item, e) {
	if (e.target.status === 200) {
		item.content = e.target.responseText;
	} else {
		console.log("can not load " + item.src);
	}
}

function load_shaders_on_complete() {
	var compiled_vs = create_shader(gl, gl.VERTEX_SHADER, vs.content);
	var compiled_fs = create_shader(gl, gl.FRAGMENT_SHADER, fs.content + fse_prefix.content + fse.content + fse_suffix.content);
	program = create_program(gl, compiled_vs, compiled_fs);

	loc.position = gl.getAttribLocation(program, "position");

	positionBuffer = gl.createBuffer();
	gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
	var positions = [
		-1, -1,
		1, -1,
		1, 1,
		-1, 1
	];
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

	loc.universe_R = gl.getUniformLocation(program, "universe_R");

	loc.camera_base = gl.getUniformLocation(program, "camera.base");
	loc.camera_dx = gl.getUniformLocation(program, "camera.dx");
	loc.camera_dy = gl.getUniformLocation(program, "camera.dy");

	var sphere_count = 3;

	for (var i = 0; i < sphere_count; i++) {
		var prefix = "sphere[" + i + "]";
		loc[prefix + ".center"] = gl.getUniformLocation(program, prefix + ".center");
		loc[prefix + ".basis.ex"] = gl.getUniformLocation(program, prefix + ".basis.ex");
		loc[prefix + ".basis.ey"] = gl.getUniformLocation(program, prefix + ".basis.ey");
		loc[prefix + ".basis.ez"] = gl.getUniformLocation(program, prefix + ".basis.ez");
		loc[prefix + ".R"] = gl.getUniformLocation(program, prefix + ".R");
		loc[prefix + ".R_angular"] = gl.getUniformLocation(program, prefix + ".R_angular");

		var image_key = "image[" + i + "]";
		loc[image_key] = gl.getUniformLocation(program, image_key);
	}

	loc.texture_enabled = gl.getUniformLocation(program, "texture_enabled");

	loc.light_model = gl.getUniformLocation(program, "light_model");
	loc.S_enabled = gl.getUniformLocation(program, "S_enabled");
	loc.WF_enabled = gl.getUniformLocation(program, "WF_enabled");
	loc.light_center = gl.getUniformLocation(program, "light_center");
	loc.light_power = gl.getUniformLocation(program, "light_power");
	loc.ambient_c = gl.getUniformLocation(program, "ambient_c");
	loc.preset = gl.getUniformLocation(program, "preset");

	gl.clearColor(0, 0, 0, 0);
	gl.useProgram(program);
	gl.enableVertexAttribArray(loc.position);
	gl.vertexAttribPointer(loc.position, 2, gl.FLOAT, false, 0, 0);

	for (var i = 0; i < sphere_count; i++) {
		gl.uniform1i(loc["image[" + i + "]"], i);
	}

	function load_images_on_complete() {
		windowOnResize();
		window.addEventListener("resize", windowOnResize);
		window.addEventListener("keydown", windowOnKeyDown);

		requestAnimationFrame(draw);
	}

	if (fs.src === "fsr.glsl") {
		load_images_on_complete();
	} else {
		var sources = [
			"earth.jpg", // http://flatplanet.sourceforge.net/maps/
			"moon.jpg", // http://flatplanet.sourceforge.net/maps/
			"sun.png" // http://www.celestiamotherlode.net/
		];
		load_images(sources, load_images_on_result, load_images_on_complete);
	}
}

apply_preset();
create_info_block();
load("post", [vs, fs, fse_prefix, fse, fse_suffix], 5000, load_shaders_on_result, load_shaders_on_complete);

function draw() {
	var width = gl.canvas.clientWidth;
	var height = gl.canvas.clientHeight;
	if (gl.canvas.width !== width || gl.canvas.height !== height) {
		gl.canvas.width = width;
		gl.canvas.height = height;
	}

	gl.viewport(0, 0, width, height);
	gl.clear(gl.COLOR_BUFFER_BIT);

	camera = new camera_t(camera_size, camera_size_px, width, height);
	camera.depth *= zoom;
	camera.prepare();

	gl.uniform1f(loc.universe_R, universe_R);

	gl.uniform4fv(loc.camera_base, camera.base.coord);
	gl.uniform4fv(loc.camera_dx, camera.dx.coord);
	gl.uniform4fv(loc.camera_dy, camera.dy.coord);

	//--------------------------------------------------------------------------

	var camera_a1_rad = camera_a1 * 2 * Math.PI / 360;

	var earth_a0_rad = earth_a0 * 2 * Math.PI / 360;
	var earth_a1_rad = earth_a1 * 2 * Math.PI / 360;

	var orbit_a0_rad = orbit_a0 * 2 * Math.PI / 360;
	var orbit_a1_rad = orbit_a1 * 2 * Math.PI / 360;

	//--------------------------------------------------------------------------

	var earth_center = new vec4();
	earth_center.coord[1] = -distance * Math.sin(camera_a1_rad);
	earth_center.coord[2] = -distance * Math.cos(camera_a1_rad);

	var earth_basis = std_basis();
	rotate_basis(earth_basis, 0, 1, earth_a0_rad);
	rotate_basis(earth_basis, 2, 1, earth_a1_rad);

	var orbit_basis = std_basis();
	rotate_basis(orbit_basis, 0, 1, orbit_a0_rad);
	rotate_basis(orbit_basis, 2, 1, orbit_a1_rad);

	var earth_R_angular = 0;

	if (universe_R > 0) {
		var a = to_spherical_4d(earth_center, std_basis(), universe_R);
		earth_center = to_4d(a, universe_R);

		rotate_basis(earth_basis, 3, 2, -a.coord[2]);
		rotate_basis(orbit_basis, 3, 2, -a.coord[2]);

		earth_R_angular = earth_R / universe_R;
	}

	rotate_basis(earth_basis, 2, 1, camera_a1_rad);
	rotate_basis(orbit_basis, 2, 1, camera_a1_rad);

	gl.uniform4fv(loc["sphere[0].center"], earth_center.coord);
	gl.uniform4fv(loc["sphere[0].basis.ex"], earth_basis.ex.coord);
	gl.uniform4fv(loc["sphere[0].basis.ey"], earth_basis.ey.coord);
	gl.uniform4fv(loc["sphere[0].basis.ez"], earth_basis.ez.coord);
	gl.uniform1f(loc["sphere[0].R"], earth_R);
	gl.uniform1f(loc["sphere[0].R_angular"], earth_R_angular);

	//--------------------------------------------------------------------------

	var pole = new vec4(0, 0, 0, universe_R);
	var pole_rotated = pole.copy();
	rotate_vector(pole_rotated, 3, 2, -Math.PI / 2);

	//--------------------------------------------------------------------------

	var moon_orbit_R = earth_R + moon_H;
	var moon_a = 2 * Math.PI * moon_t / moon_T;

	var moon_center = get_sat_center(earth_center, orbit_basis, moon_orbit_R, -moon_a, universe_R);

	var moon_basis = std_basis();
	rotate_basis(moon_basis, 2, 1, -moon_a);
	rotate_basis(moon_basis, 0, 1, orbit_a0_rad);
	rotate_basis(moon_basis, 2, 1, orbit_a1_rad);

	var moon_R_angular = 0;

	if (universe_R > 0) {
		var a = Math.acos(moon_center.dot(pole) / (universe_R * universe_R));
		if (moon_center.dot(pole_rotated) < 0) {
			a = 2 * Math.PI - a;
		}
		rotate_basis(moon_basis, 3, 2, -a);

		moon_R_angular = moon_R / universe_R;
	}

	rotate_basis(moon_basis, 2, 1, camera_a1_rad);

	gl.uniform4fv(loc["sphere[1].center"], moon_center.coord);
	gl.uniform4fv(loc["sphere[1].basis.ex"], moon_basis.ex.coord);
	gl.uniform4fv(loc["sphere[1].basis.ey"], moon_basis.ey.coord);
	gl.uniform4fv(loc["sphere[1].basis.ez"], moon_basis.ez.coord);
	gl.uniform1f(loc["sphere[1].R"], moon_R);
	gl.uniform1f(loc["sphere[1].R_angular"], moon_R_angular);

	//--------------------------------------------------------------------------

	var sun_orbit_R = earth_R + sun_H;
	var sun_a = 2 * Math.PI * sun_t / sun_T;

	var sun_center = get_sat_center(earth_center, orbit_basis, sun_orbit_R, -sun_a, universe_R);

	var sun_basis = std_basis();
	rotate_basis(sun_basis, 2, 1, -sun_a);
	rotate_basis(sun_basis, 0, 1, orbit_a0_rad);
	rotate_basis(sun_basis, 2, 1, orbit_a1_rad);

	var sun_R_angular = 0;

	if (universe_R > 0) {
		var a = Math.acos(sun_center.dot(pole) / (universe_R * universe_R));
		if (sun_center.dot(pole_rotated) < 0) {
			a = 2 * Math.PI - a;
		}
		rotate_basis(sun_basis, 3, 2, -a);

		sun_R_angular = sun_R / universe_R;
	}

	rotate_basis(sun_basis, 2, 1, camera_a1_rad);

	gl.uniform4fv(loc["sphere[2].center"], sun_center.coord);
	gl.uniform4fv(loc["sphere[2].basis.ex"], sun_basis.ex.coord);
	gl.uniform4fv(loc["sphere[2].basis.ey"], sun_basis.ey.coord);
	gl.uniform4fv(loc["sphere[2].basis.ez"], sun_basis.ez.coord);
	gl.uniform1f(loc["sphere[2].R"], sun_R);
	gl.uniform1f(loc["sphere[2].R_angular"], sun_R_angular);

	//--------------------------------------------------------------------------

	gl.uniform1i(loc.texture_enabled, texture_enabled);

	gl.uniform1i(loc.light_model, light_model);
	gl.uniform1i(loc.S_enabled, S_enabled);
	gl.uniform1i(loc.WF_enabled, WF_enabled);
	gl.uniform4fv(loc.light_center, sun_center.coord);
	gl.uniform1f(loc.light_power, light_power);
	gl.uniform1f(loc.ambient_c, ambient_c);
	gl.uniform1i(loc.preset, preset);

	gl.drawArrays(gl.TRIANGLE_FAN, 0, 4);

	frame_count++;
	var now = new Date().getTime();
	if (now - fps_ts > 1000) {
		fps_ts = now;
		fps = frame_count;
		frame_count = 0;
	}

	var now = new Date().getTime() / 1000;
	if (start_t === undefined) start_t = now;
	var universe_t = (now - start_t) * motion_direction * motion_speed;
	if (motion_enabled) {
		moon_t = (universe_t + moon_dt) % moon_T;
		sun_t = (universe_t + sun_dt) % sun_T;
	}

	if (info_mode === "all") {
		info.w.textContent = width;
		info.h.textContent = height;
		info.fps.textContent = fps;
		info.universe_L.textContent = universe_L.toFixed(2);
		info.universe_R.textContent = universe_R.toFixed(2);
		info.distance.textContent = distance.toFixed(2);
		info.camera_a1.textContent = camera_a1;
		info["earth_a0 & orbit_a0"].textContent = earth_a0;
		info.earth_a0.textContent = earth_a0;
		info.earth_a1.textContent = earth_a1;
		info.orbit_a0.textContent = orbit_a0;
		info.orbit_a1.textContent = orbit_a1;
		info.earth_R.textContent = earth_R.toFixed(2);
		info.sun_H.textContent = sun_H.toFixed(2);
		info.zoom.textContent = zoom.toFixed(2);
		info.textures.textContent = texture_enabled ? "on" : "off";
		info.universe.textContent = universe_L > 0 ? "3s" : "3d";
		info.light_model.textContent = light_model === 0 ? "none" : light_model == 1 ? "simple" : "real";
		info.S_enabled.textContent = S_enabled ? "yes" : "no";
		info.WF_enabled.textContent = WF_enabled ? "yes" : "no";
		info.light_power.textContent = light_power.toFixed(2);
		info.motion.textContent = motion_enabled ? "on" : "off";
		info.motion_direction.textContent = motion_direction > 0 ? "pos" : "neg";
		info.motion_speed.textContent = motion_speed.toFixed(2);

		var moon_a = moon_t * 360 / moon_T;
		if (moon_a < 0) moon_a += 360;
		info.moon_a.textContent = moon_a.toFixed(2);

		var sun_a = sun_t * 360 / sun_T;
		if (sun_a < 0) sun_a += 360;
		info.sun_a.textContent = sun_a.toFixed(2);
	} else if (info_mode === "d") {
		info.distance.textContent = distance.toFixed(3);
	} else if (info_mode === "a") {
		info.angle.textContent = camera_a1.toFixed(2);
	}

	requestAnimationFrame(draw);
}

function restart_motion() {
	start_t = new Date().getTime() / 1000;
	moon_t = moon_t % moon_T;
	sun_t = sun_t % sun_T;
	moon_dt = moon_t;
	sun_dt = sun_t;
}

function windowOnKeyDown(e) {
	var key = String.fromCharCode(e.keyCode);

	if (e.keyCode === 37) { // Left
		if (e.shiftKey) {
			earth_a0 -= angle_delta;
		} else if (e.ctrlKey) {
			orbit_a0 -= angle_delta;
		} else {
			earth_a0 -= angle_delta;
			orbit_a0 -= angle_delta;
		}
	}
	if (e.keyCode === 39) { // Right
		if (e.shiftKey) {
			earth_a0 += angle_delta;
		} else if (e.ctrlKey) {
			orbit_a0 += angle_delta;
		} else {
			earth_a0 += angle_delta;
			orbit_a0 += angle_delta;
		}
	}
	if (earth_a0 < 0) earth_a0 += 360;
	if (earth_a0 > 360) earth_a0 -= 360;
	if (orbit_a0 < 0) orbit_a0 += 360;
	if (orbit_a0 > 360) orbit_a0 -= 360;

	if (e.keyCode === 38) { // Up
		if (e.shiftKey) {
			earth_a1 += angle_delta;
		} else if (e.ctrlKey) {
			orbit_a1 += angle_delta;
		} else if (e.altKey) {
			moon_t += moon_t_delta;
			restart_motion();
		} else {
			camera_a1 += angle_delta;
		}
	}
	if (e.keyCode === 40) { // Dn
		if (e.shiftKey) {
			earth_a1 -= angle_delta;
		} else if (e.ctrlKey) {
			orbit_a1 -= angle_delta;
		} else if (e.altKey) {
			moon_t -= moon_t_delta;
			restart_motion();
		} else {
			camera_a1 -= angle_delta;
		}
	}
	if (camera_a1 < 0) camera_a1 += 360;
	if (camera_a1 > 360) camera_a1 -= 360;
	if (earth_a1 < 0) earth_a1 += 360;
	if (earth_a1 > 360) earth_a1 -= 360;
	if (orbit_a1 < 0) orbit_a1 += 360;
	if (orbit_a1 > 360) orbit_a1 -= 360;

	if (key === "T") texture_enabled = !texture_enabled;
	if (key === "U") universe_L = universe_L > 0 ? 0 : 100;
	if (key === "L") {
		light_model++;
		if (light_model > 2) light_model = 0;
	}
	if (key === "A") S_enabled = !S_enabled;
	if (key === "F") WF_enabled = !WF_enabled;
	if (e.keyCode === 32) { // Space
		motion_enabled = !motion_enabled;
		restart_motion();
	}
	if (key === "D") {
		motion_direction = -motion_direction;
		restart_motion();
	}
	if (key === "I") {
		if (info_mode === undefined) {
			info_mode = "all";
		} else if (info_mode === "all") {
			info_mode = "d";
		} else if (info_mode === "d") {
			info_mode = "a";
		} else {
			info_mode = undefined;
		}
		create_info_block();
	}

	if (e.keyCode === 33) { // PgUp
		if (e.altKey) {
			sun_t += sun_t_delta;
			restart_motion();
		} else {
			zoom *= zoom_k;
		}
	}
	if (e.keyCode === 34) { // PgDn
		if (e.altKey) {
			sun_t -= sun_t_delta;
			restart_motion();
		} else {
			zoom /= zoom_k;
		}
	}

	if (e.keyCode === 36) { // Home
		if (e.shiftKey) {
			light_power += light_power_delta;
		} else if (e.ctrlKey) {
			sun_H += distance_delta;
		} else if (e.altKey) {
			motion_speed *= motion_speed_k;
			restart_motion();
			e.preventDefault();
		} else {
			earth_R += distance_delta;
		}
	}
	if (e.keyCode === 35) { // End
		if (e.shiftKey) {
			light_power -= light_power_delta;
		} else if (e.ctrlKey) {
			sun_H -= distance_delta;
		} else if (e.altKey) {
			motion_speed /= motion_speed_k;
			restart_motion();
			e.preventDefault();
		} else {
			earth_R -= distance_delta;
		}
	}
	if (earth_R < 0) earth_R = 0;
	if (universe_L > 0 && earth_R > universe_L * 0.49) earth_R = universe_L * 0.49;

	universe_R = universe_L / (2 * Math.PI);
	distance_min = earth_R + 2 * camera_size;
	distance_max = universe_R > 0 ? universe_L - distance_min : 100;

	if (key === "W") {
		if (distance === distance_max) {
			distance = Math.ceil(distance_max / distance_delta - 1) * distance_delta;
		} else {
			distance -= distance_delta;
		}
	}
	if (key === "S") {
		if (distance === distance_min) {
			distance = Math.floor(distance_min / distance_delta + 1) * distance_delta;
		} else {
			distance += distance_delta;
		}
	}
	if (distance < distance_min) distance = distance_min;
	if (distance > distance_max) distance = distance_max;

	if (key === "E") {
		var sun_a = 2 * Math.PI * sun_t / sun_T;
		moon_t = sun_a * moon_T / (2 * Math.PI);
		restart_motion();
	}

	if (key === "1") { // пред. preset
		change_preset(false);
	}
	if (key === "2") { // след. preset
		change_preset(true);
	}
}

function windowOnResize() {
	if (w_const === undefined || h_const === undefined) {
		canvas.width = window.innerWidth;
		canvas.height = window.innerHeight;
	} else {
		canvas.width = w_const;
		canvas.height = h_const;
	}
}
