	if (preset == 40)
	{
		a = 0.;
		if (great_circle_xy(data.normal, a, 0.25) && inside_xz(data.normal, 0., 2. * da)) res = vec3(0, 0, 0);

		a = 0.;
		if (great_circle_xz(data.normal, a, 0.25) && inside_xy(data.normal, 0., M_PI / 2.)) res = vec3(0, 0, 0);
		if (great_circle_xz(data.normal, a, 1.0) && inside_xy(data.normal, 0., 2. * da)) res = vec3(0, 1, 0);
		if (great_circle_xz(data.normal, a, 1.0) && inside_xy(data.normal, M_PI / 2. - 2. * da, M_PI / 2.)) res = vec3(1, 0, 0);

		a = 2. * da;
		if (great_circle_xz(data.normal, a, 0.25) && inside_xy(data.normal, 0., M_PI / 2.)) res = vec3(0, 0, 0);
		if (great_circle_xz(data.normal, a, 1.0) && inside_xy(data.normal, 0., 2. * da)) res = vec3(0, 1, 0);
		if (great_circle_xz(data.normal, a, 1.0) && inside_xy(data.normal, M_PI / 2. - 2. * da, M_PI / 2.)) res = vec3(1, 0, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
