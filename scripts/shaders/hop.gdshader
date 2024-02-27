shader_type canvas_item;
uniform vec2 direction = vec2(1.0);
vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment()
{
	//vec2 translate = UV + vec2(0.0, abs(cos(TIME * 2.0)) - 0.25) * 0.5;
	vec2 rotated_uv = rotate(UV, vec2(0.5, 1.0), 1.5 + sin(TIME * 4.0) / 8.0);
	//vec2 shadow_uv = translate + direction / 5.0;
	//vec4 sprite = texture(TEXTURE, translate);
	//vec4 sprite_shadow = texture(TEXTURE, shadow_uv);
	//vec4 shadow = vec4(vec3(sprite_shadow.a * 0.0), sprite_shadow.a);
	//COLOR.rgb = mix(shadow.rgb, sprite.rgb, 1.0);
	//COLOR.a = shadow.a * 0.5 + sprite.a;
	COLOR = texture(TEXTURE, rotated_uv);
}