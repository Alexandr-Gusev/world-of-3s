	if (preset == 170 || preset == 171 || preset == 172)
	{
		float ra = 2. * da;

		int m = preset == 171 ? 9 : preset == 172 ? 17 : 5;

		bool crit = preset == 171 ? near_yzx(data.normal, 0., M_PI, ra) : preset == 172 ? false : near_yzx(data.normal, 0., M_PI, 2.6 * ra);

		a = preset == 171 ? -8. * da : preset == 172 ? -M_PI / 2. : -4. * da;
		for (int i = 0; i < 100; i++)
		{
			if (i >= m) break;
			if (preset != 172 || (i != 0 && i != 16))
			{
				if (great_circle_yz(data.normal, a, 0.5)) res = vec3(1, 0, 1);
				if (arrow_yzx(data.normal, a + M_PI, M_PI - 4. * da, da, arrow_angle))
					res = vec3(1, 0, 1);
			}
			bool crit2 = preset == 172 && (i == 0 || i == 16) ? true : inside_yz(data.normal, -M_PI / 2., M_PI / 2.);
			if (great_circle_yz(data.normal, a, 0.5) && !crit && crit2) res = vec3(1, 0, 0);
			if (arrow_yzx(data.normal, a, 3. * M_PI / 4., da, arrow_angle))
				res = vec3(1, 0, 0);
			a += 2. * da;
		}

		float ext = preset == 171 ? -(ra + 0.8 * da) : preset == 172 ? -ra : -2.7 * ra;

		crit = preset == 171 ? near_yzx(data.normal, 0., M_PI, ra) : preset == 170 ? near_yzx(data.normal, 0., M_PI, 2.6 * ra) : false;
		if (near_yzx(data.normal, 0., M_PI + ext, ra) && !crit)
			res = vec3(0, 0, 1);
		if (near_yzx(data.normal, 0., M_PI + ext, ra) && crit)
			res = vec3(0, 1, 1);

		if (small_circle_x(data.normal, M_PI / 2., 0.5)) res = vec3(0, 1, 0);

		if (near_yzx(data.normal, 0., 0., pt_size))
			res = vec3(0, 0, 0);

		if (preset == 172 && near_yzx(data.normal, 0., M_PI, pt_size))
			res = vec3(0, 1, 1);
	}
