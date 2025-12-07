shader_type canvas_item;
/*
===========================================================================
【着色器核心用途】
适用于Godot 4.5版本的2D怪物死亡消失动画，为Sprite2D节点实现噪声溶解效果：
1. 基于噪声纹理将怪物纹理分割为「正常显示/红色描边/完全隐藏」三个区域
2. 噪声值低的区域优先消失（从噪声图顶点开始渐变消失）
3. 消失边缘生成红色描边，通过两个进度变量独立控制消失和描边效果
4. 可直接附加到怪物的Sprite2D节点，适配2D游戏的怪物死亡视觉表现

【使用前置条件】
1. 需为怪物节点（Sprite2D）挂载此着色器材质
2. 必须分配噪声纹理（noise_texture），推荐使用Godot内置噪声生成器创建（类型：OpenSimplexNoise）
3. 确保怪物纹理的Alpha通道正常（透明区域不影响溶解逻辑）

【参数调试指南（常见BUG解决）】
- 问题1：溶解效果无变化 → 检查animation_progress是否在0~1区间赋值；确认noise_texture已正确分配
- 问题2：描边不显示 → 检查stroke_progress是否>0；调大描边宽度（stroke_width_base）；确认stroke_color的Alpha值为1
- 问题3：溶解效果太粗/太细 → 调整noise_scale（值越大噪声越细碎，溶解效果越密）
- 问题4：描边与消失不同步 → 检查stroke_threshold的计算逻辑，或调整stroke_width_base的数值
- 问题5：透明区域也显示描边 → 可在COLOR赋值处增加original_color.a的判断（见下方注释提示）
- 问题6：语法报错（如“:后预期为有效的类型提示”）→ 检查Godot版本兼容：4.x需用source_color，3.x用hint_color

【版本兼容提示】
- Godot 4.x 着色器类型提示变更：颜色选择提示从 hint_color → source_color
- Godot 4.x 噪声采样无需额外兼容，仅需确保噪声纹理为单通道（R通道有效）
===========================================================================
*/

// -------------------------- 可配置参数（Inspector中调整） --------------------------
// 噪声纹理：用于分割溶解区域，推荐使用无缝噪声图（Godot内置OpenSimplexNoise生成即可）
uniform sampler2D noise_texture;

// 动画消失进度 [0.0~1.0]：0=完全显示，1=完全消失；控制整体溶解的进度，噪声值低的区域优先消失
uniform float animation_progress : hint_range(0, 1) = 0.0;

// 描边进度 [0.0~1.0]：0=无描边，1=最大描边范围；控制消失边缘描边的显示宽度
uniform float stroke_progress : hint_range(0, 1) = 0.0;

// 描边颜色：默认红色，可根据需求调整（建议保留Alpha=1.0）
// 关键修正：Godot 4.x 用 source_color 替代 hint_color，避免语法报错
uniform vec4 stroke_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// 噪声缩放：控制噪声图案的精细度 [0.1~10.0]；值越大噪声越细碎，溶解效果越密
uniform float noise_scale : hint_range(0.1, 10.0) = 2.0;

// 描边基础宽度：控制描边的像素宽度（固定值，配合stroke_progress动态调整）
// 调试提示：若描边太窄调大（如0.15），太宽调小（如0.05）
uniform float stroke_width_base : hint_range(0.01, 0.5) = 0.1;

void fragment() {
    // 1. 获取当前像素的纹理坐标（UV），用于采样原始纹理和噪声纹理
    vec2 uv = UV;
    
    // 2. 采样噪声纹理并归一化到0~1范围（原始噪声值通常为-1~1，需映射）
    float noise = texture(noise_texture, uv * noise_scale).r; // 取噪声的红色通道（单通道噪声图）
    noise = noise * 0.5 + 0.5; // 映射公式：(原始值 + 1) / 2 → 结果范围0~1
    // 调试提示：可通过输出noise值排查（如COLOR = vec4(noise, 0, 0, 1)），确认噪声采样正常
    
    // 3. 计算三个区域的阈值（核心逻辑：噪声值 < 阈值则进入对应区域）
    float hide_threshold = animation_progress; // 隐藏区域阈值：低于此值的像素完全透明
    float stroke_threshold = hide_threshold + (stroke_progress * stroke_width_base); // 描边区域阈值：介于隐藏和正常之间
    
    // 4. 采样原始纹理颜色（怪物的Sprite2D纹理）
    vec4 original_color = texture(TEXTURE, uv);
    // 调试提示：若原始纹理透明区域异常，可加判断：if (original_color.a < 0.1) { COLOR = vec4(0); return; }
    
    // 5. 区域判断：根据噪声值分配对应颜色
    if (noise < hide_threshold) {
        // 隐藏区域：完全透明（死亡消失的核心效果）
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (noise < stroke_threshold) {
        // 描边区域：显示红色描边，保留原始Alpha（避免描边超出怪物轮廓）
        COLOR = stroke_color * vec4(1.0, 1.0, 1.0, original_color.a);
        // 调试提示：若描边颜色过淡，可去掉original_color.a的乘法，直接用stroke_color
    } else {
        // 正常显示区域：保留原始纹理颜色
        COLOR = original_color;
    }
    
    // 调试专用代码（启用时可直观查看噪声分布和阈值）
    // 用法：取消注释后，噪声值用红色表示，阈值用绿色线标记，方便排查区域分割问题
    /*
    // 绘制噪声值（红色通道）
    COLOR = vec4(noise, 0.0, 0.0, 1.0);
    // 绘制隐藏阈值线（绿色）
    if (abs(noise - hide_threshold) < 0.01) { COLOR = vec4(0.0, 1.0, 0.0, 1.0); }
    // 绘制描边阈值线（蓝色）
    if (abs(noise - stroke_threshold) < 0.01) { COLOR = vec4(0.0, 0.0, 1.0, 1.0); }
    */
}