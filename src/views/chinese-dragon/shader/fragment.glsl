precision mediump float;
uniform float time;
uniform float progress;
uniform float uFrequency;
uniform sampler2D matcap;
uniform vec2 mouse;
uniform vec4 resolution;
varying vec2 vUv;
float PI = 3.141592653589793238;





void main()
{
    vec2 uv = vUv;
    gl_FragColor = vec4(1.0, 1.0, 1.0, 0.5);
}