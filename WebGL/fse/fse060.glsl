	if (preset == 60 || preset == 61)
	{
		float angle = 12. * da;
		float d = 8. * da;
		float ra = 2. * da;
		float a2 = preset == 60 ?  M_PI / 2. - 4. * da :  M_PI / 2. + 4. * da;

		if (near_yzx(data.normal, angle, d, ra))
			res = vec3(0, 0, 1);

		if (near_yzx(data.normal, angle, M_PI / 2., ra))
			res = vec3(0, 0, 1);

		if (near_yzx(data.normal, angle, M_PI - d, ra))
			res = vec3(0, 0, 1);

		a = angle - ra;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, a2, da, arrow_angle))
			res = vec3(1, 0, 0);

		a = angle + ra;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, a2, da, arrow_angle))
			res = vec3(1, 0, 0);

		if (small_circle_x(data.normal, M_PI / 2., 0.5)) res = vec3(0, 1, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
