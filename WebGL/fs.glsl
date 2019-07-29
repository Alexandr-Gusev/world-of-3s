//==============================================================================
precision mediump float;
//==============================================================================
struct basis_t
{
	vec4 ex;
	vec4 ey;
	vec4 ez;
};

struct trace_data_t
{
	bool found;

	float distance;

	vec4 ray;
	vec4 point;
	vec4 normal;

	float u, v; // 0 .. 1
};

struct sphere_t
{
	vec4 center;
	basis_t basis;
	float R;
	float R_angular;
};

struct camera_t
{
	vec4 base;
	vec4 dx;
	vec4 dy;
};
//==============================================================================
const float M_PI = 3.14159265358979323846;

const int px_x_count = 3;
const int px_y_count = 3;

const int sphere_count = 3;

const vec3 bg = vec3(0.13, 0.35, 0.49);
//==============================================================================
uniform float universe_R;
uniform camera_t camera;
uniform sphere_t sphere[sphere_count];
uniform bool texture_enabled;
uniform sampler2D image[sphere_count];
uniform int light_model;
uniform bool S_enabled;
uniform bool WF_enabled;
uniform vec4 light_center;
uniform float light_power;
uniform float ambient_c;
uniform int preset;
//==============================================================================
vec4 to_spherical_3d(vec4 v_3d, basis_t basis)
{
	vec4 res;
	float x = dot(v_3d, basis.ex);
	float y = dot(v_3d, basis.ey);
	float z = dot(v_3d, basis.ez);
	res[0] = atan(y, x);
	res[1] = atan(sqrt(x * x + y * y), z);
	return res;
}

vec4 to_spherical_4d(vec4 v_3d, basis_t basis, float R)
{
	vec4 res = to_spherical_3d(v_3d, basis);
	res[2] = length(v_3d) / R;
	return res;
}

vec4 to_3d(vec4 a_3d)
{
    vec4 res;
    float sin_a0 = sin(a_3d[0]);
    float cos_a0 = cos(a_3d[0]);
    float sin_a1 = sin(a_3d[1]);
    float cos_a1 = cos(a_3d[1]);
    res[0] = sin_a1 * cos_a0;
    res[1] = sin_a1 * sin_a0;
    res[2] = cos_a1;
    return res;
}

vec4 to_4d(vec4 a_4d, float R)
{
	vec4 res = to_3d(a_4d);
	float sin_a2 = sin(a_4d[2]);
	float cos_a2 = cos(a_4d[2]);
	res[0] *= R * sin_a2;
	res[1] *= R * sin_a2;
	res[2] *= R * sin_a2;
	res[3] = R * cos_a2;
	return res;
}

basis_t std_basis()
{
	return basis_t(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0)
	);
}

