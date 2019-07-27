	if (preset == 20)
	{
		const int m = 16;

		a = 0.;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_xy(data.normal, a, i == 0 ? 1.0 : 0.5) && inside_xz(data.normal, 0., M_PI / 2.))
				res = i == 0 ? vec3(0, 1, 0) : vec3(1, 0, 0);
			a += da;
		}

		a = 0.;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_xz(data.normal, a, i == 0 ? 1.0 : 0.5) && inside_xy(data.normal, 0., M_PI / 2.))
				res = i == 0 ? vec3(1, 0, 0) : vec3(0, 1, 0);
			a += da;
		}

		a = M_PI / 2.;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_xy(data.normal, a, 0.5) && inside_yz(data.normal, float(i) * da, float(i + 1) * da)) res = mod(i, 2) == 0 ? vec3(1, 0, 0) : vec3(0, 1, 0);
		}

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);

		if (near_yzx(data.normal, M_PI / 4., M_PI / 2., pt_size))
			res = vec3(0, 0, 0);
	}
