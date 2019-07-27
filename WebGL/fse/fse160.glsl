	if (preset == 160)
	{
		float d = 6. * da;

		if (near_yzx(data.normal, 0., 0., d))
			res = vec3(0, 0, 1);

		if (small_circle_y(data.normal, M_PI / 2., 20.0)) res = vec3(0.125, 0.125, 0.125);
		if (small_circle_y(data.normal, M_PI / 2., 20.0) && inside_xz(data.normal, 0., d)) res = vec3(1, 0, 0);

		if (great_circle_xz(data.normal, 0., 1.0) && inside_xz(data.normal, -M_PI / 2., M_PI / 2.))
			res = vec3(1, 0, 0);

		if (great_circle_xz(data.normal, d, 1.0) && inside_xz(data.normal, -M_PI / 2., M_PI / 2. + d))
			res = vec3(1, 0, 0);

		if (small_circle_x(data.normal, d, 1.5) && inside_yz(data.normal, 0., M_PI)) res = vec3(1, 0, 0);

		if (all(equal(res, vec3(1, 1, 1))) && near_yzx(data.normal, 0., M_PI / 2., 3. * da) && inside_xz(data.normal, 0., d))
			res = vec3(1., 0.5, 0.5);
	}
