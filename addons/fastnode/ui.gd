@tool
extends Control
var 按钮宽度:int=90
var ed: EditorPlugin = null
var 容器数组:Array[GridContainer]=[]
var 滚动容器数组:Array=[]
var 按钮数组:Array=[]
# 重构后的插件节点字典（合并中文名称、节点类、图片路径）
var 插件节点字典 = {
	# 容器类
	"Control": {
		"名称": "容器",
		"代码": Control,
		"图片": preload("res://addons/fastnode/icons/Control.svg")
	},
	"Container": {
		"名称": "容器",
		"代码": Container,
		"图片": preload("res://addons/fastnode/icons/Container.svg")
	},
	"PanelContainer": {
		"名称": "面板容器",
		"代码": PanelContainer,
		"图片": preload("res://addons/fastnode/icons/PanelContainer.svg")
	},
	"TabContainer": {
		"名称": "标签容器",
		"代码": TabContainer,
		"图片": preload("res://addons/fastnode/icons/TabContainer.svg")
	},
	"BoxContainer": {
		"名称": "盒子容器",
		"代码": BoxContainer,
		"图片": preload("res://addons/fastnode/icons/BoxContainer.svg")
	},
	"HBoxContainer": {
		"名称": "水平盒子容器",
		"代码": HBoxContainer,
		"图片": preload("res://addons/fastnode/icons/HBoxContainer.svg")
	},
	"VBoxContainer": {
		"名称": "垂直盒子容器",
		"代码": VBoxContainer,
		"图片": preload("res://addons/fastnode/icons/VBoxContainer.svg")
	},
	"FlowContainer": {
		"名称": "流式容器",
		"代码": FlowContainer,
		"图片": preload("res://addons/fastnode/icons/FlowContainer.svg")
	},
	"HFlowContainer": {
		"名称": "水平流式容器",
		"代码": HFlowContainer,
		"图片": preload("res://addons/fastnode/icons/HFlowContainer.svg")
	},
	"VFlowContainer": {
		"名称": "垂直流式容器",
		"代码": VFlowContainer,
		"图片": preload("res://addons/fastnode/icons/VFlowContainer.svg")
	},
	"SplitContainer": {
		"名称": "分割容器",
		"代码": SplitContainer,
		"图片": preload("res://addons/fastnode/icons/SplitContainer.svg")
	},
	"HSplitContainer": {
		"名称": "水平分割容器",
		"代码": HSplitContainer,
		"图片": preload("res://addons/fastnode/icons/HSplitContainer.svg")
	},
	"VSplitContainer": {
		"名称": "垂直分割容器",
		"代码": VSplitContainer,
		"图片": preload("res://addons/fastnode/icons/VSplitContainer.svg")
	},
	"GridContainer": {
		"名称": "网格容器",
		"代码": GridContainer,
		"图片": preload("res://addons/fastnode/icons/GridContainer.svg")
	},
	"ScrollContainer": {
		"名称": "滚动容器",
		"代码": ScrollContainer,
		"图片": preload("res://addons/fastnode/icons/ScrollContainer.svg")
	},
	"MarginContainer": {
		"名称": "边距容器",
		"代码": MarginContainer,
		"图片": preload("res://addons/fastnode/icons/MarginContainer.svg")
	},
	"AspectRatioContainer": {
		"名称": "宽高比容器",
		"代码": AspectRatioContainer,
		"图片": preload("res://addons/fastnode/icons/AspectRatioContainer.svg")
	},
	"CenterContainer": {
		"名称": "居中容器",
		"代码": CenterContainer,
		"图片": preload("res://addons/fastnode/icons/CenterContainer.svg")
	},
	"SubViewportContainer": {
		"名称": "子视口容器",
		"代码": SubViewportContainer,
		"图片": preload("res://addons/fastnode/icons/SubViewportContainer.svg")
	},
	"GraphElement": {
		"名称": "图形元素",
		"代码": GraphElement,
		"图片": preload("res://addons/fastnode/icons/GraphElement.svg")
	},
	"GraphFrame": {
		"名称": "图形框架",
		"代码": GraphFrame,
		"图片": preload("res://addons/fastnode/icons/GraphFrame.svg")
	},
	"GraphNode": {
		"名称": "图形节点",
		"代码": GraphNode,
		"图片": preload("res://addons/fastnode/icons/GraphNode.svg")
	},
	"ColorPicker": {
		"名称": "颜色选择器",
		"代码": ColorPicker,
		"图片": preload("res://addons/fastnode/icons/ColorPicker.svg")
	},
	# 按钮类
	"Button": {
		"名称": "按钮",
		"代码": Button,
		"图片": preload("res://addons/fastnode/icons/Button.svg")
	},
	"CheckBox": {
		"名称": "复选框",
		"代码": CheckBox,
		"图片": preload("res://addons/fastnode/icons/CheckBox.svg")
	},
	"CheckButton": {
		"名称": "复选按钮",
		"代码": CheckButton,
		"图片": preload("res://addons/fastnode/icons/CheckButton.svg")
	},
	"ColorPickerButton": {
		"名称": "颜色选择按钮",
		"代码": ColorPickerButton,
		"图片": preload("res://addons/fastnode/icons/ColorPickerButton.svg")
	},
	"MenuButton": {
		"名称": "菜单按钮",
		"代码": MenuButton,
		"图片": preload("res://addons/fastnode/icons/MenuButton.svg")
	},
	"OptionButton": {
		"名称": "选项按钮",
		"代码": OptionButton,
		"图片": preload("res://addons/fastnode/icons/OptionButton.svg")
	},
	"LinkButton": {
		"名称": "链接按钮",
		"代码": LinkButton,
		"图片": preload("res://addons/fastnode/icons/LinkButton.svg")
	},
	"TextureButton": {
		"名称": "纹理按钮",
		"代码": TextureButton,
		"图片": preload("res://addons/fastnode/icons/TextureButton.svg")
	},
	# 文本类
	"Label": {
		"名称": "标签",
		"代码": Label,
		"图片": preload("res://addons/fastnode/icons/Label.svg")
	},
	"RichTextLabel": {
		"名称": "富文本标签",
		"代码": RichTextLabel,
		"图片": preload("res://addons/fastnode/icons/RichTextLabel.svg")
	},
	"LineEdit": {
		"名称": "单行输入框",
		"代码": LineEdit,
		"图片": preload("res://addons/fastnode/icons/LineEdit.svg")
	},
	"TextEdit": {
		"名称": "多行文本编辑框",
		"代码": TextEdit,
		"图片": preload("res://addons/fastnode/icons/TextEdit.svg")
	},
	"CodeEdit": {
		"名称": "代码编辑框",
		"代码": CodeEdit,
		"图片": preload("res://addons/fastnode/icons/CodeEdit.svg")
	},
	"SpinBox": {
		"名称": "数字输入框",
		"代码": SpinBox,
		"图片": preload("res://addons/fastnode/icons/SpinBox.svg")
	},
	# 图片类
	"ColorRect": {
		"名称": "颜色矩形",
		"代码": ColorRect,
		"图片": preload("res://addons/fastnode/icons/ColorRect.svg")
	},
	"TextureRect": {
		"名称": "纹理矩形",
		"代码": TextureRect,
		"图片": preload("res://addons/fastnode/icons/TextureRect.svg")
	},
	"NinePatchRect": {
		"名称": "九宫格矩形",
		"代码": NinePatchRect,
		"图片": preload("res://addons/fastnode/icons/NinePatchRect.svg")
	},
	"GraphEdit": {
		"名称": "图形编辑框",
		"代码": GraphEdit,
		"图片": preload("res://addons/fastnode/icons/GraphEdit.svg")
	},
	# 进度条类
	"ProgressBar": {
		"名称": "进度条",
		"代码": ProgressBar,
		"图片": preload("res://addons/fastnode/icons/ProgressBar.svg")
	},
	"TextureProgressBar": {
		"名称": "纹理进度条",
		"代码": TextureProgressBar,
		"图片": preload("res://addons/fastnode/icons/TextureProgressBar.svg")
	},
	"HSlider": {
		"名称": "水平滑块",
		"代码": HSlider,
		"图片": preload("res://addons/fastnode/icons/HSlider.svg")
	},
	"VSlider": {
		"名称": "垂直滑块",
		"代码": VSlider,
		"图片": preload("res://addons/fastnode/icons/VSlider.svg")
	},
	"HScrollBar": {
		"名称": "水平滚动条",
		"代码": HScrollBar,
		"图片": preload("res://addons/fastnode/icons/HScrollBar.svg")
	},
	"VScrollBar": {
		"名称": "垂直滚动条",
		"代码": VScrollBar,
		"图片": preload("res://addons/fastnode/icons/VScrollBar.svg")
	},
	# 布局类
	"Panel": {
		"名称": "面板",
		"代码": Panel,
		"图片": preload("res://addons/fastnode/icons/Panel.svg")
	},
	"TabBar": {
		"名称": "标签栏",
		"代码": TabBar,
		"图片": preload("res://addons/fastnode/icons/TabBar.svg")
	},
	"Tree": {
		"名称": "树形控件",
		"代码": Tree,
		"图片": preload("res://addons/fastnode/icons/Tree.svg")
	},
	"ItemList": {
		"名称": "项目列表",
		"代码": ItemList,
		"图片": preload("res://addons/fastnode/icons/ItemList.svg")
	},
	"HSeparator": {
		"名称": "水平分隔线",
		"代码": HSeparator,
		"图片": preload("res://addons/fastnode/icons/HSeparator.svg")
	},
	"VSeparator": {
		"名称": "垂直分隔线",
		"代码": VSeparator,
		"图片": preload("res://addons/fastnode/icons/VSeparator.svg")
	},
	"ReferenceRect": {
		"名称": "参考矩形",
		"代码": ReferenceRect,
		"图片": preload("res://addons/fastnode/icons/ReferenceRect.svg")
	},
	"MenuBar": {
		"名称": "菜单栏",
		"代码": MenuBar,
		"图片": preload("res://addons/fastnode/icons/MenuBar.svg")
	},
	"VideoStreamPlayer": {
		"名称": "视频流播放器",
		"代码": VideoStreamPlayer,
		"图片": preload("res://addons/fastnode/icons/VideoStreamPlayer.svg")
	},
	# 2D节点类
	"Node": {
		"名称": "节点",
		"代码": Node,
		"图片": preload("res://addons/fastnode/icons/Node.svg")
	},
	"Node2D": {
		"名称": "2D节点",
		"代码": Node2D,
		"图片": preload("res://addons/fastnode/icons/Node2D.svg")
	},
	"Sprite2D": {
		"名称": "2D精灵",
		"代码": Sprite2D,
		"图片": preload("res://addons/fastnode/icons/Sprite2D.svg")
	},
	"Polygon2D": {
		"名称": "2D多边形",
		"代码": Polygon2D,
		"图片": preload("res://addons/fastnode/icons/Polygon2D.svg")
	},
	"Line2D": {
		"名称": "2D线条",
		"代码": Line2D,
		"图片": preload("res://addons/fastnode/icons/Line2D.svg")
	},
	"MeshInstance2D": {
		"名称": "2D网格实例",
		"代码": MeshInstance2D,
		"图片": preload("res://addons/fastnode/icons/MeshInstance2D.svg")
	},
	"MultiMeshInstance2D": {
		"名称": "2D多网格实例",
		"代码": MultiMeshInstance2D,
		"图片": preload("res://addons/fastnode/icons/MultiMeshInstance2D.svg")
	},
	"Marker2D": {
		"名称": "2D标记",
		"代码": Marker2D,
		"图片": preload("res://addons/fastnode/icons/Marker2D.svg")
	},
	"RemoteTransform2D": {
		"名称": "2D远程变换",
		"代码": RemoteTransform2D,
		"图片": preload("res://addons/fastnode/icons/RemoteTransform2D.svg")
	},
	"ResourcePreloader": {
		"名称": "资源预加载器",
		"代码": ResourcePreloader,
		"图片": preload("res://addons/fastnode/icons/ResourcePreloader.svg")
	},
	"ShaderGlobalsOverride": {
		"名称": "着色器全局覆盖",
		"代码": ShaderGlobalsOverride,
		"图片": preload("res://addons/fastnode/icons/ShaderGlobalsOverride.svg")
	},
	# 2D物理类
	"StaticBody2D": {
		"名称": "2D静态体",
		"代码": StaticBody2D,
		"图片": preload("res://addons/fastnode/icons/StaticBody2D.svg")
	},
	"RigidBody2D": {
		"名称": "2D刚体",
		"代码": RigidBody2D,
		"图片": preload("res://addons/fastnode/icons/RigidBody2D.svg")
	},
	"AnimatableBody2D": {
		"名称": "2D可动画体",
		"代码": AnimatableBody2D,
		"图片": preload("res://addons/fastnode/icons/AnimatableBody2D.svg")
	},
	"Area2D": {
		"名称": "2D区域",
		"代码": Area2D,
		"图片": preload("res://addons/fastnode/icons/Area2D.svg")
	},
	"ShapeCast2D": {
		"名称": "2D形状检测",
		"代码": ShapeCast2D,
		"图片": preload("res://addons/fastnode/icons/ShapeCast2D.svg")
	},
	"RayCast2D": {
		"名称": "2D射线检测",
		"代码": RayCast2D,
		"图片": preload("res://addons/fastnode/icons/RayCast2D.svg")
	},
	"CharacterBody2D": {
		"名称": "2D角色体",
		"代码": CharacterBody2D,
		"图片": preload("res://addons/fastnode/icons/CharacterBody2D.svg")
	},
	"CollisionShape2D": {
		"名称": "2D碰撞形状",
		"代码": CollisionShape2D,
		"图片": preload("res://addons/fastnode/icons/CollisionShape2D.svg")
	},
	"CollisionPolygon2D": {
		"名称": "2D碰撞多边形",
		"代码": CollisionPolygon2D,
		"图片": preload("res://addons/fastnode/icons/CollisionPolygon2D.svg")
	},
	# 动画类
	"AnimatedSprite2D": {
		"名称": "2D动画精灵",
		"代码": AnimatedSprite2D,
		"图片": preload("res://addons/fastnode/icons/AnimatedSprite2D.svg")
	},
	"AnimationPlayer": {
		"名称": "动画播放器",
		"代码": AnimationPlayer,
		"图片": preload("res://addons/fastnode/icons/AnimationPlayer.svg")
	},
	"AnimationTree": {
		"名称": "动画树",
		"代码": AnimationTree,
		"图片": preload("res://addons/fastnode/icons/AnimationTree.svg")
	},
	# 骨骼类
	"PhysicalBone2D": {
		"名称": "2D物理骨骼",
		"代码": PhysicalBone2D,
		"图片": preload("res://addons/fastnode/icons/PhysicalBone2D.svg")
	},
	"Skeleton2D": {
		"名称": "2D骨骼",
		"代码": Skeleton2D,
		"图片": preload("res://addons/fastnode/icons/Skeleton2D.svg")
	},
	"Bone2D": {
		"名称": "2D骨骼节点",
		"代码": Bone2D,
		"图片": preload("res://addons/fastnode/icons/Bone2D.svg")
	},
	# 粒子类
	"CPUParticles2D": {
		"名称": "2D CPU粒子",
		"代码": CPUParticles2D,
		"图片": preload("res://addons/fastnode/icons/CPUParticles2D.svg")
	},
	"GPUParticles2D": {
		"名称": "2D GPU粒子",
		"代码": GPUParticles2D,
		"图片": preload("res://addons/fastnode/icons/GPUParticles2D.svg")
	},
	# 光照类
	"DirectionalLight2D": {
		"名称": "2D方向光",
		"代码": DirectionalLight2D,
		"图片": preload("res://addons/fastnode/icons/DirectionalLight2D.svg")
	},
	"PointLight2D": {
		"名称": "2D点光源",
		"代码": PointLight2D,
		"图片": preload("res://addons/fastnode/icons/PointLight2D.svg")
	},
	"LightOccluder2D": {
		"名称": "2D光遮挡器",
		"代码": LightOccluder2D,
		"图片": preload("res://addons/fastnode/icons/LightOccluder2D.svg")
	},
	# 导航类
	"NavigationRegion2D": {
		"名称": "2D导航区域",
		"代码": NavigationRegion2D,
		"图片": preload("res://addons/fastnode/icons/NavigationRegion2D.svg")
	},
	"NavigationLink2D": {
		"名称": "2D导航链接",
		"代码": NavigationLink2D,
		"图片": preload("res://addons/fastnode/icons/NavigationLink2D.svg")
	},
	"NavigationObstacle2D": {
		"名称": "2D导航障碍物",
		"代码": NavigationObstacle2D,
		"图片": preload("res://addons/fastnode/icons/NavigationObstacle2D.svg")
	},
	"NavigationAgent2D": {
		"名称": "2D导航代理",
		"代码": NavigationAgent2D,
		"图片": preload("res://addons/fastnode/icons/NavigationAgent2D.svg")
	},
	"Path2D": {
		"名称": "2D路径",
		"代码": Path2D,
		"图片": preload("res://addons/fastnode/icons/Path2D.svg")
	},
	"PathFollow2D": {
		"名称": "2D路径跟随",
		"代码": PathFollow2D,
		"图片": preload("res://addons/fastnode/icons/PathFollow2D.svg")
	},
	# 视效类
	"CanvasLayer": {
		"名称": "画布层",
		"代码": CanvasLayer,
		"图片": preload("res://addons/fastnode/icons/CanvasLayer.svg")
	},
	"CanvasGroup": {
		"名称": "画布组",
		"代码": CanvasGroup,
		"图片": preload("res://addons/fastnode/icons/CanvasGroup.svg")
	},
	"CanvasModulate": {
		"名称": "画布调制",
		"代码": CanvasModulate,
		"图片": preload("res://addons/fastnode/icons/CanvasModulate.svg")
	},
	"ParallaxBackground": {
		"名称": "视差背景",
		"代码": ParallaxBackground,
		"图片": preload("res://addons/fastnode/icons/ParallaxBackground.svg")
	},
	"Parallax2D": {
		"名称": "2D视差",
		"代码": Parallax2D,
		"图片": preload("res://addons/fastnode/icons/Parallax2D.svg")
	},
	"ParallaxLayer": {
		"名称": "视差层",
		"代码": ParallaxLayer,
		"图片": preload("res://addons/fastnode/icons/ParallaxLayer.svg")
	},
	"WorldEnvironment": {
		"名称": "世界环境",
		"代码": WorldEnvironment,
		"图片": preload("res://addons/fastnode/icons/WorldEnvironment.svg")
	},
	"BackBufferCopy": {
		"名称": "后台缓冲区复制",
		"代码": BackBufferCopy,
		"图片": preload("res://addons/fastnode/icons/BackBufferCopy.svg")
	},
	"VisibleOnScreenNotifier2D": {
		"名称": "2D屏幕可见通知器",
		"代码": VisibleOnScreenNotifier2D,
		"图片": preload("res://addons/fastnode/icons/VisibleOnScreenNotifier2D.svg")
	},
	"VisibleOnScreenEnabler2D": {
		"名称": "2D屏幕可见启用器",
		"代码": VisibleOnScreenEnabler2D,
		"图片": preload("res://addons/fastnode/icons/VisibleOnScreenEnabler2D.svg")
	},
	# 音频类
	"AudioStreamPlayer": {
		"名称": "音频流播放器",
		"代码": AudioStreamPlayer,
		"图片": preload("res://addons/fastnode/icons/AudioStreamPlayer.svg")
	},
	"AudioStreamPlayer2D": {
		"名称": "2D音频流播放器",
		"代码": AudioStreamPlayer2D,
		"图片": preload("res://addons/fastnode/icons/AudioStreamPlayer2D.svg")
	},
	"AudioListener2D": {
		"名称": "2D音频监听器",
		"代码": AudioListener2D,
		"图片": preload("res://addons/fastnode/icons/AudioListener2D.svg")
	},
	# 特殊类
	"Camera2D": {
		"名称": "2D相机",
		"代码": Camera2D,
		"图片": preload("res://addons/fastnode/icons/Camera2D.svg")
	},
	"Timer": {
		"名称": "计时器",
		"代码": Timer,
		"图片": preload("res://addons/fastnode/icons/Timer.svg")
	},
	"TileMapLayer": {
		"名称": "瓦片地图层",
		"代码": TileMapLayer,
		"图片": preload("res://addons/fastnode/icons/TileMapLayer.svg")
	},
	"TouchScreenButton": {
		"名称": "触摸屏按钮",
		"代码": TouchScreenButton,
		"图片": preload("res://addons/fastnode/icons/TouchScreenButton.svg")
	},
	# 网络类
	"HTTPRequest": {
		"名称": "HTTP请求",
		"代码": HTTPRequest,
		"图片": preload("res://addons/fastnode/icons/HTTPRequest.svg")
	},
	"MultiplayerSpawner": {
		"名称": "多人游戏生成器",
		"代码": MultiplayerSpawner,
		"图片": preload("res://addons/fastnode/icons/MultiplayerSpawner.svg")
	},
	"MultiplayerSynchronizer": {
		"名称": "多人游戏同步器",
		"代码": MultiplayerSynchronizer,
		"图片": preload("res://addons/fastnode/icons/MultiplayerSynchronizer.svg")
	},
	# 插件类
	"EditorPlugin": {
		"名称": "编辑器插件",
		"代码": EditorPlugin,
		"图片": preload("res://addons/fastnode/icons/EditorPlugin.svg")
	},
	"GridMapEditorPlugin": {
		"名称": "网格地图编辑器插件",
		"代码": GridMapEditorPlugin,
		"图片": null
	},
	"StatusIndicator": {
		"名称": "状态指示器",
		"代码": StatusIndicator,
		"图片": preload("res://addons/fastnode/icons/StatusIndicator.svg")
	},
	# 窗口类
	"Window": {
		"名称": "窗口",
		"代码": Window,
		"图片": preload("res://addons/fastnode/icons/Window.svg")
	},
	# 对话框类
	"AcceptDialog": {
		"名称": "确认对话框",
		"代码": AcceptDialog,
		"图片": preload("res://addons/fastnode/icons/AcceptDialog.svg")
	},
	"ConfirmationDialog": {
		"名称": "确认提示框",
		"代码": ConfirmationDialog,
		"图片": preload("res://addons/fastnode/icons/ConfirmationDialog.svg")
	},
	"FileDialog": {
		"名称": "文件对话框",
		"代码": FileDialog,
		"图片": preload("res://addons/fastnode/icons/FileDialog.svg")
	},
	# 弹出框类
	"Popup": {
		"名称": "弹出框",
		"代码": Popup,
		"图片": preload("res://addons/fastnode/icons/Popup.svg")
	},
	"PopupMenu": {
		"名称": "弹出菜单",
		"代码": PopupMenu,
		"图片": preload("res://addons/fastnode/icons/PopupMenu.svg")
	},
	"PopupPanel": {
		"名称": "弹出面板",
		"代码": PopupPanel,
		"图片": preload("res://addons/fastnode/icons/PopupPanel.svg")
	},
	"SubViewport": {
		"名称": "子视口",
		"代码": SubViewport,
		"图片": preload("res://addons/fastnode/icons/SubViewport.svg")
	}
}
# 分类名称(字符串) 作为键，对应节点名称列表(字符串数组) 作为值
var 节点类型字典 = {
	"容器类": [
		"Container", "PanelContainer", "TabContainer", "BoxContainer",
		"HBoxContainer", "VBoxContainer", "FlowContainer", "HFlowContainer",
		"VFlowContainer", "SplitContainer", "HSplitContainer", "VSplitContainer",
		"GridContainer", "ScrollContainer", "MarginContainer", "AspectRatioContainer",
		"CenterContainer", "SubViewportContainer", "GraphElement", "GraphFrame",
		"GraphNode", "ColorPicker"],
	"按钮类": [
		"Button", "CheckBox", "CheckButton", "ColorPickerButton",
		"MenuButton", "OptionButton", "LinkButton", "TextureButton"],
	"文本类": ["Label", "RichTextLabel", "LineEdit", "TextEdit", "CodeEdit", "SpinBox"],
	"图片类": ["ColorRect", "TextureRect", "NinePatchRect", "GraphEdit"],
	"进度条类": ["ProgressBar", "TextureProgressBar", "HSlider", "VSlider","HScrollBar", "VScrollBar"],
	"布局类": [
		"Panel", "TabBar", "Tree", "ItemList", "HSeparator",
		"VSeparator", "ReferenceRect", "MenuBar", "VideoStreamPlayer"],
	"2D节点类": [
		"Node", "Node2D", "Sprite2D", "Polygon2D", "Line2D",
		"MeshInstance2D", "MultiMeshInstance2D", "Marker2D","RemoteTransform2D"],
	"2D物理类": [
		"StaticBody2D", "RigidBody2D", "AnimatableBody2D", "Area2D",
		"ShapeCast2D", "RayCast2D", "CharacterBody2D", "CollisionShape2D","CollisionPolygon2D"],
	"动画类": ["AnimatedSprite2D", "AnimationPlayer", "AnimationTree"],
	"骨骼类": ["PhysicalBone2D", "Skeleton2D", "Bone2D"],
	"粒子类": ["CPUParticles2D", "GPUParticles2D"],
	"光照类": ["DirectionalLight2D", "PointLight2D", "LightOccluder2D"],
	"导航类": [
		"NavigationRegion2D", "NavigationLink2D", "NavigationObstacle2D",
		"NavigationAgent2D", "Path2D", "PathFollow2D"],
	"视效类": [
		"CanvasLayer", "CanvasGroup", "CanvasModulate", "ParallaxBackground",
		"Parallax2D", "ParallaxLayer", "WorldEnvironment", "BackBufferCopy",
		"VisibleOnScreenNotifier2D", "VisibleOnScreenEnabler2D"],
	"音频类": ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioListener2D"],
	"特殊类": ["Camera2D", "Timer", "TileMapLayer", "TouchScreenButton"],
	"网络类": ["HTTPRequest", "MultiplayerSpawner", "MultiplayerSynchronizer"],
	"插件类": ["EditorPlugin", "GridMapEditorPlugin", "StatusIndicator"],
	"窗口类": ["Window"],
	"对话框类": ["AcceptDialog", "ConfirmationDialog", "FileDialog"],
	"弹出框类": ["Popup", "PopupMenu", "PopupPanel", "SubViewport"],
	"加载":["ResourcePreloader", "ShaderGlobalsOverride"]}
