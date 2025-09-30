@tool
extends Control

var ed: EditorPlugin = null


func _on_刷新_pressed() -> void:
    if is_instance_valid(ed.面板): #如果面板存在
        ed.remove_control_from_docks(ed.面板) #从右侧移除面板
        #ed.remove_control_from_bottom_panel(ed.面板) #从底部面板移除面板
        for child in ed.面板.get_children(): #遍历面板的子节点
            ed.面板.remove_child(child) #移除子节点
            child.queue_free() #释放子节点
        ed.面板.queue_free() #释放面板
    
    # 重新创建面板
    ed.面板 = preload("res://addons/fastnode/ui.tscn").instantiate() #加载面板
    ed.面板.ed = ed #设置面板的ed属性为ed
    ed.面板.name = "节点速览"
    #ed.add_control_to_bottom_panel(ed.面板, "UI模板") #将面板添加到底部面板
    ed.add_control_to_dock( ed.DOCK_SLOT_RIGHT_UL, ed.面板) #显示在右侧
    print("插件已刷新") #打印信息
    pass

#---------------------

#------创建模板
func _on_模板_1_pressed() -> void:
    var 场景 = PackedScene.new()
    var 根节点 = Node2D.new()
    根节点.name = "Template1Root"
    
    var 图片 = Sprite2D.new()
    图片.name = "MySprite"
    根节点.add_child(图片)
    
    # 设置owner以便正确保存场景
    for child in 根节点.get_children():
        child.owner = 根节点
    
    场景.pack(根节点)
    var 新路径 = "res://模板_1_%d.tscn" % (randi() % 10000)
    ResourceSaver.save(场景, 新路径)
    ed.get_editor_interface().open_scene_from_path(新路径)
    pass


#------容器
var editor
var selection
var selected_nodes
var parent_node 

func selectnode() -> void:
    editor = ed.get_editor_interface() #获取编辑器接口
    print("编辑器接口: ", editor)  # 调试输出
    selection = editor.get_selection() #获取选择器
    print("选择器: ", selection)  # 调试输出
    selected_nodes = selection.get_selected_nodes() #获取选中的节点
    print("选中的节点数量: ", selected_nodes.size())  # 调试输出
    if selected_nodes.size() == 0:
        printerr("请先选择一个父节点")
        return
    parent_node = selected_nodes[0]
    print("父节点类型: ", parent_node.get_class())  # 调试输出


#------容器
func _on_container_pressed() -> void:
    selectnode()
    var newnode = Container.new()
    newnode.name = "Container"
    
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass


func _on_panel_container_pressed() -> void:
    selectnode()
    var newnode = PanelContainer.new()
    newnode.name = "PanelContainer"

    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_tab_container_pressed() -> void:
    selectnode()
    var newnode = TabContainer.new()
    newnode.name = "TabContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_box_container_pressed() -> void:
    selectnode()
    var newnode = BoxContainer.new()
    newnode.name = "BoxContainer"
    parent_node.add_child(newnode)  
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_box_container_pressed() -> void:
    selectnode()
    var newnode = HBoxContainer.new()
    newnode.name = "HBoxContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_box_container_pressed() -> void:
    selectnode()
    var newnode = VBoxContainer.new()
    newnode.name = "VBoxContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_flow_container_pressed() -> void:
    selectnode()
    var newnode = FlowContainer.new()
    newnode.name = "FlowContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_flow_container_pressed() -> void:
    selectnode()
    var newnode = HFlowContainer.new()
    newnode.name = "HFlowContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_flow_container_pressed() -> void:
    selectnode()
    var newnode = VFlowContainer.new()
    newnode.name = "VFlowContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_split_container_pressed() -> void:
    selectnode()
    var newnode = SplitContainer.new()
    newnode.name = "SplitContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_split_container_pressed() -> void:
    selectnode()
    var newnode = HSplitContainer.new()
    newnode.name = "HSplitContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_split_container_pressed() -> void:
    selectnode()
    var newnode = VSplitContainer.new()
    newnode.name = "VSplitContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_grid_container_pressed() -> void:
    selectnode()
    var newnode = GridContainer.new()
    newnode.name = "GridContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_scroll_container_pressed() -> void:
    selectnode()
    var newnode = ScrollContainer.new()
    newnode.name = "ScrollContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_margin_container_pressed() -> void:
    selectnode()
    var newnode = MarginContainer.new()
    newnode.name = "MarginContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_aspect_ratio_container_pressed() -> void:
    selectnode()
    var newnode = AspectRatioContainer.new()
    newnode.name = "AspectRatioContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_center_container_pressed() -> void:
    selectnode()
    var newnode = CenterContainer.new()
    newnode.name = "CenterContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_sub_viewport_container_pressed() -> void:
    selectnode()
    var newnode = SubViewportContainer.new()
    newnode.name = "SubViewportContainer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_graph_element_pressed() -> void:
    selectnode()
    var newnode = GraphElement.new()
    newnode.name = "GraphElement"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_graph_frame_pressed() -> void:
    selectnode()
    var newnode = GraphFrame.new()
    newnode.name = "GraphFrame"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_graph_node_pressed() -> void:
    selectnode()
    var newnode = GraphNode.new()
    newnode.name = "GraphNode"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_color_picker_pressed() -> void:
    selectnode()
    var newnode = ColorPicker.new()
    newnode.name = "ColorPicker"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.



