@tool
extends EditorPlugin
##将固定场景路径字典（键=按钮名称，值=场景路径）
# 自定义标签页的主控件
var 标签页: Control = null
const 快捷跳转 := preload("res://addons/tab_saver/快捷跳转.tscn")
func _enter_tree() -> void:
	标签页=快捷跳转.instantiate()
	标签页.hide()  # 初始隐藏，切换到该标签时再显示
	var 扩展页 = EditorInterface.get_editor_main_screen()
	扩展页.add_child(标签页)
	#print("标签页",标签页)
func _exit_tree() -> void:
	# 移除控件（保留原逻辑）
	if is_instance_valid(标签页):
		标签页.queue_free()
# 声明这是一个主屏幕插件
func _has_main_screen() -> bool:
	return true

# 标签页显示的名称（保留原逻辑）
func _get_plugin_name() -> String:
	return "快捷跳转"

## 标签页的图标
#func _get_plugin_icon() -> Texture2D:
	#return EditorInterface.get_editor_theme().get_icon("SceneFile", "EditorIcons")

# 控制标签页的显示/隐藏（保留原逻辑）
func _make_visible(visible: bool) -> void:
	if is_instance_valid(标签页):
		标签页.visible = visible
