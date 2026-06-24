#version 330 compatibility

uniform sampler2D colortex5;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferProjection;

in vec2 texcoord;

const int GODRAY_SAMPLES = 24;
const float GODRAY_DECAY = 0.93;
const float GODRAY_DENSITY = 0.4;

/* RENDERTARGETS: 5 */
layout(location = 0) out vec4 color;

void main() {
	vec3 lightViewPos = normalize(shadowLightPosition);
	vec4 lightClipPos = gbufferProjection * vec4(lightViewPos * 100.0, 1.0);
	vec2 lightScreenPos = (lightClipPos.xy / lightClipPos.w) * 0.5 + 0.5;

	vec3 viewDir = vec3(0.0, 0.0, -1.0);
	float lightFacing = dot(lightViewPos, viewDir);
	float edgeFade = smoothstep(-0.1, 0.3, lightFacing);

	if (edgeFade <= 0.0) {
		color = vec4(0.0, 0.0, 0.0, 1.0);
		return;
	}

	vec2 deltaCoord = (texcoord - lightScreenPos) * GODRAY_DENSITY / float(GODRAY_SAMPLES);
	vec2 sampleCoord = texcoord;
	float illuminationDecay = 1.0;
	vec3 result = vec3(0.0);

	for (int i = 0; i < GODRAY_SAMPLES; i++) {
		sampleCoord -= deltaCoord;
		vec3 sampleColor = texture(colortex5, sampleCoord).rgb * illuminationDecay;
		result += sampleColor;
		illuminationDecay *= GODRAY_DECAY;
	}

	color = vec4((result / float(GODRAY_SAMPLES)) * edgeFade, 1.0);
}