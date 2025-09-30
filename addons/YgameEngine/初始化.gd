@tool
extends EditorPlugin


#插件启动函数
func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton("引擎", "res://addons/YgameEngine/脚本/0.引擎.gd")
	print("引擎插件已启动，全局'引擎.xxx'可使用")
	
	#
	

#插件关闭函数
func _disable_plugin() -> void:
	remove_autoload_singleton("引擎")
	print("引擎插件已注销，全局'引擎.xxx'不再可用")


	
func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
