
varying vec2 vUv;
varying vec3 vPosition;
uniform float time;
uniform sampler2D positionTexture;
float PI = 3.141592653589793238;


void main() {
    vUv = uv;
    // vec3 pos = texture(positionTexture, reference).xyz;
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);

    gl_PointSize = 2.5 * (1.0 / - mvPosition.z);
    gl_Position = projectionMatrix * mvPosition;
}