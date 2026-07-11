# 通用平移补间动画控制器（火球/飞弹/投射物通用）
class_name 梅平移补间控制器
extends Node2D

# 补间缓动方法枚举（对应Tween.TransitionType + Tween.EaseType）
enum 缓动模式 {
	线性 = 0,           # 匀速线性
	正弦缓入 = 1,
	正弦缓出 = 2,
	正弦缓入缓出 = 3,
	二次缓入 = 4,
	二次缓出 = 5,
	二次缓入缓出 = 6,
	三次缓入 = 7,
	三次缓出 = 8,
	三次缓入缓出 = 9,
	四次缓入 = 10,
	四次缓出 = 11,
	四次缓入缓出 = 12,
	五次缓入 = 13,
	五次缓出 = 14,
	五次缓入缓出 = 15,
	弹性缓入 = 16,
	弹性缓出 = 17,
	弹性缓入缓出 = 18,
	指数缓入 = 19,
	指数缓出 = 20,
	指数缓入缓出 = 21,
	回退缓入 = 22,
	回退缓出 = 23,
	回退缓入缓出 = 24,
	弹跳缓入 = 25,
	弹跳缓出 = 26,
	弹跳缓入缓出 = 27,
}

# 信号：抵达目标坐标
signal 抵达目标()
# 信号：整套动画全部结束（含爆炸粒子）
signal 动画播放完成()

# 核心参数
var 目标坐标: Vector2 = Vector2.ZERO
var 生成坐标: Vector2 = Vector2.ZERO
var 动画时长: float = 1.0
var 当前缓动: 缓动模式 = 缓动模式.线性

# 可在编辑器拖拽赋值（泛用化，不绑定固定节点路径）
@export var 动画精灵: Sprite2D
@export var 拖尾粒子: GPUParticles2D
@export var 爆炸粒子: GPUParticles2D

# 内部缓存
var _补间实例: Tween = null
var _是否播放中: bool = false
var _摆动偏移: Vector2 = Vector2.ZERO
#func _ready() -> void:
	## 起点坐标 300,300，目标 1500,800，飞行5秒，缓动选用二次缓出
	#初始化(Vector2(1500, 800),Vector2(300, 300),1.0,缓动模式.二次缓入)

# 初始化并启动平移飞行动画
# 参数：目标位置、生成位置、动画持续时间、缓动模式（可选）
func 初始化(p_目标坐标: Vector2,p_生成坐标: Vector2,p_动画时长: float,p_缓动模式: 缓动模式 = 缓动模式.线性) -> void:
	# 赋值参数
	目标坐标 = p_目标坐标
	生成坐标 = p_生成坐标
	动画时长 = p_动画时长
	当前缓动 = p_缓动模式
	# 重置初始状态
	global_position = 生成坐标
	global_scale = Vector2.ONE
	global_rotation = 0.0
	if 动画精灵:
		动画精灵.visible = true

	# 计算飞行朝向，根节点整体转向飞行方向
	var 飞行方向 = (目标坐标 - 生成坐标).normalized()
	if 飞行方向 != Vector2.ZERO:
		global_rotation = 飞行方向.angle()

	# 开启拖尾粒子
	if 拖尾粒子:
		拖尾粒子.emitting = true

	# 启动整套并行补间动画
	_启动补间动画()


# 内部：创建并配置并行补间动画
func _启动补间动画() -> void:
	# 杀死残留动画防止重叠
	if _补间实例 and _补间实例.is_running():
		_补间实例.kill()

	_补间实例 = create_tween()
	_补间实例.set_parallel(true)  # 所有动画同步并行执行

	# 1. 核心位移动画：从起点平滑移动至目标
	var 位移动画:PropertyTweener = _补间实例.tween_property(
		self,
		"global_position",
		目标坐标,
		动画时长
	)
	_应用缓动模式(位移动画, 当前缓动)

	# 2. 飞行小幅左右摆动（正弦晃动）
	var 摆动动画:MethodTweener = _补间实例.tween_method(
		_计算摆动偏移,
		0.0,
		1.0,
		动画时长)
	_应用缓动模式(摆动动画, 缓动模式.正弦缓入缓出)

	# 4. 整体缩放动画：接近目标轻微放大
	var 缩放动画:PropertyTweener = _补间实例.tween_property(
		self,
		"global_scale",
		Vector2(1.2, 1.2),
		动画时长
	)
	_应用缓动模式(缩放动画, 当前缓动)
	_补间实例.finished.connect(_动画结束处理)
	_是否播放中 = true