#------按钮
func _on_button_pressed() -> void:
    selectnode()
    var newnode = Button.new()
    newnode.name = "Button"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_check_box_pressed() -> void:
    selectnode()
    var newnode = CheckBox.new()
    newnode.name = "CheckBox"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_check_button_pressed() -> void:
    selectnode()
    var newnode = CheckButton.new()
    newnode.name = "CheckButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_color_picker_button_pressed() -> void:
    selectnode()
    var newnode = ColorPickerButton.new()
    newnode.name = "ColorPickerButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_menu_button_pressed() -> void:
    selectnode()
    var newnode = MenuButton.new()
    newnode.name = "MenuButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_option_button_pressed() -> void:
    selectnode()
    var newnode = OptionButton.new()
    newnode.name = "OptionButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_link_button_pressed() -> void:
    selectnode()
    var newnode = LinkButton.new()
    newnode.name = "LinkButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_texture_button_pressed() -> void:
    selectnode()
    var newnode = TextureButton.new()
    newnode.name = "TextureButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#------文本
func _on_label_pressed() -> void:
    selectnode()
    var newnode = Label.new()
    newnode.name = "Label"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_rich_text_label_pressed() -> void:
    selectnode()
    var newnode = RichTextLabel.new()
    newnode.name = "RichTextLabel"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_line_edit_pressed() -> void:
    selectnode()
    var newnode = LineEdit.new()
    newnode.name = "LineEdit"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_text_edit_pressed() -> void:
    selectnode()
    var newnode = TextEdit.new()
    newnode.name = "TextEdit"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_code_edit_pressed() -> void:
    selectnode()
    var newnode = CodeEdit.new()
    newnode.name = "CodeEdit"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_spin_box_pressed() -> void:
    selectnode()
    var newnode = SpinBox.new()
    newnode.name = "SpinBox"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#------图片
func _on_color_rect_pressed() -> void:
    selectnode()
    var newnode = ColorRect.new()
    newnode.name = "ColorRect"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_texture_rect_pressed() -> void:
    selectnode()
    var newnode = TextureRect.new()
    newnode.name = "TextureRect"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_nine_patch_rect_pressed() -> void:
    selectnode()
    var newnode = NinePatchRect.new()
    newnode.name = "NinePatchRect"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_graph_edit_pressed() -> void:
    selectnode()
    var newnode = GraphEdit.new()
    newnode.name = "GraphEdit"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#------进度条
