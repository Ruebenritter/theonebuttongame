shader_type canvas_item;

uniform sampler2D mask;
uniform float progress : hint_range(0, 1) = 0.5;
uniform bool reverse = false;

void fragment() {
	COLOR = vec4(0, 0, 0, 0);

	vec2 muv = UV;

	float value = texture(mask, muv).r;
	if (value <= progress)
	{
		if (reverse)
		{
			value = 1.0;
		}
		else
		{
			value = 0.0;
		}
	}
	else
	{
		if (reverse)
		{
			value = 0.0;
		}
		else
		{
			value = 1.0;
		}
	}

	COLOR.a = value;
}
