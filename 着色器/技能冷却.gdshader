shader_type canvas_item;

// 冷却进度参数，取值范围 0 ~ 1
uniform float cool_down_progress : hint_range(0.0, 1.0);

void fragment() {
    // 将UV原点挪到图片中心，坐标范围 [-0.5, 0.5]
    vec2 center_uv = UV - vec2(0.5);
    
    // 计算当前像素相对于中心点的弧度 atan(y, x) 范围 [-PI, PI]
    float radian = atan(center_uv.y, center_uv.x);
    
    // 旋转角度基准：把起始点改为12点钟竖直向上
    radian += PI / 2.0;
    
    // 将负弧度转正，统一映射到 0 ~ TAU（0~360度）
    if (radian < 0.0) {
        radian += TAU;
    }
    
    // 根据进度算出扇形最大可视弧度
    float max_radian = cool_down_progress * TAU;
    
    // 判断当前像素是否在露出的扇形区域内
    bool inside_show_area = radian <= max_radian;
    
    // 读取上层遮罩贴图本身颜色
    vec4 tex = texture(TEXTURE, UV);
    
    if (inside_show_area) {
        // 扇形内部完全透明，透出下方技能图标
        COLOR.a = 0.0;
    } else {
        // 扇形外部保留遮罩原图，遮挡底层图标
        COLOR = tex;
    }
}