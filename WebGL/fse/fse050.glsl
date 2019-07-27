	if (preset == 50)
	{
		float angle = 12. * da;
		float d = 8. * da;

		const int m = 32;

		a = 0.;
		for (int i = 0; i < m; i++)
		{
			if (great_circle_yz(data.normal, a, 0.5)) res = vec3(1, 0, 0);
			a += da;
		}

		a = angle;
		if (great_circle_yz(data.normal, a, 1.0) && near_yzx(data.normal, 0., 0., d) && inside_xy(data.normal, 0., M_PI))
			res = vec3(1, 0, 0);

		a = 0.;
		for (int i = 0; i < m; i++)
		{
			if (small_circle_x(data.normal, a, 0.5)) res = vec3(0, 1, 0);
			a += da;
		}

		a = 0.;
		if (great_circle_yz(data.normal, a, 1.0) && inside_xy(data.normal, 0., 4. * da)) res = vec3(1, 0, 0);

		if (all(equal(res, vec3(1, 1, 1))) && near_yzx(data.normal, 0., 0., 3. * da) && inside_yz(data.normal, 0., angle))
			res = vec3(1., 0.5, 0.5);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);

		if (near_yzx(data.normal, angle, d, pt_size))
			res = vec3(0, 0, 0);

		if (arrow_yzx(data.normal, 0., 4. * da, da, arrow_angle))
			res = vec3(1, 0, 0);
	}
