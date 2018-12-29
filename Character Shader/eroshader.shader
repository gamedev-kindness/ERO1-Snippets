shader_type spatial;
render_mode shadows_disabled, ambient_light_disabled;
uniform float rim = 0.15;
uniform float rim_tint = 0.75;
uniform sampler2D albedo : hint_albedo;
uniform float specular;
uniform float roughness = 1.0;
uniform bool disable_lighting = false;

uniform vec4 shadow_color : hint_color;

float saturate(float x)
{
  return max(0, min(1, x));
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}


float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float and(float a, float b) {
  return a * b;
}

void light() {
	if (disable_lighting) {
		DIFFUSE_LIGHT += ALBEDO;
		return;
	}
	
	float NdotL = dot(LIGHT,NORMAL);
	float NdotV = dot(NORMAL, VIEW);
	vec3 tint = vec3(0.0);
	//tint = vec3(saturate((floor(NdotL * 2.0))));
	
	float transitionSmoothMin = 0.49;
	float transitionSmoothMax = 0.51;
	
	tint += mix(shadow_color.rgb, vec3(1.0), 0.0) * when_lt(NdotL, transitionSmoothMin);
	tint += mix(shadow_color.rgb, vec3(1.0), (NdotL - transitionSmoothMin)/ (transitionSmoothMax-transitionSmoothMin)) * and(when_gt(NdotL, transitionSmoothMin), when_lt(NdotL, transitionSmoothMax));
	tint += vec3(1.0) * when_gt(NdotL, transitionSmoothMax);
	
	
	

	float cNdotV = max(NdotV, 0.0);
	float diffuse_brdf_NL = smoothstep(-ROUGHNESS,max(ROUGHNESS,0.01), 1.0);
	DIFFUSE_LIGHT += 0.8*tint*ATTENUATION*ALBEDO*diffuse_brdf_NL*(LIGHT_COLOR*0.3);
	
	// rim
	float rim_light = pow(max(0.0,1.0-cNdotV), max(0.0,(1.0-0.7)*16.0));
	DIFFUSE_LIGHT += rim_light * rim * mix(vec3(1.0),ALBEDO,rim_tint) * LIGHT_COLOR;
	
	// Specular stuff
	vec3 R = normalize(-reflect(LIGHT,NORMAL));
	float RdotV = dot(R,VIEW);
	float mid = 1.0-ROUGHNESS;
	mid*=mid;
	float intensity = smoothstep(mid-ROUGHNESS*0.5, mid+ROUGHNESS*0.5, RdotV) * mid;
	DIFFUSE_LIGHT += LIGHT_COLOR * intensity * specular * ATTENUATION; // write to diffuse_light, as in toon shading you generally want no reflection
}
void fragment() {
	ROUGHNESS = roughness;
	vec4 albedo_tex = texture(albedo,UV).rgba;
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}
