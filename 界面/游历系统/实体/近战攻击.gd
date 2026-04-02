extends 游历子弹
class_name 游历子弹_近战攻击
var 击退力:Vector2=Vector2(10,10)
##子弹创建后立即播放动画
func _ready() -> void:
	print("攻击开始,动画时长%.1f"%获取动画时长())
	if not 初始化参数检查():
		return
	var 所有动画名称: PackedStringArray = 动画.get_animation_list()
	if 武器名称 not in 所有动画名称:
		print("警告：动画「%s」不存在，已重置为默认动画" % 武器名称)
		武器名称 = "标准剑"
	var 当前动画: Animation = 动画.get_animation(武器名称)
	var 动画时长: float = 当前动画.length  # 获取动画总时长（单位：秒）
	动画.play(武器名称)
	if 动画时长>=0.1:
		动画.animation_finished.connect(动画结束)
	else :
		visible=false
		await 动画.animation_finished
		visible=true
		贴图.rotation += 1
		await get_tree().create_timer(0.15).timeout
		var 补间动画 = create_tween()
		补间动画.tween_property(贴图, "rotation",贴图.rotation- 1, 0.1)
		造成伤害()
		await get_tree().create_timer(0.1).timeout
		攻击结束()
func 攻击结束():
	await get_tree().create_timer(0.1).timeout
	queue_free()
func 获取动画时长()->float:
	var 当前动画: Animation = 动画.get_animation(武器名称)
	var 动画时长: float = 当前动画.length  # 获取动画总时长（单位：秒）
	if 动画时长>=0.1:return 动画时长+0.1
	else :return 0.35