vec4 end_of_arc(vec4 center, vec4 point, float ra, float delta, float R)
{
/*
Точка на продолжении геодезической линии 3-сферы проходящей через две точки.
Пусть
	O - центр 3-сферы
	A - центр 2-сферы принадлежащей 3-сфере
	B - произвольная точка 2-сферы
	C - искомая точка лежащая на продолжении геодезической линии AB на малом угловом расстоянии delta от точки B
	D - точка пересечения прямых AB и OC
	E - точка пересечения прямой проходящей через точку D перпендикулярно прямой AB и прямой проходящей через точку O параллельно прямой AB
	ra - угловой радиус 2-сферы
	a = (PI - ra) / 2
	b = a - delta
Если ra > PI, то следует положить ra = 2 * PI - ra, delta = -delta
Найдем OD
	OD = OA + AB / |AB| * |AD|
где
	|AD| = |AB| / 2 + |OE|
	|OE| = |DE| / tan(b)
	|DE| = R * sin(a)
найдем OC
	OC = OD / |OD| * R
*/
	if (ra > M_PI)
	{
		ra = 2. * M_PI - ra;
		delta = -delta;
	}
	float a = (M_PI - ra) / 2.;
	float b = a - delta;

	vec4 AB = point - center;
	float DE = R * sin(a);
	float OE = DE / tan(b);
	float AD = length(AB) / 2. + OE;

	vec4 OD = center + normalize(AB) * AD;
	vec4 OC = normalize(OD) * R;

	return OC;
}
//------------------------------------------------------------------------------
trace_data_t sphere_trace(sphere_t obj, vec4 direction)
{
	trace_data_t res;
	res.found = false;
	vec4 e;
	if (universe_R == 0.) // 3d
	{
		vec4 oc = -obj.center;
		float b = dot(oc, direction);
		float c = dot(oc, oc) - obj.R * obj.R;
		float D = b * b - c;

		if (D >= 0.)
		{
			float sqrt_D = sqrt(D);

			float t1 = -b - sqrt_D;
			if (t1 > 0.)
			{
				res.found = true;
				res.distance = t1;
			}
			else
			{
				float t2 = -b + sqrt_D;
				if (t2 > 0.)
				{
					res.found = true;
					res.distance = t2;
				}
			}
			if (res.found)
			{
				res.ray = direction;
				res.point = direction * res.distance;
				res.normal = (res.point - obj.center) / obj.R;

				e = res.normal;
			}
		}
	}
	else // 3s
	{
/*
--------------------------------------------------------------------------------
3-сфера с центром в начале координат -
множество точек, радиус-вектор которых имеет длину равную радиусу 3-сферы R
	x0 * x0 + x1 * x1 + x2 * x2 + x3 * x3 = R * R
--------------------------------------------------------------------------------
2-сфера принадлежащая 3-сфере -
множество точек, радиус-вектор которых имеет длину равную радиусу 3-сферы R и
образует с радиус-вектором центра 2-сферы c угол равный угловому радиусу 2-сферы ra
	x0 * c0 + x1 * c1 + x2 * c2 + x3 * c3 = R * R * cos(ra)
где
	ra = r / R
	r - геодезический радиус 2-сферы
--------------------------------------------------------------------------------
Переход от гиперсферических координат (a0, a1, a2) к декартовым (x0, x1, x2, x3)
	x0 = R * sin(a2) * sin(a1) * cos(a0)
	x1 = R * sin(a2) * sin(a1) * sin(a0)
	x2 = R * sin(a2) * cos(a1)
	x3 = R * cos(a2)
где
	a0 меняется от 0 до 2 * PI
	a1 меняется от 0 до PI
	a2 меняется от 0 до PI
--------------------------------------------------------------------------------
Пересечение геодезической линии 3-сферы с 2-сферой принадлежащей 3-сфере.
Пусть имеется геодезическая линия выходящая из полюса 3-сферы (0, 0, 0, R) в направлении определяемом углами a0 и a1 -
эти углы совпадают с углами определяющими направление в трехмерном пространстве в окрестностях полюса 3-сферы (0, 0, 0, R)
	x0 = R * sin(a2) * sin(a1) * cos(a0)
	x1 = R * sin(a2) * sin(a1) * sin(a0)
	x2 = R * sin(a2) * cos(a1)
	x3 = R * cos(a2)
упростив имеем (1)
	x0 = r0 * sin(a2)
	x1 = r1 * sin(a2)
	x2 = r2 * sin(a2)
	x3 = r3 * cos(a2)
где
	r0 = R * sin(a1) * cos(a0)
	r1 = R * sin(a1) * sin(a0)
	r2 = R * cos(a1)
	r3 = R
подставив (1) в уравнение 2-сферы и упростив имеем (2)
	A * sin(a2) + B * cos(a2) = C
где
	A = r0 * c0 + r1 * c1 + r2 * c2
	B = r3 * c3
	C = R * R * cos(ra)
подставив (1) в уравнение 3-сферы и упростив имеем (3)
	D * sin(a2) * sin(a2) + E * cos(a2) * cos(a2) = F
где
	D = r0 * r0 + r1 * r1 + r2 * r2
	E = r3 * r3
	F = R * R
выразив из (2) cos(a2) имеем
	cos(a2) = (C - A * sin(a2)) / B
подставив в (3) cos(a2) имеем
	D * sin(a2) * sin(a2) + E / (B * B) * (C - A * sin(a2)) * (C - A * sin(a2)) = F
упростив имеем
	a * sin(a2) * sin(a2) + b * sin(a2) + c = 0
где
	m = E / (B * B)
	a = m * A * A + D
	b = m * -2 * A * C
	c = m * C * C - F
--------------------------------------------------------------------------------
Условный радиус 2-сферы принадлежащей 3-сфере -
радиус 2-сферы площадь которой равна площади 2-сферы с угловым радиусом ra принадлежащей 3-сфере с радиусом R
	rn = R * sin(ra)
*/
		vec4 a = to_spherical_4d(direction, std_basis(), universe_R);

		float sin_a0 = sin(a[0]);
		float cos_a0 = cos(a[0]);

		float sin_a1 = sin(a[1]);
		float cos_a1 = cos(a[1]);

		float r[4];
		r[0] = universe_R * sin_a1 * cos_a0;
		r[1] = universe_R * sin_a1 * sin_a0;
		r[2] = universe_R * cos_a1;
		r[3] = universe_R;

		float A = r[0] * obj.center[0] + r[1] * obj.center[1] + r[2] * obj.center[2];
		float B = r[3] * obj.center[3];
		float C = universe_R * universe_R * cos(obj.R_angular);

		float E = r[0] * r[0] + r[1] * r[1] + r[2] * r[2];
		float D = r[3] * r[3];
		float F = universe_R * universe_R;

		float eps = 1e-6;

		if (abs(B) > eps)
		{
			float m = E / (B * B);

			float _a = m * A * A + D;
			float _b = m * -2. * A * C;
			float _c = m * C * C - F;

			float _D = _b * _b - 4. * _a * _c;
			if (_D >= 0.)
			{
				if (abs(_a) > eps)
				{
					float sin_a2 = (-_b + sqrt(_D)) / (2. * _a);
					if (abs(sin_a2) > 1.)
					{
						sin_a2 = sin_a2 > 0. ? 1. : -1.;
					}
					float cos_a2 = (C - A * sin_a2) / B;
					if (abs(cos_a2) > 1.)
					{
						cos_a2 = cos_a2 > 0. ? 1. : -1.;
					}
					float a2 = atan(sin_a2, cos_a2);
					if (a2 < 0.)
					{
						a2 += 2. * M_PI;
					}

					res.found = true;
					res.distance = a2;

					sin_a2 = (-_b - sqrt(_D)) / (2. * _a);
					if (abs(sin_a2) > 1.)
					{
						sin_a2 = sin_a2 > 0. ? 1. : -1.;
					}
					cos_a2 = (C - A * sin_a2) / B;
					if (abs(cos_a2) > 1.)
					{
						cos_a2 = cos_a2 > 0. ? 1. : -1.;
					}
					a2 = atan(sin_a2, cos_a2);
					if (a2 < 0.)
					{
						a2 += 2. * M_PI;
					}

					if (!res.found || a2 < res.distance)
					{
						res.found = true;
						res.distance = a2;
					}
				}
				else if (abs(_b) > eps)
				{
					float sin_a2 = -_c / _b;
					if (abs(sin_a2) > 1.)
					{
						sin_a2 = sin_a2 > 0. ? 1. : -1.;
					}
					float cos_a2 = (C - A * sin_a2) / B;
					if (abs(cos_a2) > 1.)
					{
						cos_a2 = cos_a2 > 0. ? 1. : -1.;
					}
					float a2 = atan(sin_a2, cos_a2);
					if (a2 < 0.)
					{
						a2 += 2. * M_PI;
					}

					res.found = true;
					res.distance = a2;
				}
			}
		}
		else if (abs(A) > eps)
		{
			float sin_a2 = C / A;
			if (abs(sin_a2) > 1.)
			{
				sin_a2 = sin_a2 > 0. ? 1. : -1.;
			}
			if (abs(E) > eps)
			{
				float tmp = (F - D * sin_a2 * sin_a2) / E;
				if (tmp > 0.)
				{
					float cos_a2 = sqrt(tmp);
					if (abs(cos_a2) > 1.)
					{
						cos_a2 = cos_a2 > 0. ? 1. : -1.;
					}
					float a2 = atan(sin_a2, cos_a2);
					if (a2 < 0.)
					{
						a2 += 2. * M_PI;
					}

					res.found = true;
					res.distance = a2;

					cos_a2 = -cos_a2;
					a2 = atan(sin_a2, cos_a2);
					if (a2 < 0.)
					{
						a2 += 2. * M_PI;
					}

					if (a2 < res.distance)
					{
						res.distance = a2;
					}
				}
			}
		}
		if (res.found)
		{
			float delta = 0.01;

			float sin_d0 = sin(res.distance);
			float cos_d0 = cos(res.distance);

			float sin_d1 = sin(res.distance + delta);
			float cos_d1 = cos(res.distance + delta);

			res.point[0] = r[0] * sin_d0;
			res.point[1] = r[1] * sin_d0;
			res.point[2] = r[2] * sin_d0;
			res.point[3] = r[3] * cos_d0;

			res.ray[0] = r[0] * sin_d1;
			res.ray[1] = r[1] * sin_d1;
			res.ray[2] = r[2] * sin_d1;
			res.ray[3] = r[3] * cos_d1;

			res.ray -= res.point;
			res.ray /= length(res.ray);

			res.distance *= universe_R;

			vec4 p = end_of_arc(obj.center, res.point, obj.R_angular, delta, universe_R);
			res.normal = normalize(p - res.point);

			p = end_of_arc(obj.center, res.point, obj.R_angular, -obj.R_angular + delta, universe_R);
			e = normalize(p - obj.center);
		}
	}
	if (res.found)
	{
		vec4 a = to_spherical_3d(e, obj.basis);

		if (a[0] < 0.)
		{
			a[0] += 2. * M_PI;
		}
		res.u = a[0] / (2. * M_PI);

		res.v = a[1] / M_PI;
	}
	return res;
}
//------------------------------------------------------------------------------
int mod(int x, int y)
{
	return x - y * (x / y);
}

