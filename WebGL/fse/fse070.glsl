	if (preset == 70 || preset == 71)
	{
		float ra = 2. * da;
		float a2 = preset == 70 ? M_PI / 4. : 3. * M_PI / 4.;

		const int m = 32;

		a = 0.;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_yz(data.normal, a, 0.5)) res = vec3(1, 0, 0);
			if (arrow_yzx(data.normal, a, a2, da, arrow_angle))
				res = vec3(1, 0, 0);
			a += 2. * da;
		}

		if (near_yzx(data.normal, 0., M_PI, ra))
			res = vec3(0, 0, 1);

		if (small_circle_x(data.normal, M_PI / 2., 0.5)) res = vec3(0, 1, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);
	}
