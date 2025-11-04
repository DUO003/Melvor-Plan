extends Node
##不具备任何功能,仅展示常用语法.
func 语法备忘录(真: bool=true,假: bool=false,
整数: int = 1,浮点数: float = 1.0,文本:String = "",
数组: Array = [],字典: Dictionary = {},节点引用: Control = $Control,
颜色: Color = Color(1, 0, 0),空值 = null,方法:Callable=func(_参数名):pass,
二维向量: Vector2 = Vector2(0,0),二维向量整数: Vector2i = Vector2i(0,0),
三维向量: Vector3 = Vector3(0,0,0),三维向量整数: Vector3i = Vector3i(0,0,0)):
	#基础类型（备注）
		#var 布尔值: bool = true # 基础布尔类型，取值true/false
		#var 整数: int = 10 # 基础整数类型，无小数部分
		#var 浮点数: float = 3.14 # 基础浮点类型，支持小数
		#var 文本: String = "Godot" # 基础字符串类型，存储文本
		#var 数组: Array = [1, "a", true] # 通用数组，可存储不同类型数据
		#var 字典: Dictionary = {"key": "value", 1: 2} # 键值对集合，通过键访问值
		#var 节点引用: Control = $Control # 场景树节点引用，直接关联场景节点
		#var 颜色: Color = Color(1, 0, 0, 1) # 颜色类型，RGBA取值0-1（红、绿、蓝、透明度）
		#var 空值: null = null # 空值类型，表示无数据
		#var 方法: Callable = func(参数): pass # 可调用方法类型，存储函数引用
		#var 二维向量: Vector2 = Vector2(100.0, 200.0) # 2D向量，用于2D位置、尺寸等（浮点数）
		#var 二维向量整数: Vector2i = Vector2i(50, 50) # 2D整数向量，适用于整数坐标场景
		#var 三维向量: Vector3 = Vector3(0, 1, 0) # 3D向量，用于3D位置、旋转、缩放等（浮点数）
		#var 三维向量整数: Vector3i = Vector3i(1, 2, 3) # 3D整数向量，适用于3D整数坐标场景
		#补充基础类型
		#var _节点路径: NodePath = NodePath("Control/Label") # 节点路径类型，安全引用场景树节点路径
		#var _二维矩形: Rect2 = Rect2(10.0, 20.0, 100.0, 50.0) # 2D矩形（浮点数），存储x、y位置和宽高
		#var _二维矩形整数: Rect2i = Rect2i(10, 20, 100, 50) # 2D整数矩形，适用于整数尺寸/位置场景
		#var _三维盒体: AABB = AABB(Vector3(0,0,0), Vector3(10,10,10)) # 3D轴对齐盒体（浮点数），存储位置和大小
		#var _四元数: Quaternion = Quaternion(Vector3(0,1,0), PI/2) # 3D旋转类型，避免欧拉角万向锁问题
		#var _基向量矩阵: Basis = Basis(Vector3(0,1,0), PI/2) # 3x3矩阵，表示3D旋转和缩放
		#var _二维变换矩阵: Transform2D = Transform2D(PI/4, Vector2(100,200),PI/4, Vector2(1,1)) # 2D完整变换，包含旋转角度、缩放向量、倾斜角度,位置向量
		#var _三维变换矩阵: Transform3D = Transform3D(Basis(), Vector3(0,1,0)) # 3D完整变换，包含位置、旋转、缩放
		#var _字符串名称: StringName = StringName("on_click") # 高效字符串类型，适用于信号名、属性名等高频访问场景
		#var _资源ID: RID = load("res://icon.svg").get_rid() # 底层资源ID，用于引用纹理、声音等底层资源
		#var _字节池数组: PackedByteArray = PackedByteArray([0x00, 0xFF, 0x80]) # 指定类型的数组，高效存储大量指定类型的相同数据
		#var _四维向量: Vector4 = Vector4(1.0, 2.0, 3.0, 4.0) # 4D向量，常用于着色器、矩阵运算等场景
		#var _四维向量整数: Vector4i = Vector4i(1, 2, 3, 4) # 4D整数向量，适用于4D整数运算场景
		#var _平面: Plane = Plane(Vector3(0,1,0), 0) # 3D平面类型，由法向量和原点距离定义，常用于碰撞检测
	var 参数:Variant=""
	方法.call(参数)#执行方法
	return[真,假,整数,浮点数,文本,数组,字典,节点引用,颜色,空值,二维向量,二维向量整数,三维向量,三维向量整数]
#func _exit_tree() -> void:#节点退出节点树时执行（生命周期结束）
#func _tree_entered() -> void:#节点进入场景树时执行（早于_ready）
#func _tree_exiting() -> void:#节点即将退出场景树时执行（退出前回调）
#
#func _physics_process(_delta: float) -> void:#每物理帧执行（默认60帧/秒，适合物理逻辑）
#func _process(_delta: float) -> void:#每帧执行（帧率随硬件变化，适合UI/动画）
#
#func _input(event: InputEvent) -> void:#处理输入事件（如按键/鼠标，优先于节点树下游）
#func _unhandled_input(event: InputEvent) -> void:#处理未被其他节点消耗的输入事件
#func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:#碰撞体接收输入事件时执行（如按钮点击检测）
#
#func _draw() -> void:#触发自定义绘制时执行（需调用update()触发，适合2D绘制）
#func _visible_changed() -> void:#节点可见性（visible属性）改变时执行
#
#func _body_entered(body: Node3D) -> void:#检测到刚体进入碰撞范围时执行（3D碰撞体）
#func _body_exited(body: Node3D) -> void:#检测到刚体离开碰撞范围时执行（3D碰撞体）
#func _body_shape_entered(shape_idx: int, body: Node3D, body_shape_idx: int, local_point: Vector3, local_normal: Vector3, impulse: Vector3) -> void:#3D刚体碰撞形状接触时执行
#func _area_entered(area: Area3D) -> void:#检测到Area进入范围时执行（3D Area节点）
#func _area_exited(area: Area3D) -> void:#检测到Area离开范围时执行（3D Area节点）
#
#func _body_entered(body: Node2D) -> void:#检测到刚体进入碰撞范围时执行（2D碰撞体）
#func _body_exited(body: Node2D) -> void:#检测到刚体离开碰撞范围时执行（2D碰撞体）
#func _area_entered(area: Area2D) -> void:#检测到Area进入范围时执行（2D Area节点）
#func _area_exited(area: Area2D) -> void:#检测到Area离开范围时执行（2D Area节点）
#
#func _animation_finished(anim_name: StringName) -> void:#动画播放完毕时执行（AnimationPlayer节点）
#func _animation_started(anim_name: StringName) -> void:#动画开始播放时执行（AnimationPlayer节点）
#
#func _timeout() -> void:#定时器超时触发时执行（Timer节点）
#func _script_changed() -> void:#脚本被修改或重新加载时执行
#
#func _notification(what: int) -> void:#处理节点通用通知（如场景切换、资源加载等，需配合NOTIFICATION_*常量）
	#print()
	#signal#声明信号
	#初始化.emit_signal("更新_UI")#发出信号示例
