function camera_t(camera_size, camera_size_px, width_px, height_px) {
	var self = this;

	self.rightward = new vec4(1, 0, 0);
	self.topward = new vec4(0, 1, 0);
	self.forward = new vec4(0, 0, -1);

	self.width = camera_size * width_px / camera_size_px;
	self.height = camera_size * height_px / camera_size_px;
	self.depth = camera_size;

	self.prepare = function() {
		self.base = self.forward.mul(self.depth)
			.sub(self.rightward.mul(self.width / 2))
			.sub(self.topward.mul(self.height / 2));
		self.dx = self.rightward.mul(self.width / width_px);
		self.dy = self.topward.mul(self.height / height_px);
		self.base = self.base
			.add(self.dx.div(2))
			.add(self.dy.div(2));
	};
}

function to_spherical_3d(v_3d, basis) {
	var res = new vec4();
	var x = v_3d.dot(basis.ex);
	var y = v_3d.dot(basis.ey);
	var z = v_3d.dot(basis.ez);
	res.coord[0] = Math.atan2(y, x);
	res.coord[1] = Math.atan2(Math.sqrt(x * x + y * y), z);
	return res;
}

function to_spherical_4d(v_3d, basis, R) {
	var res = to_spherical_3d(v_3d, basis);
	res.coord[2] = v_3d.length() / R;
	return res;
}

function to_3d(a_3d) {
    var res = new vec4();
    var sin_a0 = Math.sin(a_3d.coord[0]);
    var cos_a0 = Math.cos(a_3d.coord[0]);
    var sin_a1 = Math.sin(a_3d.coord[1]);
    var cos_a1 = Math.cos(a_3d.coord[1]);
    res.coord[0] = sin_a1 * cos_a0;
    res.coord[1] = sin_a1 * sin_a0;
    res.coord[2] = cos_a1;
    return res;
}

function to_4d(a_4d, R) {
	var res = to_3d(a_4d);
	var sin_a2 = Math.sin(a_4d.coord[2]);
	var cos_a2 = Math.cos(a_4d.coord[2]);
	res.coord[0] *= R * sin_a2;
	res.coord[1] *= R * sin_a2;
	res.coord[2] *= R * sin_a2;
	res.coord[3] = R * cos_a2;
	return res;
}

function rotate_vector(v_4d, coord_idx_1, coord_idx_2, a) {
	var cos_a = Math.cos(a);
	var sin_a = Math.sin(a);
	var m = [
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	];
	m[coord_idx_1 * 4 + coord_idx_1] = cos_a;
	m[coord_idx_1 * 4 + coord_idx_2] = -sin_a;
	m[coord_idx_2 * 4 + coord_idx_1] = sin_a;
	m[coord_idx_2 * 4 + coord_idx_2] = cos_a;
	var tmp = new vec4();
	for (var i = 0; i < 4; i++) {
		for (var j = 0; j < 4; j++) {
			tmp.coord[i] += m[i * 4 + j] * v_4d.coord[j];
		}
	}
	v_4d.coord = tmp.coord;
}

function rotate_basis(basis, coord_idx_1, coord_idx_2, a) {
	rotate_vector(basis.ex, coord_idx_1, coord_idx_2, a);
	rotate_vector(basis.ey, coord_idx_1, coord_idx_2, a);
	rotate_vector(basis.ez, coord_idx_1, coord_idx_2, a);
}

function std_basis() {
	return {
		ex: new vec4(1, 0, 0, 0),
		ey: new vec4(0, 1, 0, 0),
		ez: new vec4(0, 0, 1, 0)
	};
}

function copy_basis(basis) {
	return {
		ex: basis.ex.copy(),
		ey: basis.ey.copy(),
		ez: basis.ez.copy()
	};
}

function end_of_arc(center, point, ra, delta, R) {
	if (ra > Math.PI) {
		ra = 2 * Math.PI - ra;
		delta = -delta;
	}
	var a = (Math.PI - ra) / 2;
	var b = a - delta;

	var AB = point.sub(center);
	var DE = R * Math.sin(a);
	var OE = DE / Math.tan(b);
	var AD = AB.length() / 2 + OE;

	var OD = center.add(AB.div(AB.length()).mul(AD));
	var OC = OD.div(OD.length()).mul(R);

	return OC;
}

function get_sat_center(center, basis, orbit_R, sat_a, universe_R) {
	var a_3d = new vec4(Math.PI / 2, sat_a);
	var v_3d = to_3d(a_3d);
	var probe = basis.ex.mul(v_3d.coord[0])
		.add(basis.ey.mul(v_3d.coord[1]))
		.add(basis.ez.mul(v_3d.coord[2]));
	if (universe_R > 0) {
		var probe_length = 0.01;
		probe = center.add(probe.mul(probe_length));

		var probe_R_angular = 2 * Math.asin(probe_length / (2 * universe_R));
		var orbit_R_angular = orbit_R / universe_R;
		var delta = orbit_R_angular - probe_R_angular;

		return end_of_arc(center, probe, probe_R_angular, delta, universe_R);
	} else {
		return center.add(probe.mul(orbit_R));
	}
}