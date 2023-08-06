varying vec2 vUv;
varying vec3 vPosition;

varying vec3 worldNormal;
varying vec3 eyeVector;

void main()
{
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;

    gl_Position = projectedPosition;

    worldNormal = normalize(modelMatrix * vec4(normal, 0.0)).xyz;
    eyeVector =  normalize(modelPosition.xyz - cameraPosition);

}