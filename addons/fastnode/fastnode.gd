@tool
extends EditorPlugin

var 面板 = preload("res://addons/fastnode/ui.tscn").instantiate()

func _enter_tree():
    面板.ed = self
    面板.name = "节点速览"
    add_control_to_dock(DOCK_SLOT_RIGHT_UL, 面板)
    
func _exit_tree():
    if is_instance_valid(面板):
        remove_control_from_docks(面板)
        if is_instance_valid(面板.ed):
            面板.ed = null
