	if (preset == 150)
	{
		float angle = M_PI / 2.;
		float d = 6. * da;

		if (near_yzx(data.normal, 0., 0., d))
			res = vec3(0, 0, 1);

		a = angle;
		if (great_circle_yz(data.normal, a, 1.0) && near_yzx(data.normal, 0., 0., d) && inside_xz(data.normal, 0., M_PI))
			res = vec3(1, 0, 0);
	}
