	if (preset == 110)
	{
		float angle = -M_PI / 2.;
		float d = 4.1 * da;
		float ra = 4. * da;
		float ext = 11.5 * da;

		if (near_yzx(data.normal, angle, d, ra))
			res = vec3(0, 0, 1);

		a = angle - ra - ext;
		for (int i = 0; i < 8; i++)
		{
			float d2 = 0.;
			if (i == 1 || i == 6)
			{
				d2 = d - 0.3 * da;
			}
			if (i == 2 || i == 5)
			{
				d2 = d + 2.5 * da;
			}
			if (i == 3 || i == 4)
			{
				d2 = d + 3.9 * da;
			}
			if (great_circle_yz(data.normal, a, 0.5) && !near_yzx(data.normal, 0., 0., d2) && inside_xz(data.normal, M_PI, 2. * M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a + M_PI, 4. * da, da, arrow_angle))
				res = vec3(1, 0, 1);
			if (great_circle_yz(data.normal, a, 0.5) && inside_xz(data.normal, 0., M_PI)) res = vec3(1, 0, 1);
			if (arrow_yzx(data.normal, a, 10. * da, -da, arrow_angle))
				res = vec3(1, 0, 1);
			a += 2. * (ra + ext) / 7.;
		}

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);

		if (all(equal(res, vec3(1, 1, 1))) && near_yzx(data.normal, 0., 0., 3. * da) && inside_yz(data.normal, a - 2. * (ra + ext) / 7., angle - ra - ext))
			res = vec3(1., 0.5, 1.);
	}