func _on_progress_bar_pressed() -> void:
    selectnode()
    var newnode = ProgressBar.new()
    newnode.name = "ProgressBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_texture_progress_bar_pressed() -> void:
    selectnode()
    var newnode = TextureProgressBar.new()
    newnode.name = "TextureProgressBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_slider_pressed() -> void:
    selectnode()
    var newnode = HSlider.new()
    newnode.name = "HSlider"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_slider_pressed() -> void:
    selectnode()
    var newnode = VSlider.new()
    newnode.name = "VSlider"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_scroll_bar_pressed() -> void:
    selectnode()
    var newnode = HScrollBar.new()
    newnode.name = "HScrollBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_scroll_bar_pressed() -> void:
    selectnode()
    var newnode = VScrollBar.new()
    newnode.name = "VScrollBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#------布局
func _on_panel_pressed() -> void:
    selectnode()
    var newnode = Panel.new()
    newnode.name = "Panel"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_tab_bar_pressed() -> void:
    selectnode()
    var newnode = TabBar.new()
    newnode.name = "TabBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_tree_pressed() -> void:
    selectnode()
    var newnode = Tree.new()
    newnode.name = "Tree"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_item_list_pressed() -> void:
    selectnode()
    var newnode = ItemList.new()
    newnode.name = "ItemList"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_h_separator_pressed() -> void:
    selectnode()
    var newnode = HSeparator.new()
    newnode.name = "HSeparator"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_v_separator_pressed() -> void:
    selectnode()
    var newnode = VSeparator.new()
    newnode.name = "VSeparator"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_reference_rect_pressed() -> void:
    selectnode()
    var newnode = ReferenceRect.new()
    newnode.name = "ReferenceRect"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_menu_bar_pressed() -> void:
    selectnode()
    var newnode = MenuBar.new()
    newnode.name = "MenuBar"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_video_stream_player_pressed() -> void:
    selectnode()
    var newnode = VideoStreamPlayer.new()
    newnode.name = "VideoStreamPlayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.



#-----2d节点
func _on_node_pressed() -> void:
    selectnode()
    var newnode = Node.new()
    newnode.name = "Node"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_node_2d_pressed() -> void:
    selectnode()
    var newnode = Node2D.new()
    newnode.name = "Node2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_sprite_2d_pressed() -> void:
    selectnode()
    var newnode = Sprite2D.new()
    newnode.name = "Sprite2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_polygon_2d_pressed() -> void:
    selectnode()
    var newnode = Polygon2D.new()
    newnode.name = "Polygon2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_line_2d_pressed() -> void:
    selectnode()
    var newnode = Line2D.new()
    newnode.name = "Line2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_mesh_instance_2d_pressed() -> void:
    selectnode()
    var newnode = MeshInstance2D.new()
    newnode.name = "MeshInstance2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_multi_mesh_instance_2d_pressed() -> void:
    selectnode()
    var newnode = MultiMeshInstance2D.new()
    newnode.name = "MultiMeshInstance2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_marker_2d_pressed() -> void:
    selectnode()
    var newnode = Marker2D.new()
    newnode.name = "Marker2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_remote_transform_2d_pressed() -> void:
    selectnode()
    var newnode = RemoteTransform2D.new()
    newnode.name = "RemoteTransform2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_resource_preloader_pressed() -> void:
    selectnode()
    var newnode = ResourcePreloader.new()
    newnode.name = "ResourcePreloader"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

func _on_shader_globals_override_pressed() -> void:
    selectnode()
    var newnode = ShaderGlobalsOverride.new()
    newnode.name = "ShaderGlobalsOverride"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----物理节点
func _on_static_body_2d_pressed() -> void:
    selectnode()
    var newnode = StaticBody2D.new()
    newnode.name = "StaticBody2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_rigid_body_2d_pressed() -> void:
    selectnode()
    var newnode = RigidBody2D.new()
    newnode.name = "RigidBody2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_animatable_body_2d_pressed() -> void:
    selectnode()
    var newnode = AnimatableBody2D.new()
    newnode.name = "AnimatableBody2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_area_2d_pressed() -> void:
    selectnode()
    var newnode = Area2D.new()
    newnode.name = "Area2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_shape_cast_2d_pressed() -> void:
    selectnode()
    var newnode = ShapeCast2D.new()
    newnode.name = "ShapeCast2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_ray_cast_2d_pressed() -> void:
    selectnode()
    var newnode = RayCast2D.new()
    newnode.name = "RayCast2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_character_body_2d_pressed() -> void:
    selectnode()
    var newnode = CharacterBody2D.new()
    newnode.name = "CharacterBody2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_collision_shape_2d_pressed() -> void:
    selectnode()
    var newnode = CollisionShape2D.new()
    newnode.name = "CollisionShape2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_collision_polygon_2d_pressed() -> void:
    selectnode()
    var newnode = CollisionPolygon2D.new()
    newnode.name = "CollisionPolygon2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----动画节点
