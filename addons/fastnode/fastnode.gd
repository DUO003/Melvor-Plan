@tool
extends EditorPlugin
var 面板
func _enter_tree():
	面板= preload("res://addons/fastnode/ui.tscn").instantiate()
	面板.ed = self
	面板.name = "目录"
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, 面板)
func _exit_tree():
	if is_instance_valid(面板):
		remove_control_from_docks(面板)
		面板.queue_free()
