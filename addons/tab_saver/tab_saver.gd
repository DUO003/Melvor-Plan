@tool
extends EditorPlugin
# 固定场景路径
const TARGET_SCENE_PATH: String = "res://界面/空界面.tscn"
# 自定义标签页的主控件
var custom_screen: Control = null
func _enter_tree() -> void:
	# 1. 创建标签页内容（一个按钮，居中显示）
	custom_screen = PanelContainer.new()
	custom_screen.name = "EmptySceneScreen"
	# 按钮
	var open_btn = Button.new()
	open_btn.text = "打开空界面场景"
	open_btn.custom_minimum_size = Vector2(200, 50)
	open_btn.pressed.connect(_on_open_clicked)
	# 居中容器
	var center_container = CenterContainer.new()
	center_container.add_child(open_btn)
	custom_screen.add_child(center_container)
	# 2. 将控件添加到编辑器主屏幕（主屏幕是 2D/3D/脚本标签的容器）
	var main_screen = EditorInterface.get_editor_main_screen()
	main_screen.add_child(custom_screen)
	custom_screen.hide()  # 初始隐藏，切换到该标签时再显示
func _exit_tree() -> void:
	# 移除控件
	custom_screen.queue_free()
# 声明这是一个主屏幕插件（必须实现，否则标签不显示）
func _has_main_screen() -> bool:
	return true
# 标签页显示的名称（必须实现）
func _get_plugin_name() -> String:
	return "空界面"
# 标签页的图标（可选，用内置图标）
func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("SceneFile", "EditorIcons")
# 控制标签页的显示/隐藏（当切换到该标签时调用）
func _make_visible(visible: bool) -> void:
	custom_screen.visible = visible
# 按钮点击事件：打开固定场景
func _on_open_clicked() -> void:
	var editor = EditorInterface
	editor.open_scene_from_path(TARGET_SCENE_PATH)
	editor.set_main_screen_editor("2D")
