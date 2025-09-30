## Tween动画工具类
## 提供基于Godot Tween的动画创建和控制功能
#extends Node
#class_name 引擎缓动
#
### 创建一个新的Tween动画实例
### [br]返回:[br]
###   - 新创建的Tween对象
###[codeblock]
### var 缓动器 = 引擎.缓动.创建缓动()
###[/codeblock]
#func 创建缓动() -> Tween:
	#return  Engine.get_main_loop().current_scene.create_tween()
#
### 添加一个属性缓动动画
### [br]参数:[br]
###   - _缓动器: Tween实例[br]
###   - _物体: 要操作的对象[br]
###   - _物体属性: 要缓动的属性路径，默认为"position"[br]
###   - _目标值: 属性的目标值，默认为Vector2(258, 0)[br]
###   - _时间: 动画持续时间（秒），默认为1.0秒
### [br]返回:[br]
###   - PropertyTweener对象，可用于链式设置动画参数
###[codeblock]
### 引擎.缓动.追加缓动属性(缓动器, $Node2D, "position", Vector2(100, 100), 0.5)
###[/codeblock]
#func 追加缓动属性(_缓动器: Tween, _物体: Object, _物体属性: NodePath = "position", _目标值: Variant = Vector2(258, 0), _时间: float = 1.0) -> PropertyTweener:
	#return _缓动器.tween_property(_物体, _物体属性, _目标值, _时间)
#
### 添加一个回调函数到Tween序列
### [br]参数:[br]
###   - _缓动器: Tween实例[br]
###   - _独立函数: 要调用的Callable函数
### [br]返回:[br]
###   - CallbackTweener对象，可用于链式设置回调参数
###[codeblock]
### 引擎.缓动.追加缓动函数(缓动器, self.on_animation_complete.bind(arg1, arg2))
###[/codeblock]
#func 追加缓动函数(_缓动器: Tween, _独立函数: Callable) -> CallbackTweener:
	#return _缓动器.tween_callback(_独立函数)
#
### 立即终止并删除Tween动画
### [br]参数:[br]
###   - _缓动器: 要终止的Tween实例
###[codeblock]
### 引擎.缓动.结束(缓动器)
###[/codeblock]
#func 结束(_缓动器: Tween):
	#_缓动器.kill()
