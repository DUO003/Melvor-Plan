extends Control
var 当前摄像机:Camera2D
var 初始大小:Vector2
var 初始位置:Vector2
var 相机全局位置:Vector2
func _ready():
	clip_contents=true
	初始位置=position
	初始大小=size
	var 活跃相机:Camera2D = get_viewport().get_camera_2d()
	if 活跃相机:
		当前摄像机=活跃相机
		相机全局位置 = 当前摄像机.global_position
func _physics_process(_间隔: float) -> void:
	if 当前摄像机:
		var 相机位置 = 当前摄像机.global_position
		position=相机全局位置-相机位置+初始位置