var 目录 = {
	"UI": ["容器类", "按钮类", "文本类", "图片类", "进度条类","布局类"],
	"2D": ["2D节点类", "2D物理类", "骨骼类","光照类", "导航类", ],
	"功能": ["特殊类", "音频类", "动画类"],
	"其他": ["网络类", "插件类", "视效类", "粒子类", "窗口类", "对话框类", "弹出框类","加载"]
}
var 缓存尺寸=-1
func _ready() -> void:
	resized.connect(func():
		if visible:
			if 缓存尺寸==-1 or abs(size.x - 缓存尺寸) >= 10.0:
				缓存尺寸=size.x
				一键设置())
	快速生成结构()
	visibility_changed.connect(func():if visible:一键设置())
func 一键设置():
	await get_tree().process_frame
	await get_tree().process_frame
	var 平均宽度字典={}
	var 我是谁的子节点={}
	if size.x<320:
		按钮宽度=int(clamp(size.x/2,100,150))
		for 节点 in 按钮数组:
			节点.custom_minimum_size=Vector2(按钮宽度,50)
			节点.size=Vector2(按钮宽度,50)
			节点.text_overrun_behavior=TextServer.OVERRUN_TRIM_CHAR
		print("按钮宽度:",按钮宽度,"/",size)
		var 容量:int=max(1,int(size.x/按钮宽度))
		for 节点 in 容器数组:
			节点.columns=容量
	else :
		for 节点 in 容器数组:
			var 总宽度=0
			for 子节点 in 节点.get_children():
				子节点.custom_minimum_size=Vector2(0,50)
				子节点.text_overrun_behavior=TextServer.OVERRUN_NO_TRIMMING
				总宽度+=子节点.get_combined_minimum_size().x
				我是谁的子节点[子节点]=节点
			var 平均宽度=总宽度/节点.get_children().size()+5
			平均宽度字典[节点]=平均宽度
			for 子节点 in 节点.get_children():
				if 子节点.get_combined_minimum_size().x>平均宽度:
					子节点.custom_minimum_size=Vector2(平均宽度,50)
					子节点.size=Vector2(平均宽度,50)
					子节点.text_overrun_behavior=TextServer.OVERRUN_TRIM_CHAR
			var 容量:int=max(1,int(size.x/平均宽度))
			print("平均宽度:",平均宽度,"/",size,"/",容量)
			节点.columns=容量
	for 节点 in 滚动容器数组:
		节点.custom_minimum_size=size+Vector2(-1,-80)
	await get_tree().process_frame
	await get_tree().process_frame
	if size.x>=320:
		for 子节点 in 按钮数组:
			var 平均宽度=平均宽度字典[我是谁的子节点[子节点]]
			if 子节点.get_combined_minimum_size().x>平均宽度:
				子节点.custom_minimum_size=Vector2(平均宽度,50)
				子节点.size=Vector2(平均宽度,50)
				子节点.text_overrun_behavior=TextServer.OVERRUN_TRIM_CHAR
