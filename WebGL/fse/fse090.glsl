	if (preset == 90 || preset == 91 || preset == 92 || preset == 93)
	{
		float angle = 12. * da;
		float d = 8. * da;
		float ra = 2. * da;
		float a2 =
			preset == 90 ? M_PI / 2. - 4. * da :
			preset == 91 ? M_PI / 2. + 4. * da :
			preset == 92 ? 3. * M_PI / 2. - 4. * da :
			3. * M_PI / 2. + 4. * da;

		if (preset == 92 || preset == 93)
		{
			float a3 = preset == 90 || preset == 91 ? 0. : M_PI;

			if (near_yzx(data.normal, angle, a3 + d, ra))
				res = vec3(0, 0, 1);

			if (near_yzx(data.normal, angle, a3 + M_PI / 2., ra))
				res = vec3(0, 0, 1);

			if (near_yzx(data.normal, angle, a3 + M_PI - d, ra))
				res = vec3(0, 0, 1);
		}

		a = angle - ra;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, a2, da, arrow_angle))
			res = vec3(1, 0, 0);

		a = angle + ra;
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
		if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 0);
		if (arrow_yzx(data.normal, a, a2, da, arrow_angle))
			res = vec3(1, 0, 0);

		if (small_circle_x(data.normal, M_PI / 2., 0.5)) res = vec3(0, 1, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