vec3 binary_texture_color(trace_data_t data, float min, float max, int nu, int nv)
{
	float du = 1. / float(nu);
	float dv = 1. / float(nv);
	int u = int(data.u / du);
	if (u == nu)
	{
		u--;
	}
	int v = int(data.v / dv);
	if (v == nv)
	{
		v--;
	}
	return vec3(mod(mod(u, 2) + mod(v, 2), 2) == 1 ? max : min);
}

vec3 quadrant_texture_color(trace_data_t data)
{
	vec3 colors[8];
	colors[0] = vec3(1, 0, 0);
	colors[1] = vec3(0, 1, 0);
	colors[2] = vec3(0, 0, 1);
	colors[3] = vec3(1, 0.5, 0);
	colors[4] = vec3(0, 1, 1);
	colors[5] = vec3(1, 0, 1);
	colors[6] = vec3(1, 1, 0);
	colors[7] = vec3(1, 1, 1);
	int u = int(data.u / 0.25);
	if (u == 4)
	{
		u--;
	}
	int v = int(data.v / 0.5);
	if (v == 2)
	{
		v--;
	}
	int idx = v * 4 + u;
	for (int i = 0; i < 8; i++)
	{
		if (i == idx)
		{
			return colors[i];
		}
	}
	return vec3(0);
}

