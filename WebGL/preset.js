var presets = [
	0,
	10,
	20,
	30,
	40,
	50,
	60, 61,
	70, 71,
	80, 81,
	90, 91, 92, 93,
	100,
	110,
	120,
	130,
	140,
	150,
	160,
	170, 171, 172,

	1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017,
	1020, 1021, 1022, 1023, 1024, 1025, 1026,
	1030, 1031, 1032, 1033, 1034,
	1040, 1041, 1042, 1043,
	1050, 1051,
	1060, 1061,
	1070,
	1081
];

function change_preset(next) {
	var i = presets.indexOf(preset);
	if (next) {
		if (i === -1 || i === presets.length - 1) i = 0;
		else i++;
	} else {
		if (i === -1 || i === 0) i = presets.length - 1;
		else i--;
	}
	location = location.origin + location.pathname + "?preset=" + presets[i];
}

function apply_preset() {
	if (preset > 0 && preset < 1000) {
		w_const = 800;
		h_const = 600;

		universe_L = 0;
		universe_R = 0;

		earth_a0 = 240;
		earth_a1 = 60;
		zoom = 2;

		fs.src = "fsr.glsl";
		fse.src = "fse/fse" + (preset < 100 ? "0" : "") + (preset - preset % 10) + ".glsl";

		if (preset === 60) {
			earth_a0 = 215;
		}
		if (preset === 61) {
			earth_a0 = 145;
		}

		if (preset === 71) {
			earth_a0 = 120;
		}

		if (preset === 80) {
			earth_a0 = 250;
			earth_a1 = 90;
		}
		if (preset === 81) {
			earth_a0 = 110;
			earth_a1 = 90;
		}

		if (preset === 90) {
			earth_a0 = 215;
		}
		if (preset === 91) {
			earth_a0 = 145;
		}
		if (preset === 92) {
			earth_a0 = 35;
			earth_a1 = 120;
		}
		if (preset === 93) {
			earth_a0 = 325;
			earth_a1 = 120;
		}

		if (preset === 110) {
			earth_a0 = 270;
			earth_a1 = 90;
		}

		if (preset === 120) {
			earth_a0 = 270;
			earth_a1 = 90;
		}

		if (preset === 130 || preset === 140) {
			earth_a0 = 320;
			earth_a1 = 90;
		}

		if (preset === 150) {
			w_const = 600;
			distance = 100;
			earth_a0 = 240;
			earth_a1 = 90;
			zoom = 40.82;
		}

		if (preset === 160) {
			w_const = 600;
			distance = 100;
			earth_a0 = 180;
			earth_a1 = 90;
			zoom = 40.82;

			light_model = 0;
		}

		if (preset === 170 || preset === 171 || preset === 172) {
			earth_a0 = 120;
		}

		info_mode = undefined;

		motion_enabled = false;
	}
	if
	(
		preset === 1010 || preset === 1011 || preset === 1012 || preset === 1013 ||
		preset === 1014 || preset === 1015 || preset === 1016 || preset === 1017
	) {
		w_const = 600;
		h_const = 600;

		camera_size_px = 600;

		earth_R = 2.5;

		distance = 6.25;
		if (preset === 1012 || preset === 1013) {
			earth_a1 = 180;
		}
		if (preset === 1014 || preset === 1015) {
			earth_a1 = 45;
		}
		if (preset === 1016 || preset === 1017) {
			earth_a1 = 135;
		}

		texture_enabled = preset === 1011 || preset === 1013 || preset === 1015 || preset === 1017;

		info_mode = undefined;

		// прячем Солнце и Луну внутрь Земли
		moon_H = -earth_R;
		sun_H = -earth_R;

		motion_enabled = false;
	}
	if
	(
		preset === 1020 || preset === 1021 || preset === 1022 || preset === 1023 || preset === 1024 ||
		preset === 1025 || preset === 1026
	) {
		w_const = preset === 1020 ? 150 : 600;
		h_const = preset === 1020 ? 150 : 600;

		camera_size_px = preset === 1020 ? 150 : 600;

		if (preset !== 1025 && preset !== 1026) {
			earth_R = 2.5;
		}

		if (preset === 1020) {
			distance = 3.125; // 3.125 -> 97.480
		}
		if (preset === 1021 || preset === 1022 || preset === 1023 || preset === 1024) {
			distance = 47;
		}
		if (preset === 1025) {
			distance = 24.5;
		}
		if (preset === 1026) {
			distance = 24.75;
		}

		if (preset === 1023 || preset === 1024) {
			camera_a1 = 180;
			earth_a0 = 180;
		}

		if (preset === 1020) {
			zoom = 1;
		}
		if (preset === 1021 || preset === 1022 || preset === 1023 || preset === 1024) {
			zoom = 0.32;
		}
		if (preset === 1025 || preset === 1026) {
			zoom = 7.45;
		}

		distance_delta = 3.125;

		texture_enabled = preset === 1022 || preset === 1024;

		info_mode = "d";

		// прячем Солнце и Луну внутрь Земли
		moon_H = -earth_R;
		sun_H = -earth_R;

		motion_enabled = false;
	}
	if (preset === 1030 || preset === 1031 || preset === 1032 || preset === 1033 || preset === 1034) {
		w_const = preset === 1030 ? 150 : preset === 1033 || preset === 1034 ? 600 : 800;
		h_const = preset === 1030 ? 150 : 600;

		camera_size_px = preset === 1030 ? 150 : 600;

		earth_R = 2.5;

		distance = 2.52;
		if (preset === 1030) {
			zoom = 1;
		}
		if (preset === 1033 || preset === 1034) {
			zoom = 0.32;
		}
		if (preset === 1031 || preset === 1032) {
			zoom = 0.055;
		}

		if (preset === 1030) {
			// camera_a1: 0 -> 348.75
		}
		if (preset === 1031 || preset === 1032) {
			camera_a1 = 180;
		}
		if (preset === 1033 || preset === 1034) {
			camera_a1 = 135;
		}

		angle_delta = 11.25;

		texture_enabled = preset === 1032 || preset === 1034;

		info_mode = preset === 1030 ? "a" : undefined;

		// прячем Солнце и Луну внутрь Земли
		moon_H = -earth_R;
		sun_H = -earth_R;

		motion_enabled = false;
	}
	if (preset === 1040 || preset === 1041 || preset === 1042 || preset === 1043) {
		w_const = 600;
		h_const = 600;

		camera_size_px = 600;

		earth_R = 2.5;

		distance = 6.25;
		if (preset === 1042 || preset === 1043) {
			camera_a1 = 180;
			earth_a0 = 180;
		}

		texture_enabled = preset === 1041 || preset === 1043;

		info_mode = undefined;

		// прячем Солнце и Луну внутрь Земли
		moon_H = -earth_R;
		sun_H = -earth_R;

		motion_enabled = false;
	}
	if (preset === 1050 || preset === 1060 || preset === 1070 || preset === 1051 || preset === 1061) {
		w_const = preset === 1051 || preset === 1061 ? 800 : 640;
		h_const = preset === 1051 || preset === 1061 ? 600 : 360;

		distance = 5;
		earth_a0 = 90;
		earth_a1 = 90;
		orbit_a0 = 90;
		zoom = preset === 1051 || preset === 1061 ? 2.25 : 1.625;

		texture_enabled = true;

		info_mode = undefined;

		if (preset === 1050) {
			moon_t = 133 / 360 * moon_T; // 133 -> 0 -> 227
		}
		if (preset === 1051) {
			moon_t = 53 / 360 * moon_T;
		}
		if (preset === 1060 || preset === 1061) {
			moon_H = -earth_R; // прячем Луну внутрь Земли
		}
		if (preset === 1070) {
			moon_t = 0 / 360 * moon_T;
		}

		sun_H = 25;
		if (preset === 1061) {
			sun_t = 236 / 360 * sun_T;
		} else {
			sun_t = 270 / 360 * sun_T; // 1060, 1070: 270 -> 90
		}

		light_model = 2;
		WF_enabled = true;
		light_power = 4;

		motion_enabled = false;
	}
	if (preset === 1080 || preset === 1081) {
		w_const = preset === 1080 ? 1600 : 800;
		h_const = preset === 1080 ? 1200 : 600;
		
		camera_size_px = preset === 1080 ? 1200 : 500;
		camera_size = 0.001;

		distance = 1.002;
		camera_a1 = 120;
		zoom = 0.5;
		
		texture_enabled = true;

		info_mode = undefined;

		if (preset === 1080) {
			moon_H = -earth_R; // прячем Луну внутрь Земли
		}
		if (preset === 1081) {
			moon_t = 333 / 360 * moon_T;
		}
		sun_H = 25;
		sun_t = 88 / 360 * sun_T;

		light_model = 2;
		WF_enabled = true;
		light_power = 4;

		motion_enabled = false;
	}
}
