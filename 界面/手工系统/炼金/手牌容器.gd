@tool
extends Container
class_name 手牌容器
## 重叠度（0-1之间，0无重叠，1完全重叠）
@export var 重叠度: float = 0.1:
	set(值):
		if 值==1.0:#不允许等于1
			return
		重叠度 = clamp(值, 0.0, 1.0)
		if Engine.is_editor_hint():排列子节点()
@export var 缩放子节点:Vector2=Vector2(1,1):
	set(值):
		缩放子节点 = 值
		if Engine.is_editor_hint():排列子节点()
## 卡片垂直对齐方式（默认居中）
@export var 垂直对齐: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(值):
		垂直对齐 = 值
		if Engine.is_editor_hint():排列子节点()
var 卡片区节点数组:Array[Control]=[]
var 选中卡片:Dictionary[Control,bool]={}
# 封装：获取子节点缩放后的真实宽度
func 获取卡片真实宽度(卡片: Control) -> float:
	return 卡片.size.x * 缩放子节点.x

# 封装：获取子节点缩放后的真实高度
func 获取卡片真实高度(卡片: Control) -> float:
	return 卡片.size.y * 缩放子节点.y

func 排列子节点() -> void:
	print("排序测试")
	var 子节点列表: Array[Control] = []
	for 子节点 in 卡片区节点数组:
		if 子节点 and 子节点 is Control and 子节点.visible:
			子节点.scale = 缩放子节点
			子节点列表.append(子节点)
	
	if 子节点列表.is_empty():
		return
	var 容器左内边距: float = get_theme_constant("margin_left")
	var 容器右内边距: float = get_theme_constant("margin_right")
	var 容器可用宽度: float = size.x - 容器左内边距 - 容器右内边距
	var 卡片数量: int = 子节点列表.size()

	# ========== 核心修改：删除单张卡片的单独分支，统一处理 ==========
	# 计算「原始重叠度下的总占位长度」
	var 原始总长度: float = 获取卡片真实宽度(子节点列表[0])
	for 索引 in range(1, 卡片数量):
		var 上一张卡片真实宽度: float = 获取卡片真实宽度(子节点列表[索引-1])
		var 当前卡片真实宽度: float = 获取卡片真实宽度(子节点列表[索引])
		原始总长度 += 当前卡片真实宽度 - 上一张卡片真实宽度 * 重叠度

	# 计算最终重叠度（自适应调整）
	var 最终重叠度: float = 重叠度
	if 原始总长度 > 容器可用宽度:
		var 前n_1张真实宽度总和: float = 0.0
		for 索引 in range(0, 卡片数量-1):
			前n_1张真实宽度总和 += 获取卡片真实宽度(子节点列表[索引])
		var 最后一张真实宽度: float = 获取卡片真实宽度(子节点列表[-1])
		
		if 前n_1张真实宽度总和 > 0:
			最终重叠度 = (前n_1张真实宽度总和 - (容器可用宽度 - 最后一张真实宽度)) / 前n_1张真实宽度总和
			最终重叠度 = clamp(最终重叠度, 0.0, 1.0)
	# 遍历排列所有子节点（兼容单张/多张）
	var 当前x位置: float = 容器左内边距
	for 索引 in range(卡片数量):
		var 当前卡片: Control = 子节点列表[索引]
		# Y位置计算用真实高度
		var 当前y位置: float = 计算垂直对齐位置(当前卡片)
		# 设置卡片位置
		当前卡片.position = Vector2(当前x位置, 当前y位置)
		# 更新下一张卡片的X位置（最后一张不更新，单张卡片时此逻辑自动跳过）
		if 索引 < 卡片数量 - 1:
			var 当前卡片真实宽度: float = 获取卡片真实宽度(当前卡片)
			当前x位置 += 当前卡片真实宽度 * (1 - 最终重叠度)
	var 排序结果:Array[Control]=[]
	for 卡片 in 子节点列表:
		if not(选中卡片 and 选中卡片.has(卡片)):
			排序结果.append(卡片)
	for 卡片 in 子节点列表:
		if 选中卡片 and 选中卡片.has(卡片):
			排序结果.append(卡片)
	if 排序结果.size()>1:
		for i in range(排序结果.size()):
			var 卡片 = 排序结果[i]
			move_child(卡片, i)  # 移动到第i个位置