vec3 texture_color(int image_idx, float u, float v)
{
	for (int i = 0; i < sphere_count; i++)
	{
		if (i == image_idx)
		{
			return vec3(texture2D(image[i], vec2(u, v)).xyz);
		}
	}
	return vec3(0);
}

bool shaded_point(vec4 point, vec4 normal, vec4 sphere_center)
{
	if (universe_R == 0.) // 3d
	{
		vec4 e = normalize(light_center - point);
		for (int i = 0; i < sphere_count; i++)
		{
			if (all(equal(sphere[i].center, light_center)) || all(equal(sphere[i].center, sphere_center)))
			{
				continue;
			}
			sphere_t tmp = sphere[i];
			tmp.center = tmp.center - point;
			if (sphere_trace(tmp, e).found)
			{
				return true;
			}
		}
	}
	else // 3s
	{
		float delta = 0.01;
		float ra1 = acos(dot(point, light_center) / (universe_R * universe_R));
		vec4 p1 = end_of_arc(point, light_center, ra1, -ra1 + delta, universe_R);
		vec4 e1 = normalize(p1 - point);
		if (dot(e1, normal) < 0.)
		{
			ra1 = 2. * M_PI - ra1;
			e1 = -e1;
		}
		float distance_to_light = ra1 * universe_R;
		for (int i = 0; i < sphere_count; i++)
		{
			if (all(equal(sphere[i].center, light_center)) || all(equal(sphere[i].center, sphere_center)))
			{
				continue;
			}
			sphere_t tmp = sphere[i];
			float ra2 = acos(dot(point, tmp.center) / (universe_R * universe_R));
			vec4 p2 = end_of_arc(point, tmp.center, ra2, -ra2 + delta, universe_R);
			vec4 e2 = normalize(p2 - point);
			if (dot(e2, normal) < 0.)
			{
				ra2 = 2. * M_PI - ra2;
				e2 = -e2;
			}
			float a = acos(dot(e1, e2));
			tmp.center = to_4d(vec4(0, a, ra2, 0), universe_R);
			trace_data_t data = sphere_trace(tmp, vec4(0, 0, 1, 0));
			if (data.found && data.distance < distance_to_light)
			{
				return true;
			}
		}
	}
	return false;
}

