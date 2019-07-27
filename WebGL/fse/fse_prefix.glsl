vec3 fig_trace(trace_data_t data)
{
	vec3 res = vec3(1);
	const int n = 64;
	const float da = 2. * M_PI / float(n);
	const float pt_size = da / 4.;
	const float arrow_angle = M_PI / 12.;
	float a; 
