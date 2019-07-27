	if (preset == 80 || preset == 81)
	{
		float angle = 12. * da;
		float d = 8. * da;
		float ra = 2. * da;
		float ext = 0.775 * da;

		if (near_yzx(data.normal, angle, M_PI - d, ra) && inside_yz(data.normal, 0., angle))
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, angle, M_PI - d, ra) && inside_yz(data.normal, angle, M_PI))
			res = vec3(0, 1, 1);

		if (near_yzx(data.normal, angle, M_PI + d, ra) && inside_yz(data.normal, M_PI + angle, 2. * M_PI))
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, angle, M_PI + d, ra) && inside_yz(data.normal, M_PI, M_PI + angle))
			res = vec3(0, 1, 1);

		a = angle - ra - ext;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xz(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
		if (great_circle_yz(data.normal, a, 0.5) && near_yzx(data.normal, 0., M_PI, d)) res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, 10. * da, da, arrow_angle))
			res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, M_PI / 2. + 6. * da, da, arrow_angle))
			res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, M_PI + 6. * da, da, arrow_angle))
			res = vec3(1, 0, 0);

		a = angle + ra + ext;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xz(data.normal, 0., M_PI)) res = vec3(1, 0, 1);
		if (great_circle_yz(data.normal, a, 0.5) && near_yzx(data.normal, 0., M_PI, d)) res = vec3(1, 0, 1);
		if (arrow_yzx(data.normal, a, 10. * da, da, arrow_angle))
			res = vec3(1, 0, 1);
		if (arrow_yzx(data.normal, a, M_PI / 2. + 6. * da, da, arrow_angle))
			res = vec3(1, 0, 1);
		if (arrow_yzx(data.normal, a, M_PI + 6. * da, da, arrow_angle))
			res = vec3(1, 0, 1);

		if (small_circle_x(data.normal, M_PI / 2., 0.5)) res = vec3(0, 1, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
