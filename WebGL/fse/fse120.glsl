	if (preset == 120)
	{
		float angle = da;
		float d = 8. * da;
		float ra = da;
		float ext = 0.45 * da;

		if (near_yzx(data.normal, -M_PI / 2., 4.1 * da, 4. * da))
			res = vec3(0, 0, 1);

		bool crit = inside_xy(data.normal, 0., d);
		if (near_yzx(data.normal, angle, d, ra) && crit)
			res = vec3(1, 1, 0);
		if (near_yzx(data.normal, angle, d, ra) && !crit)
			res = vec3(1, 0.5, 0);

		a = angle - ra - ext;
		for (int i = 0; i < 4; i++)
		{
			float d1 = d;
			float d2 = d;
			if (i == 1 || i == 2)
			{
				d1 = d - ra;
				d2 = d + ra;
			}
			if (great_circle_yz(data.normal, a, 0.5) && near_yzx(data.normal, 0., 0., d1) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
			if (arrow_yzx(data.normal, a, 5. * da, da, arrow_angle))
				res = vec3(1, 0, 0);
			if (i == 0 || i == 1)
			{
				if (great_circle_yz(data.normal, a, 0.5) && !near_yzx(data.normal, 0., 0., d2) && inside_xy(data.normal, 0., M_PI)) res = vec3(1, 0, 1);
				if (arrow_yzx(data.normal, a + M_PI, 5. * da, da, arrow_angle))
					res = vec3(1, 0, 1);
				if (great_circle_yz(data.normal, a, 0.5) && inside_xy(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 1);
				if (arrow_yzx(data.normal, a, 11. * da, -da, arrow_angle))
					res = vec3(1, 0, 1);
			}
			a += 2. * (ra + ext) / 3.;
		}

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