# 封装垂直对齐位置计算逻辑，简化代码
func 计算垂直对齐位置(卡片: Control) -> float:
	var 卡片高度: float=获取卡片真实高度(卡片)
	var 容器上内边距: float = get_theme_constant("margin_top")
	var 容器下内边距: float = get_theme_constant("margin_bottom")
	var 对齐逻辑: VerticalAlignment=垂直对齐
	if 选中卡片 and 选中卡片.has(卡片):
		match 对齐逻辑:
			VERTICAL_ALIGNMENT_TOP:
				对齐逻辑=VERTICAL_ALIGNMENT_BOTTOM
			VERTICAL_ALIGNMENT_BOTTOM:
				对齐逻辑=VERTICAL_ALIGNMENT_TOP
			VERTICAL_ALIGNMENT_CENTER,_:
				对齐逻辑=VERTICAL_ALIGNMENT_TOP
	match 对齐逻辑:
		VERTICAL_ALIGNMENT_TOP:
			return 容器上内边距
		VERTICAL_ALIGNMENT_BOTTOM:
			return size.y - 卡片高度 - 容器下内边距
		VERTICAL_ALIGNMENT_CENTER,_:
			return (size.y - 卡片高度) / 2
var 炼金卡牌场景:梅奖励卡片 = preload("res://界面/手工系统/炼金/炼金卡牌.tscn").instantiate()
func 更新手牌(炼金数据:梅炼金数据):
	var 药水长度=炼金数据.药水序列.size()
	if not 卡片区节点数组.size()==药水长度:
		计划.清除子节点(self)
		卡片区节点数组.clear()
	选中卡片={}
	for i in 药水长度:
		var 药水名称:String=炼金数据.查询药水(i,"名称",药水长度)
		var 药水数量:int=炼金数据.查询药水(i,"数量",药水长度)
		var 是否解锁=i<=炼金数据.炼金数量
		var 下次解锁=i==(炼金数据.炼金数量%药水长度)
		if i<卡片区节点数组.size():
			卡片区节点数组[i].传入参数(药水名称,药水数量,是否解锁,下次解锁,0.1*i+0.2)
			if 下次解锁:
				选中卡片[卡片区节点数组[i]]=true
		else :
			var 克隆节点:梅奖励卡片=炼金卡牌场景.duplicate()
			克隆节点.传入参数(药水名称,药水数量,是否解锁,下次解锁,0.1*i+0.2)
			克隆节点.点击事件=选中更改.bind(克隆节点)
			卡片区节点数组.append(克隆节点)
			add_child(克隆节点)
			if 下次解锁:
				选中卡片[克隆节点]=true
	计划.显示后执行(排列子节点,self)
func 选中更改(选中:String,节点:Control):
	var 清空:bool=false
	if 选中=="切换":
		选中="隐藏" if 选中卡片.has(节点) else "显示"
		清空=true
	if 选中=="显示":
		if not 选中卡片.has(节点):
			if 清空:选中卡片={}
			选中卡片[节点]=true
			排列子节点()
	elif 选中=="隐藏":
		if 选中卡片.has(节点):
			if 清空:选中卡片={}
			else:选中卡片.erase(节点)
			排列子节点()
## 节点就绪后主动触发首次排列,忽略非Control节点
func _ready() -> void:
	卡片区节点数组.clear()
	var 节点数组=get_children()
	for 节点 in 节点数组:
		if 节点 is Control:
			卡片区节点数组.append(节点)
	if Engine.is_editor_hint():
		排列子节点()
	else :
		计划.显示后执行(延迟信号,self)
func 延迟信号():
	item_rect_changed.connect(排列子节点)
	resized.connect(排列子节点)
	排列子节点()
