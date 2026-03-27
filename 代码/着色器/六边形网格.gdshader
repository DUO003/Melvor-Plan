shader_type canvas_item;

// ========================
// 输入纹理
// ========================
uniform sampler2D from_tex;
uniform sampler2D to_tex;

// ========================
// 过渡控制
// ========================
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// ========================
// 六边形参数
// ========================
uniform float hex_size : hint_range(0.01, 0.5) = 0.08;
uniform float randomness = 0.05;
uniform float edge_softness = 0.01;
uniform float transition_speed = 0.3;

// ========================
// 工具函数
// ========================
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hextile(inout vec2 p) {
    const vec2 s = vec2(1.0, 1.7320508);
    const vec2 hs = s * 0.5;

    vec2 a = mod(p, s) - hs;
    vec2 b = mod(p - hs, s) - hs;

    vec2 c = dot(a, a) < dot(b, b) ? a : b;
    vec2 id = (c - p + hs) / s;

    p = c;
    return floor(id);
}

float hex(vec2 p, float r) {
    p = abs(p);
    return max(p.x * 0.866025 + p.y * 0.5, p.y) - r;
}

// ========================
// 修复版 片段着色器
// ========================
void fragment() {
    vec2 uv = UV;
    // 1. 直接采样两张纹理的 完整RGBA (修复透明通道)
    vec4 from_texel = texture(from_tex, uv);
    vec4 to_texel = texture(to_tex, uv);

    // 2. 默认直接混合，无初始颜色赋值 (修复透明染色)
    vec4 final_color;
    
    if (progress > 0.0) {
        vec2 screen_size = vec2(1.0) / SCREEN_PIXEL_SIZE;       
        vec2 p = uv - 0.5;
        float aspect = screen_size.x / screen_size.y;
        p.x *= aspect * 0.9;
        vec2 hp = p / hex_size;
        vec2 id = hextile(hp);
		
        float delay = (uv.x + uv.y) * 0.5;
        float hex_progress = progress >= 1.0 ? 1.0 : smoothstep(
            delay - transition_speed,
            delay + transition_speed,
            progress * (1.0 + transition_speed)
        );
        hex_progress = clamp(hex_progress, 0.0, 1.0);

        float r = hash(id);
        float t = clamp(hex_progress - r * randomness, 0.0, 1.0);
        float h = hex(hp, t * 0.9);
        float mask = smoothstep(edge_softness, -edge_softness, h);

        // 3. 核心修复：同时混合 RGB + Alpha 四个通道！
        final_color = mix(from_texel, to_texel, mask);
    } else {
        // 进度为0时，直接显示原图
        final_color = from_texel;
    }

    // 4. 删除了 强制跳变的代码！全程平滑过渡
    COLOR = final_color;
}