# 根据枚举匹配引擎原生过渡+缓动类型
func _应用缓动模式(动画器: Tweener, 模式: 缓动模式) -> void:
	match 模式:
		缓动模式.线性:
			动画器.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		缓动模式.正弦缓入:
			动画器.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		缓动模式.正弦缓出:
			动画器.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		缓动模式.正弦缓入缓出:
			动画器.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		缓动模式.二次缓入:
			动画器.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		缓动模式.二次缓出:
			动画器.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		缓动模式.二次缓入缓出:
			动画器.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		缓动模式.三次缓入:
			动画器.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		缓动模式.三次缓出:
			动画器.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		缓动模式.三次缓入缓出:
			动画器.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		缓动模式.四次缓入:
			动画器.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		缓动模式.四次缓出:
			动画器.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		缓动模式.四次缓入缓出:
			动画器.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)
		缓动模式.五次缓入:
			动画器.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		缓动模式.五次缓出:
			动画器.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		缓动模式.五次缓入缓出:
			动画器.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		缓动模式.弹性缓入:
			动画器.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
		缓动模式.弹性缓出:
			动画器.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		缓动模式.弹性缓入缓出:
			动画器.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
		缓动模式.指数缓入:
			动画器.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		缓动模式.指数缓出:
			动画器.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		缓动模式.指数缓入缓出:
			动画器.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		缓动模式.回退缓入:
			动画器.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		缓动模式.回退缓出:
			动画器.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		缓动模式.回退缓入缓出:
			动画器.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		缓动模式.弹跳缓入:
			动画器.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
		缓动模式.弹跳缓出:
			动画器.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		缓动模式.弹跳缓入缓出:
			动画器.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)


# 计算飞行过程左右摆动偏移
func _计算摆动偏移(进度: float) -> void:
	var 摆动幅度 = 12.0 * sin(进度 * 2 * PI * 2)  # 2个完整晃动周期，单位像素
	var 飞行方向 = (目标坐标 - 生成坐标).normalized()
	# 垂直于飞行方向的横向轴（2D垂直向量）
	var 横向轴 = Vector2(-飞行方向.y, 飞行方向.x)
	_摆动偏移 = 横向轴 * 摆动幅度
	# 叠加偏移实现晃动效果
	global_position = 生成坐标.move_toward(目标坐标, (生成坐标 - 目标坐标).length() * 进度) + _摆动偏移





# 动画抵达目标后的收尾逻辑（严格按需求重构）
func _动画结束处理() -> void:
	#隐藏动画精灵贴图
	if 动画精灵:
		动画精灵.visible = false
		print("贴图已隐藏")
	#立刻暂停拖尾粒子继续生成
	if 拖尾粒子:
		拖尾粒子.emitting = false
	print("动画结束")
	_是否播放中 = false
	#发送抵达目标信号
	抵达目标.emit()
	# 分支1：存在爆炸粒子，等爆炸播放完再发送完成信号
	if 爆炸粒子:
		爆炸粒子.emitting = true
		# 等待粒子完整生命周期
		await get_tree().create_timer(爆炸粒子.lifetime).timeout
		动画播放完成.emit()
	# 分支2：无爆炸粒子，抵达直接发送完成信号
	else:
		动画播放完成.emit()


# 查询当前是否正在播放平移动画
func 是否播放中() -> bool:
	return _是否播放中

# 暂停动画
func 暂停动画() -> void:
	if _补间实例 and _补间实例.is_running():
		_补间实例.pause()

# 恢复动画
func 恢复动画() -> void:
	if _补间实例 and _补间实例.is_running():
		_补间实例.play()
