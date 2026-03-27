shader_type canvas_item; // 着色器类型：画布项（适用于2D精灵/UI）

// 受击变白的过渡百分比（范围0.0~1.0，步长0.1）
uniform float percent : hint_range(0.0, 1.0, 0.1);

// 自定义白色颜色（新增：可在编辑器里调整白色的色调和透明度）
uniform vec4 hit_color : source_color = vec4(1.0);

void fragment() {
    // 采样原纹理的颜色（包含透明度）
    vec4 original_color = texture(TEXTURE, UV);
    
    // 构建受击颜色：保持原纹理的透明度，颜色部分使用自定义的hit_color
    vec4 hit_effect_color = vec4(hit_color.rgb, original_color.a);
    
    // 混合原颜色和受击颜色：percent=0时显示原颜色，percent=1时完全显示受击颜色
    COLOR = mix(original_color, hit_effect_color, percent);
}