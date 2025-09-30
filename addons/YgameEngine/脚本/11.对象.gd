extends Node
class_name 引擎对象


## 创建对象（支持场景资源或普通类）
## [codeblock]
## # 创建场景对象
## var 敌人对象 = 引擎.对象.创建对象("res://scenes/Enemy.tscn")
## # 创建普通类对象
## var 数据对象 = 引擎.对象.创建对象("res://scripts/Data.gd")
## [/codeblock]
func 创建对象(对象路径: String) -> Object:
	var 资源 = load(对象路径)
	if 资源 is PackedScene:
		return 资源.instantiate()  # 场景对象实例化
	else:
		return 资源.new()  # 普通类对象创建
	

## 创建对象并添加为子对象
## [br]参数:[br]
##   - 父对象: 接收子对象的父级对象（Node类型）[br]
##   - 子对象场景路径: 要创建的子对象场景路径
## [br]返回:[br]
##   - 创建并添加成功的子对象
##[codeblock]
## 引擎.对象.创建并添加子对象($Parent, "res://scenes/Child.tscn")
##[/codeblock]
func 创建并添加子对象(父对象:Node, 子对象场景路径:String) -> Node:
	var 子对象 = 创建对象(子对象场景路径)  # 复用创建对象的逻辑
	父对象.add_child(子对象)
	return 子对象

## 清空指定对象的所有子对象
## [br]参数:[br]
##   - 目标对象: 要清空子对象的父对象
##[codeblock]
## 引擎.对象.清空子对象($Parent)
##[/codeblock]
func 清空子对象(目标对象:Node):
	for 子对象 in 目标对象.get_children():
		目标对象.remove_child(子对象)

## 将焦点设置到指定对象
## [br]参数:[br]
##   - 目标对象: 要获取焦点的对象（如按钮、输入框等）
##[codeblock]
## 引擎.对象.设置焦点($Button)
##[/codeblock]
func 设置焦点(目标对象:Node):
	目标对象.grab_focus()

## 显示指定对象
## [br]参数:[br]
##   - 目标对象: 要显示的对象
##[codeblock]
## 引擎.对象.显示($Panel)
##[/codeblock]
func 显示(目标对象:Node):
	目标对象.show()

## 隐藏指定对象
## [br]参数:[br]
##   - 目标对象: 要隐藏的对象
##[codeblock]
## 引擎.对象.隐藏($Panel)
##[/codeblock]
func 隐藏(目标对象:Node):
	目标对象.hide()

## 获取指定路径的子对象
## [br]参数:[br]
##   - 父对象: 父级对象实例[br]
##   - 子对象路径: 子对象的路径（如"Child/Grandchild"）
## [br]返回:[br]
##   - 指定路径的子对象
##[codeblock]
## var 子对象 = 引擎.对象.获取子对象($Parent, "Child/Grandchild")
##[/codeblock]
func 获取子对象(父对象:Node, 子对象路径:NodePath) -> Node:
	return 父对象.get_node(子对象路径)



## 为对象挂载脚本
## [br]参数:[br]
##   - 目标对象: 要挂载脚本的对象[br]
##   - 脚本资源: 要挂载的脚本资源（通过load()加载）
##[codeblock]
## 引擎.对象.挂载脚本到对象($Node, "res://scripts/MyScript.gd")
##[/codeblock]
func 挂载脚本到对象(目标对象:Node, 脚本路径):
	目标对象.set_script(load(脚本路径))

func 检测碰撞体(包围盒位置:Vector2,包围盒尺寸:Vector2,过滤检测方:bool=false):
	var 检测2D=Area2D.new()
	
	var 检测2D碰撞体=CollisionShape2D.new()
	var 检测2D物理矩形=RectangleShape2D.new()
	检测2D物理矩形.extents = 包围盒尺寸
	检测2D碰撞体.shape = 检测2D物理矩形
	检测2D.add_child(检测2D碰撞体)
	检测2D.name="包围盒"
	Engine.get_main_loop().current_scene.add_child(检测2D)
	检测2D.position=包围盒位置
	检测2D.z_index = 11
	var 形状2D查询 = PhysicsShapeQueryParameters2D.new()
	形状2D查询.set_shape(检测2D物理矩形)
	形状2D查询.collide_with_areas = true
	
	形状2D查询.transform = Transform2D(0, 包围盒位置)
	var 查询数据 =Engine.get_main_loop().current_scene.get_world_2d().direct_space_state.intersect_shape(形状2D查询)
	
	
	##打包
	var 碰撞体列表=[]
	for i in 查询数据:
		if 过滤检测方==true:
			if i.collider!=检测2D:
				碰撞体列表.append(i.collider)
		else:
			碰撞体列表.append(i.collider)
	#延迟销毁(检测2D)
	销毁对象延迟(检测2D)
	return 碰撞体列表

## 销毁指定对象
## [br]参数:[br]
##   - 目标对象: 要销毁的对象
##[codeblock]
## 引擎.对象.销毁对象($TempNode)
##[/codeblock]
func 销毁对象(目标对象:Node):
	目标对象.queue_free()

func 销毁对象延迟(目标对象:Node,时间:float=1.0):
	await Engine.get_main_loop().create_timer(时间).timeout
	目标对象.queue_free()
## 检查对象实例是否有效
## [br]参数:[br]
##   - 目标对象: 要检查的对象
## [br]返回:[br]
##   - 如果对象有效返回true，否则返回false
##[codeblock]
## if 引擎.对象.是否有效对象($Node):
##     print("对象有效")
##[/codeblock]
func 是否有效对象(目标对象:Node) -> bool:
	return is_instance_valid(目标对象)  # 优化：判断节点是否真正有效（处理已销毁但未回收的情况）

func 获取子对象数量(目标对象:Node) -> int:
	return 目标对象.get_child_count()

func 获取索引(目标对象:Node)-> int:#
	return 目标对象.get_index()
	


## 将对象设置为目标父对象的子对象（变更父子关系）
## [br]参数:[br]
##   - 待设置对象: 要成为子对象的对象[br]
##   - 目标父对象: 新的父级对象（待设置对象将成为其子对象）
##[codeblock]
## 引擎.对象.设置为子对象($Child, $NewParent)  # $Child 成为 $NewParent 的子对象
##[/codeblock]
func 设置为子对象(待设置对象:Node, 目标父对象:Node):
	待设置对象.reparent(目标父对象)
