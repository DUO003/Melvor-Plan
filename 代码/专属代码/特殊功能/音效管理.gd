extends Node
class_name 梅声音

# 全局默认音量（0~1 线性值，最直观）
const 默认音量 = 1.0

# 所有音效预加载
var 音效文件: Dictionary[String, AudioStream] = {
	"鼠标点击": preload("res://素材/音效/点击鼠标音效.mp3"),
	"启用": preload("res://素材/GDC2026音频包/音频_启用.wav"),
	"打开": preload("res://素材/GDC2026音频包/音频_打开.wav"),
	"滑动": preload("res://素材/GDC2026音频包/音频_滑动.wav"),
	"解锁": preload("res://素材/GDC2026音频包/音频_解锁.wav"),
	"金币": preload("res://素材/GDC2026音频包/音频_金币.wav"),
	"错误": preload("res://素材/GDC2026音频包/音频_错误.wav"),
	"火球": preload("res://素材/GDC2026音频包/音频_火球.wav"),
	"电流": preload("res://素材/GDC2026音频包/音频_电流.wav"),
	"破碎": preload("res://素材/GDC2026音频包/音频_破碎.wav"),
	"水泡": preload("res://素材/GDC2026音频包/音频_水泡.wav"),
	"硬币": preload("res://素材/自制/音频/硬币碰撞.wav"),
}

# ====================== 核心通用方法 ======================
# 调用示例：
# 梅声音.播放音效("鼠标点击")
# 梅声音.播放音效("金币", 0.5)  → 半音量
func 播放音效(音效名称: String, 自定义音量: float = 默认音量):
	# 全局静音判断
	if 计划.配置文件.has("音量") and 计划.配置文件["音量"] == 0:
		return

	# 检查音效是否存在
	if not 音效文件.has(音效名称):
		print("⚠️ 音效不存在：", 音效名称)
		return

	# 创建临时播放器
	var 音频播放器 = AudioStreamPlayer.new()
	音频播放器.stream = 音效文件[音效名称]
	
	# ✅ 正确写法：线性音量转分贝 (Godot 4 官方标准)
	音频播放器.volume_db = linear_to_db(自定义音量)
	
	add_child(音频播放器)

	# 播放完成后自动销毁
	音频播放器.finished.connect(音频播放器.queue_free)
	音频播放器.play()

# ====================== 兼容旧方法 ======================
func 播放鼠标点击音效():
	播放音效("鼠标点击")

func 语法糖随机音效(音效列表: Array[String], 自定义音量: float = 默认音量):
	if 音效列表.is_empty():
		print("⚠️ 随机音效列表为空")
		return
	
	# 平均概率随机选一个
	var 随机索引 = randi() % 音效列表.size()
	var 选中音效 = 音效列表[随机索引]
	
	# 播放
	播放音效(选中音效, 自定义音量)