func _on_animated_sprite_2d_pressed() -> void:
    selectnode()
    var newnode = AnimatedSprite2D.new()
    newnode.name = "AnimatedSprite2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_animation_player_pressed() -> void:
    selectnode()
    var newnode = AnimationPlayer.new()
    newnode.name = "AnimationPlayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_animation_tree_pressed() -> void:
    selectnode()
    var newnode = AnimationTree.new()
    newnode.name = "AnimationTree"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.



#-----骨骼
func _on_physical_bone_2d_pressed() -> void:
    selectnode()
    var newnode = PhysicalBone2D.new()
    newnode.name = "PhysicalBone2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_skeleton_2d_pressed() -> void:
    selectnode()
    var newnode = Skeleton2D.new()
    newnode.name = "Skeleton2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_bone_2d_pressed() -> void:
    selectnode()
    var newnode = Bone2D.new()
    newnode.name = "Bone2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----粒子
func _on_cpu_particles_2d_pressed() -> void:
    selectnode()
    var newnode = CPUParticles2D.new()
    newnode.name = "CPUParticles2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_gpu_particles_2d_pressed() -> void:
    selectnode()
    var newnode = GPUParticles2D.new()
    newnode.name = "GPUParticles2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----光照
func _on_directional_light_2d_pressed() -> void:
    selectnode()
    var newnode = DirectionalLight2D.new()
    newnode.name = "DirectionalLight2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_point_light_2d_pressed() -> void:
    selectnode()
    var newnode = PointLight2D.new()
    newnode.name = "PointLight2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_light_occluder_2d_pressed() -> void:
    selectnode()
    var newnode = LightOccluder2D.new()
    newnode.name = "LightOccluder2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#-----导航
func _on_navigation_region_2d_pressed() -> void:
    selectnode()
    var newnode = NavigationRegion2D.new()
    newnode.name = "NavigationRegion2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_navigation_link_2d_pressed() -> void:
    selectnode()
    var newnode = NavigationLink2D.new()
    newnode.name = "NavigationLink2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_navigation_obstacle_2d_pressed() -> void:
    selectnode()
    var newnode = NavigationObstacle2D.new()
    newnode.name = "NavigationObstacle2D"
    parent_node.add_child(newnode)
    pass # Replace with function body.


func _on_navigation_agent_2d_pressed() -> void:
    selectnode()
    var newnode = NavigationAgent2D.new()
    newnode.name = "NavigationAgent2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_path_2d_pressed() -> void:
    selectnode()
    var newnode = Path2D.new()
    newnode.name = "Path2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_path_follow_2d_pressed() -> void:
    selectnode()
    var newnode = PathFollow2D.new()
    newnode.name = "PathFollow2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----视效
func _on_canvas_layer_pressed() -> void:
    selectnode()
    var newnode = CanvasLayer.new()
    newnode.name = "CanvasLayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_canvas_group_pressed() -> void:
    selectnode()
    var newnode = CanvasGroup.new()
    newnode.name = "CanvasGroup"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_canvas_modulate_pressed() -> void:
    selectnode()
    var newnode = CanvasModulate.new()
    newnode.name = "CanvasModulate"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_parallax_background_pressed() -> void:
    selectnode()
    var newnode = ParallaxBackground.new()
    newnode.name = "ParallaxBackground"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_parallax_2d_pressed() -> void:
    selectnode()
    var newnode = Parallax2D.new()
    newnode.name = "Parallax2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_parallax_layer_pressed() -> void:
    selectnode()
    var newnode = ParallaxLayer.new()
    newnode.name = "ParallaxLayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_world_environment_pressed() -> void:
    selectnode()
    var newnode = WorldEnvironment.new()
    newnode.name = "WorldEnvironment"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_back_buffer_copy_pressed() -> void:
    selectnode()
    var newnode = BackBufferCopy.new()
    newnode.name = "BackBufferCopy"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_pressed() -> void:
    selectnode()
    var newnode = VisibleOnScreenNotifier2D.new()
    newnode.name = "VisibleOnScreenNotifier2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_pressed() -> void:
    selectnode()
    var newnode = VisibleOnScreenEnabler2D.new()
    newnode.name = "VisibleOnScreenEnabler2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#-----音频
