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
@export var 基础量: int = 1       # 基础回复量（外部传入）
var 是否长按: bool = false        # 标记是否处于长按状态
var 长按计时器: Timer            # 用于长按周期性回复的计时器
func 更新UI(资源回复速度={}):
	var 当前数量 = 初始化.查看资源(资源名称)
	var 上限变量名 = 资源名称 + "上限"
	var 上限值 = 初始化.get(上限变量名)
	var 背包内数量=初始化.检查背包物品数量(资源名称)
	$"进度".max_value = 上限值
	$"进度".value = 当前数量
	if 背包内数量>=1:
		$"背包内数量".text="存:"+str(背包内数量)
		$"背包内数量".visible=true
	else :
		$"背包内数量".visible=false
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
	if is_inside_tree():# 编辑器内安全检查：确保节点已加入场景树，避免空引用错误
		长按计时器 = Timer.new()
		长按计时器.wait_time = 0.5    # 长按间隔0.5秒
		长按计时器.one_shot = false   # 循环触发
		长按计时器.timeout.connect(长按超时处理)
	add_child(长按计时器)
	$"点击范围".gui_input.connect(点击逻辑)
func 点击逻辑(event: InputEvent):
	if is_inside_tree():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:# 仅响应鼠标左键事件
			if event.pressed:
				# 鼠标按下时处理
				处理按下()
			else:
				# 鼠标释放时处理
				处理释放()
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
		$"资源粒子".texture = 纹理
		$"资源粒子".emitting=false
	else:
		print("警告：编辑器内无法加载贴图 -> ", 贴图路径, "（可能资源未导入）")
func 处理按下():
	if 基础量>0:
		初始化.获得资源(资源名称, 基础量 * 5, true, true)# 点击立即回复5倍基础量资源
		是否长按 = true# 标记为长按状态并启动计时器
		长按计时器.start()
		$"资源粒子".amount=10
		$"资源粒子".amount_ratio=0.25
		$"资源粒子".preprocess=0.5
		$"资源粒子".emitting=true
func 处理释放():# 结束长按状态但不停止计时器
	是否长按 = false
func 长按超时处理():
	print(资源名称,"长按超时处理",是否长按)
	if 是否长按:# 长按期间每0.5秒回复1倍基础量资源
		if not $"资源粒子".emitting:
			$"资源粒子".emitting=true
			$"资源粒子".preprocess=0
			$"资源粒子".amount_ratio=0.3
		初始化.获得资源(资源名称, 基础量, true, true)# 每0.5秒回复一次基础量资源
	else :
		长按计时器.stop()
