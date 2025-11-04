//矩形遮罩内显示着色器
shader_type canvas_item;
uniform vec4 u_rects[32]; // 最多支持32个矩形，可根据需求调整
uniform int u_rect_count; // 实际矩形数量
uniform vec2 u_container_size;// 新增：传入容器节点的尺寸（用于UV转像素坐标）
void fragment() {
    vec2 uv = UV * u_container_size; // UV范围是[0,1]，乘以尺寸得到像素位置
    bool in_mask = false;

    // 新增：如果矩形数量为0，则默认全部显示
    if (u_rect_count == 0) {
        in_mask = true;
    } else {
        // 检查当前像素是否在任意一个遮罩矩形内
        for (int i = 0; i < u_rect_count; i++) {
            vec4 rect = u_rects[i];
            float x = rect.x;
            float y = rect.y;
            float w = rect.z;
            float h = rect.w;
            // 判断是否在矩形内（x <= uv.x <= x+w 且 y <= uv.y <= y+h）
            if (uv.x >= x && uv.x <= x + w && uv.y >= y && uv.y <= y + h) {
                in_mask = true;
                break; // 只要在一个矩形内就生效
            }
        }
    }
    vec4 color = texture(TEXTURE, UV);// 采样原图颜色
    color.a = in_mask ? color.a : 0.0;// 不在遮罩内则透明度设为0（隐藏）
    COLOR = color;
}