func _on_audio_stream_player_pressed() -> void:
    selectnode()
    var newnode = AudioStreamPlayer.new()
    newnode.name = "AudioStreamPlayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_audio_stream_player_2d_pressed() -> void:
    selectnode()
    var newnode = AudioStreamPlayer2D.new()
    newnode.name = "AudioStreamPlayer2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_audio_listener_2d_pressed() -> void:
    selectnode()
    var newnode = AudioListener2D.new()
    newnode.name = "AudioListener2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#-----特殊
func _on_camera_2d_pressed() -> void:
    selectnode()
    var newnode = Camera2D.new()
    newnode.name = "Camera2D"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_timer_pressed() -> void:
    selectnode()
    var newnode = Timer.new()
    newnode.name = "Timer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_tile_map_layer_pressed() -> void:
    selectnode()
    var newnode = TileMapLayer.new()
    newnode.name = "TileMapLayer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_touch_screen_button_pressed() -> void:
    selectnode()
    var newnode = TouchScreenButton.new()
    newnode.name = "TouchScreenButton"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#-----网络
func _on_http_request_pressed() -> void:
    selectnode()
    var newnode = HTTPRequest.new()
    newnode.name = "HTTPRequest"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_multiplayer_spawner_pressed() -> void:
    selectnode()
    var newnode = MultiplayerSpawner.new()
    newnode.name = "MultiplayerSpawner"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_multiplayer_synchronizer_pressed() -> void:
    selectnode()
    var newnode = MultiplayerSynchronizer.new()
    newnode.name = "MultiplayerSynchronizer"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----插件
func _on_editor_plugin_pressed() -> void:
    selectnode()
    var newnode = EditorPlugin.new()
    newnode.name = "EditorPlugin"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_grid_map_editor_plugin_pressed() -> void:
    selectnode()
    var newnode = GridMapEditorPlugin.new()
    newnode.name = "GridMapEditorPlugin"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_status_indicator_pressed() -> void:
    selectnode()
    var newnode = StatusIndicator.new()
    newnode.name = "StatusIndicator"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


#-----窗口
func _on_window_pressed() -> void:
    selectnode()
    var newnode = Window.new()
    newnode.name = "Window"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#----对话框
func _on_accept_dialog_pressed() -> void:
    selectnode()
    var newnode = AcceptDialog.new()
    newnode.name = "AcceptDialog"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_confirmation_dialog_pressed() -> void:
    selectnode()
    var newnode = ConfirmationDialog.new()
    newnode.name = "ConfirmationDialog"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_file_dialog_pressed() -> void:
    selectnode()
    var newnode = FileDialog.new()
    newnode.name = "FileDialog"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.

#----弹出框
func _on_popup_pressed() -> void:
    selectnode()
    var newnode = Popup.new()
    newnode.name = "Popup"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_popup_menu_pressed() -> void:
    selectnode()
    var newnode = PopupMenu.new()
    newnode.name = "PopupMenu"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_popup_panel_pressed() -> void:
    selectnode()
    var newnode = PopupPanel.new()
    newnode.name = "PopupPanel"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.


func _on_sub_viewport_pressed() -> void:
    selectnode()
    var newnode = SubViewport.new()
    newnode.name = "SubViewport"
    parent_node.add_child(newnode)
    newnode.owner = editor.get_edited_scene_root()
    pass # Replace with function body.