vec3 scene_trace(vec4 direction)
{
	vec3 res = vec3(0);
	trace_data_t data;
	data.found = false;
	int image_idx;
	vec4 sphere_center;
	for (int i = 0; i < sphere_count; i++)
	{
		trace_data_t tmp = sphere_trace(sphere[i], direction);
		if (tmp.found && (!data.found || data.distance > tmp.distance))
		{
			data = tmp;
			image_idx = i;
			sphere_center = sphere[i].center;
		}
	}
	if (data.found)
	{
		if (texture_enabled)
		{
			res = texture_color(image_idx, data.u, data.v);
		}
		else
		{
			res = vec3(1);
			res *= binary_texture_color(data, 0.5, 1., 12, 12);
			res *= quadrant_texture_color(data);
		}
		float light_c = 0.;
		if (light_model == 0)
		{
			light_c = 1.;
		}
		else if (light_model == 1)
		{
			light_c = dot(-data.ray, data.normal);
		}
		else if (all(equal(sphere_center, light_center)))
		{
			light_c = 1.;
		}
		else
		{
			if (!shaded_point(data.point, data.normal, sphere_center))
			{
				float cos_a, S_factor;
				if (universe_R == 0.) // 3d
				{
					vec4 ray = data.point - light_center;
					cos_a = dot(-normalize(ray), data.normal);
					S_factor = length(ray);
					S_factor *= S_factor;
				}
				else // 3s
				{
					float delta = 0.01;
					float ra = acos(dot(light_center, data.point) / (universe_R * universe_R));
					vec4 p = end_of_arc(light_center, data.point, ra, delta, universe_R);
					vec4 ray = normalize(p - data.point);
					cos_a = abs(dot(-ray, data.normal));
					S_factor = universe_R * sin(ra);
					S_factor *= S_factor;
				}
				light_c = light_power * cos_a;
				if (S_enabled)
				{
					light_c /= S_factor; // учет влияния площади волнового фронта
				}
				if (WF_enabled)
				{
					light_c = log(light_c); // учет особенностей восприятия (закон Вебера - Фехнера)
				}
			}
			if (light_c < ambient_c)
			{
				light_c = ambient_c;
			}
		}
		res *= light_c;
	}
	else
	{
		if (light_model != 2)
		{
			res = bg;
		}
		else
		{
			// корона
			float delta = 0.01;
			vec4 origin = vec4(0, 0, 0, universe_R);
			float ra = acos(dot(origin, light_center) / (universe_R * universe_R));
			vec4 light_direction = normalize(end_of_arc(origin, light_center, ra, delta - ra, universe_R) - origin);
			float a = acos(dot(direction, light_direction));
			if (a > M_PI / 2.)
			{
				a = M_PI - a;
			}
			float a_max = M_PI / 32.;
			if (a < a_max)
			{
				float c = 1. - a / a_max;
				res = vec3(c * c);
			}
		}
	}
	return res;
}
//==============================================================================
void main()
{
	vec3 res;
	for (int px_x = 0; px_x < px_x_count; px_x++)
	{
		float dx = float(px_x) / float(px_x_count);
		for (int px_y = 0; px_y < px_y_count; px_y++)
		{
			float dy = float(px_y) / float(px_y_count);
			vec4 direction = normalize
			(
				camera.base
				+ camera.dx * (gl_FragCoord.x + dx)
				+ camera.dy * (gl_FragCoord.y + dy)
			);
			res += scene_trace(direction);
		}
	}
	res /= float(px_x_count * px_y_count);
	gl_FragColor = vec4(res, 1);
}