func _on_刷新_pressed() -> void:
	if is_instance_valid(ed.面板): #如果面板存在
		if visible:一键设置()
# 改造后的生成结构函数（适配新字典）
func 快速生成结构():
	容器数组 = []
	滚动容器数组 = []
	按钮数组 = []
	for 目录名 in 目录:
		var 滚动区=ScrollContainer.new()
		滚动区.name = 目录名
		滚动区.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
		var 垂直容器=VBoxContainer.new()
		for 功能区名 in 目录[目录名]:
			var 文本=Label.new()
			文本.text=功能区名  # 功能区名称本身已是中文，无需修改
			垂直容器.add_child(文本)
			var 容器=GridContainer.new()
			#print("##",功能区名)
			for 节点按钮 in 节点类型字典[功能区名]:
				var 节点信息 = 插件节点字典[节点按钮]
				var 按钮=Button.new()
				按钮.text=节点信息["名称"]+"\r"+节点按钮  # 显示中文名称
				var 图片=节点信息["图片"]
				if 图片:
					按钮.icon=图片
				按钮.pressed.connect(func():按下功能(节点按钮))
				按钮数组 += [按钮]
				容器.add_child(按钮)
			容器数组+=[容器]
			垂直容器.add_child(容器)
		滚动区.add_child(垂直容器)
		滚动容器数组+=[滚动区]
		%"功能区".add_child(滚动区)
#---------------------
func 按下功能(功能):
	if %"添加".button_pressed==true:
		加载当前节点()
		var 节点=插件节点字典[功能]["代码"].new()
		节点.name = 功能
		parent_node.add_child(节点)
		节点.owner = EditorInterface.get_edited_scene_root()
	if %"复制".button_pressed==true:
		DisplayServer.clipboard_set(功能)
	if %"文档".button_pressed==true:
		var script_editor = EditorInterface.get_script_editor()
		script_editor.goto_help("class_name:"+功能)
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
var selection
var selected_nodes
var parent_node 

func 加载当前节点() -> void:
	selection = EditorInterface.get_selection() #获取选择器
	selected_nodes = selection.get_selected_nodes() #获取选中的节点
	if selected_nodes.size() == 0:
		printerr("请先选择一个父节点")
		return
	parent_node = selected_nodes[0]
##添加节点
func 模版(节点类型) -> void:
	加载当前节点()
	var newnode = Container.new()
	newnode.name = "Container"
	parent_node.add_child(newnode)
	newnode.owner = EditorInterface.get_edited_scene_root()
