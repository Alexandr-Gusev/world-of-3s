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
//------------------------------------------------------------------------------
/*
проверка того что точка n принадлежит большой окружности - пересечению сферы и
плоскости с нормалью v (в координатах базиса сферы)
*/
bool great_circle(vec4 n, vec4 v, float w)
{
	v = sphere[0].basis.ex * v.x + sphere[0].basis.ey * v.y + sphere[0].basis.ez * v.z;
	return abs(acos(dot(n, v)) - M_PI / 2.) < 0.008 * w;
}
/*
секущая плоскость получена вращением от оси x к оси y
*/
bool great_circle_xy(vec4 n, float a, float w)
{
	a += M_PI / 2.;
	return great_circle(n, vec4(cos(a), sin(a), 0, 0), w);
}
bool great_circle_yz(vec4 n, float a, float w)
{
	a += M_PI / 2.;
	return great_circle(n, vec4(0, cos(a), sin(a), 0), w);
}
bool great_circle_xz(vec4 n, float a, float w)
{
	a += M_PI / 2.;
	return great_circle(n, vec4(cos(a), 0, sin(a), 0), w);
}
/*
проверка того что точка n лежит между двумя плоскостями с нормалями v1 v2
(в координатах базиса сферы)
*/
bool inside(vec4 n, vec4 v1, vec4 v2)
{
	v1 = sphere[0].basis.ex * v1.x + sphere[0].basis.ey * v1.y + sphere[0].basis.ez * v1.z;
	v2 = sphere[0].basis.ex * v2.x + sphere[0].basis.ey * v2.y + sphere[0].basis.ez * v2.z;
	return dot(n, v1) > 0. && dot(n, v2) > 0.;
}
/*
плоскости получены вращением от оси x к оси y
*/
bool inside_xy(vec4 n, float a1, float a2)
{
	a1 += M_PI / 2.;
	a2 += M_PI / 2.;
	return inside(n, vec4(cos(a1), sin(a1), 0, 0), -vec4(cos(a2), sin(a2), 0, 0));
}
bool inside_yz(vec4 n, float a1, float a2)
{
	a1 += M_PI / 2.;
	a2 += M_PI / 2.;
	return inside(n, vec4(0, cos(a1), sin(a1), 0), -vec4(0, cos(a2), sin(a2), 0));
}
bool inside_xz(vec4 n, float a1, float a2)
{
	a1 += M_PI / 2.;
	a2 += M_PI / 2.;
	return inside(n, vec4(cos(a1), 0, sin(a1), 0), -vec4(cos(a2), 0, sin(a2), 0));
}
/*
проверка того что точка n лежит на угловом расстоянии da от вектора
полученого по сферическим координатам в базисе yzx вместо xyz
*/
bool near_yzx(vec4 n, float a0, float a1, float da)
{
	vec4 v = to_3d(vec4(a0, a1, 0, 0));
	v = sphere[0].basis.ey * v.x + sphere[0].basis.ez * v.y + sphere[0].basis.ex * v.z;
	return dot(n, v) > cos(da);
}
/*
проверка того что точка n принадлежит малой окружности лежащей на расстоянии a
от вектора v
*/
bool small_circle(vec4 n, vec4 v, float a, float w)
{
	return abs(acos(dot(n, v)) - a) < 0.008 * w;
}
/*
вектор v равен ex
*/
bool small_circle_x(vec4 n, float a, float w)
{
	return small_circle(n, sphere[0].basis.ex, a, w);
}
bool small_circle_y(vec4 n, float a, float w)
{
	return small_circle(n, sphere[0].basis.ey, a, w);
}
bool small_circle_z(vec4 n, float a, float w)
{
	return small_circle(n, sphere[0].basis.ez, a, w);
}
/*
стрелка с острым углом angle на поверхности сферы с началом (a0, a1) и концом (a0, a1 + da)
по сферическим координатам в базисе yzx вместо xyz -
стрелка направленная по геодезической линии от полюса/к полюсу (0, 1, 0) при положительных/отрицательных da
указывающая на точку (a0, a1 + da)
*/
bool arrow_yzx(vec4 n, float a0, float a1, float da, float angle)
{
	vec4 v1 = to_3d(vec4(a0, a1, 0, 0));
	v1 = sphere[0].basis.ey * v1.x + sphere[0].basis.ez * v1.y + sphere[0].basis.ex * v1.z;
	vec4 v2 = to_3d(vec4(a0, a1 + da, 0, 0));
	v2 = sphere[0].basis.ey * v2.x + sphere[0].basis.ez * v2.y + sphere[0].basis.ex * v2.z;
	vec4 v = normalize(v1 - v2);
	vec4 p = n - v2;
	float len = length(p);
	p = normalize(p);
	float cosine = dot(p, v);
	return cosine > cos(angle) && cosine * len < abs(da);
}
//------------------------------------------------------------------------------
vec3 fig_trace(trace_data_t data);
//------------------------------------------------------------------------------
vec3 scene_trace(vec4 direction)
{
	vec3 res = bg;
	trace_data_t data = sphere_trace(sphere[0], direction);
	if (data.found)
	{
		res = fig_trace(data);
		if (light_model != 0)
		{
			res *= dot(-data.ray, data.normal);
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
