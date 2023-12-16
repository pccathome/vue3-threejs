precision mediump float;
uniform float time;
uniform float progress;
uniform float uFrequency;
uniform sampler2D matcap;
uniform vec2 mouse;
uniform vec4 resolution;
varying vec2 vUv;
float PI = 3.141592653589793238;



mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

vec2 getmatcap(vec3 eye, vec3 normal) {
	vec3 reflected = reflect(eye, normal);
	float m = 2.8284271247461903 * sqrt( reflected.z+0.95 );
	return reflected.xy / m + 0.5;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sdSphere( vec3 p, float r ) {
  return length(p)-r;
}

float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}



float sdf(vec3 p) {
	vec3 p1 = rotate(p, vec3(1.0), time / 2.0); // cube rotate speed
    float box = smin(sdBox(p1, vec3(0.1)), sdSphere(p, 0.02), 0.3);

    // float realsphere = sdSphere(p1, 0.2);
    float realsphere = sdSphere(p1, uFrequency / 300.0);
    float final = mix(box, realsphere, progress);

    //bobbles
    for(float i=0.0; i<(uFrequency/15.0); i++) {
        float randOffset = rand(vec2(i, 0.0));
        float progr = fract(time / 2.0 + randOffset * 12.0);
        vec3 pos = vec3(sin(randOffset * 2.0 * PI), cos(randOffset * 2.0 * PI), 0.0);
        float gotoCenter = sdSphere(p - pos * progr, 0.1); // 0.1
        final = smin(final, gotoCenter, 0.3);
    }
    return smin(final, realsphere, 1.1); // 0.3 黏度
}

vec3 calcNormal( in vec3 p ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0.0);
    return normalize( vec3(
        sdf(p+h.xyy) - sdf(p-h.xyy),
        sdf(p+h.yxy) - sdf(p-h.yxy),
        sdf(p+h.yyx) - sdf(p-h.yyx)
        ) );
}

void main()
{
    float dist = length(vUv - vec2(0.5));
    vec3 bg = mix(vec3(0.95), vec3(0.0), dist);
    vec3 camPos = vec3(0.0, 0.0, 5.0);
    vec3 ray = normalize(vec3((vUv - vec2(0.5)) * resolution.zw, -1));

    float t = 0.0;
    float tMax = 5.0;
    for(int i = 0; i < 256; ++i) {
        vec3 pos = camPos + t * ray;
        float h = sdf(pos);
        if(h < 0.0001 || t > tMax) break;
        t += h;
    }

    vec3 color = bg;
    if(t < tMax) {
        vec3 pos = camPos + t * ray;
        // color = vec3(1.0);
        vec3 normal = calcNormal(pos);
        // color = normal;
        float diff = dot(vec3(1.0), normal);
		vec2 matcapUV = getmatcap(ray, normal);
        // color = vec3(diff);
		color = texture2D(matcap, matcapUV).rgb;

        float fresnel = pow(1.0 + dot(ray, normal), 6.0); // 6.0 邊緣鋸齒

        color = mix(color, bg, fresnel);
    }


    gl_FragColor = vec4(color, 1.0);
}