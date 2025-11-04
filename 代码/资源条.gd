@tool  # 关键：让脚本在编辑器内运行，实现实时预览
extends Control
class_name 资源进度条
## 设定资源字典中的其中一种资源
@export var 资源名称: String = "木材":
	set(值):
		资源名称=值
		if is_inside_tree():
			更新贴图()
var 材料贴图: Dictionary = {# 资源名称与贴图路径的映射
	"木材": "res://素材/游戏素材/货币/without background/36.png",
	"矿石": "res://素材/游戏素材/货币/without background/13.png",
	"皮革": "res://素材/游戏素材/货币/without background/16.png",
	"药草": "res://素材/游戏素材/货币/without background/11.png",
	"零件": "res://素材/游戏素材/货币/without background/49.png",
	"精华": "res://素材/游戏素材/货币/without background/50.png"
}
func 更新UI(资源回复速度={}):
	var 当前数量 = 初始化.查看资源(资源名称)
	var 上限变量名 = 资源名称 + "上限"
	var 上限值 = 初始化.get(上限变量名)
	$"进度".max_value = 上限值
	$"进度".value = 当前数量
	var 回复速度=资源回复速度.get(资源名称,0)
	if 回复速度==0:
		$"进度".size=Vector2(400,50)
		$"回复".visible=false
	else :
		$"进度".size=Vector2(350,50)
		$"回复".visible=true
		$"回复".text= "+%.1f" % 回复速度
func _ready():
	更新贴图()# 节点就绪时初始化
	if Engine.is_editor_hint():
		$"进度".size=Vector2(400,50)
		$"回复".visible=false
	else :
		材料贴图=初始化.材料贴图
		更新UI()
func 更新贴图():
	if not is_inside_tree():# 编辑器内安全检查：确保节点已加入场景树，避免空引用错误
		print("节点未加入节点树")
		return
	var 贴图节点 = $贴图
	$"文本".text=str(资源名称)
	if not 贴图节点:# 确保TextureRect节点存在
		print("警告：未找到「贴图」节点，请检查节点路径")
		return
	var 贴图路径=材料贴图.get(资源名称)
	var 纹理 = load(贴图路径)
	if 纹理:
		贴图节点.texture = 纹理
	else:
		print("警告：编辑器内无法加载贴图 -> ", 贴图路径, "（可能资源未导入）")
