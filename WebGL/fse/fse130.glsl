	if (preset == 130)
	{
		float angle = M_PI;
		float d = 12. * da;
		float ra = 4. * da;
		float ext = 0.4 * da;

		bool crit = near_yzx(data.normal, 0., 0., d);
		if (near_yzx(data.normal, angle, d, ra) && crit)
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, angle, d, ra) && !crit)
			res = vec3(0, 1, 1);
		crit = near_yzx(data.normal, 0., 0., d - ra + 0.2 * da);
		if (near_yzx(data.normal, angle, d, ra) && crit)
			res = vec3(0.25, 0.25, 0.25);

		crit = near_yzx(data.normal, 0., 0., d / 2.);
		if (near_yzx(data.normal, angle, d / 2., 0.8 * da) && crit)
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, angle, d / 2., 0.8 * da) && !crit)
			res = vec3(0.25, 0.25, 0.25);

		a = angle - ra - ext;
		for (int i = 0; i < 4; i++)
		{
			float d1 = d;
			float d2 = d;
			float arrow_d = 14. * da;
			if (i == 1 || i == 2)
			{
				d1 = d - ra + 0.2 * da;
				d2 = d + ra - 0.2 * da;
				arrow_d += ra;
			}
			if (great_circle_yz(data.normal, a, 0.5) && near_yzx(data.normal, 0., 0., d1) && inside_xy(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 0);
			if (arrow_yzx(data.normal, a, 4. * da, da, arrow_angle))
				res = vec3(1, 0, 0);
			if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a + M_PI, 2.5 * da, da, arrow_angle))
				res = vec3(1, 0, 1);
			if (great_circle_yz(data.normal, a, 0.5) && !near_yzx(data.normal, 0., 0., d2) && inside_xy(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a, arrow_d, -da, arrow_angle))
				res = vec3(1, 0, 1);
			a += 2. * (ra + ext) / 3.;
		}

		crit = inside_xy(data.normal, 0., M_PI);
		if (near_yzx(data.normal, 0., 0., da) && crit)
			res = vec3(1, 0.5, 0);
		if (near_yzx(data.normal, 0., 0., da) && !crit)
			res = vec3(1, 1, 0);

		float a_b = angle - ra - ext + 2. * (ra + ext) / 3.;
		float a_e = a_b + 2. * (ra + ext) / 3.;
		crit = inside_yz(data.normal, a_b, a_e);
		if (all(equal(res, vec3(1, 1, 1))) && near_yzx(data.normal, 0., 0., d) && !near_yzx(data.normal, 0., 0., d / 2.) && crit)
			res = vec3(0.5, 0.5, 0.5);
	}
