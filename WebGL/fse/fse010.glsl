	if (preset == 10)
	{
		const int m = 9;

		a = -4. * da;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_xy(data.normal, a, i == 4 ? 1.0 : 0.5) && inside_xz(data.normal, -4. * da, 4. * da))
				res = i == 4 ? vec3(0, 1, 0) : vec3(1, 0, 0);
			a += da;
		}

		a = -4. * da;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_xz(data.normal, a, i == 4 ? 1.0 : 0.5) && inside_xy(data.normal, -4. * da, 4. * da))
				res = i == 4 ? vec3(1, 0, 0) : vec3(0, 1, 0);
			a += da;
		}

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);

		if (arrow_yzx(data.normal, 0., 4. * da, da, arrow_angle))
			res = vec3(1, 0, 0);

		if (arrow_yzx(data.normal, M_PI / 2., 4. * da, da, arrow_angle))
			res = vec3(0, 1, 0);
	}
