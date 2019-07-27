	if (preset == 100)
	{
		float angle = 12. * da;
		float d = 8. * da;
		float ra = 2. * da;
		float ext = 0.775 * da;

		bool crit = near_yzx(data.normal, 0., 0., d);
		if (near_yzx(data.normal, angle, d, ra) && crit)
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, angle, d, ra) && !crit)
			res = vec3(0, 1, 1);

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
			if (great_circle_yz(data.normal, a, 0.5) && near_yzx(data.normal, 0., 0., d1) && inside_xz(data.normal, 0., M_PI)) res = vec3(1, 0, 0);
			if (arrow_yzx(data.normal, a, 4. * da, da, arrow_angle))
				res = vec3(1, 0, 0);
			if (great_circle_yz(data.normal, a, 0.5) && inside_xz(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a + M_PI, 4. * da, da, arrow_angle))
				res = vec3(1, 0, 1);
			if (great_circle_yz(data.normal, a, 0.5) && !near_yzx(data.normal, 0., 0., d2) && inside_xz(data.normal, 0., M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a, 12. * da, -da, arrow_angle))
				res = vec3(1, 0, 1);
			a += 2. * (ra + ext) / 3.;
		}

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
