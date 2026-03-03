extends 基类梅窗口
@onready var 提示: VBoxContainer = %提示
@onready var 最大通知文本: Label = %最大通知文本
@onready var 标签: TabContainer = %标签
@onready var 展示按钮: Button = %展示按钮
@onready var 排序按钮: Button = %排序
@onready var 置顶: Button = %置顶
@onready var 前移: Button = %前移
@onready var 后移: Button = %后移
@onready var 跳转: Button = %跳转
var 窗口:=计划.窗口
var 选中窗口:String=""
func _ready() -> void:
	super._ready()
	加载通知()
	计划.通知更新.connect(加载通知)
	计划.过去一秒.connect(func():
		if 通知更新冷却>0:
			通知更新冷却=0
			加载通知())
	任务栏初始化()
	后移.icon=垂直翻转图片(后移.icon)
	展示按钮.pressed.connect(窗口切换)
	置顶.pressed.connect(_处理窗口排序.bind("置顶"))
	排序按钮.pressed.connect(_处理窗口排序.bind("排序"))
	前移.pressed.connect(_处理窗口排序.bind("前移"))
	后移.pressed.connect(_处理窗口排序.bind("后移"))
	跳转.pressed.connect(切换场景)
	加载窗口("任务窗口")
var 通知更新冷却:int=0
func 加载通知():
	if 通知更新冷却>2:
		return
	计划.清除子节点(提示)
	最大通知文本.text="最多保留,本次游戏中,最新的%d条通知"%[计划.配置文件.get("最大通知",20)]
	通知更新冷却=true
	var 序号=0
	for 文本 in 计划.历史通知文本列表:
		序号+=1
		var 节点=Label.new()
		节点.text="第%d条通知:"%序号+文本
		提示.add_child(节点)
func 任务栏初始化():
	var 窗口解锁数组:Array = 计划.梅存档.挂机.窗口解锁
	var 已读取数组:Array=[]
	var 需要删除:Array=[]
	计划.清除子节点(%"任务栏盒子")
	for 界面名称 in 窗口解锁数组:
		if 已读取数组.has(界面名称):
			需要删除.append(界面名称)
			continue
		if not 窗口.窗口数据.has(界面名称):
			需要删除.append(界面名称)
			continue
		已读取数组.append(界面名称)
		var 任务按钮: Button = Button.new()
		任务按钮.vertical_icon_alignment=VERTICAL_ALIGNMENT_FILL
		任务按钮.vertical_icon_alignment=VERTICAL_ALIGNMENT_CENTER
		任务按钮.expand_icon=true
		任务按钮.custom_minimum_size=Vector2(200,0)
		任务按钮.show()#防止节点为隐藏
		任务按钮.text = 窗口.窗口数据[界面名称].显示名
		任务按钮.icon = load(窗口.窗口数据[界面名称].贴图)
		任务按钮.pressed.connect(加载窗口.bind(界面名称))
		%"任务栏盒子".add_child(任务按钮)
	if 需要删除.size()>=1:
		for 界面名称 in 需要删除:
			窗口解锁数组.erase(界面名称)
func 加载窗口(界面名称):
	选中窗口=界面名称
	var 窗口禁用数组 = 计划.梅存档.挂机.窗口禁用
	%"窗口名".text="窗口名称:"+界面名称
	var 加载简介:Array=窗口.窗口数据[界面名称].简介
	%"窗口介绍".text="简介:\r"+ "\r".join(加载简介) +"\r管理任务栏中显示的按钮"
	var 纹理地址:String=计划.窗口.窗口数据[界面名称].贴图
	var 纹理 = null
	if not 纹理地址=="":纹理 =load(纹理地址)
	展示按钮.icon=纹理
	展示按钮.button_pressed=not 窗口禁用数组.has(界面名称)
func 窗口切换():
	if 选中窗口=="":
		return
	var 窗口禁用数组:Array = 计划.梅存档.挂机.窗口禁用
	if 窗口禁用数组.has(选中窗口):窗口禁用数组.erase(选中窗口)
	else :窗口禁用数组.append(选中窗口)
	展示按钮.button_pressed=not 窗口禁用数组.has(选中窗口)
	if 计划.节点有效性检查("空节点"):
		计划.节点["空节点"].生成任务栏按钮()
func 垂直翻转图片(原始纹理: Texture2D) -> ImageTexture:
	# 校验输入是否有效
	if 原始纹理 == null:
		print("错误：传入的图片资源为空")
		return null
	# 1. 将Texture2D（按钮icon的类型）转换为可修改的Image对象
	var 原始图片 = 原始纹理.get_image()
	if 原始图片 == null:
		print("错误：无法将纹理转换为Image对象")
		return null
	# 2. 复制原图避免修改源文件，执行上下镜像翻转
	var 翻转后的图片 = 原始图片.duplicate()  # 复制原图，防止修改原始资源
	翻转后的图片.flip_y()  # 核心：上下镜像（flip_y=垂直翻转，flip_x=水平翻转）
	# 3. 将处理后的Image转回ImageTexture（按钮icon支持的类型）
	var 翻转后的纹理 = ImageTexture.create_from_image(翻转后的图片)
	return 翻转后的纹理
# 通用方法：处理所有窗口排序操作（置顶/前移/后移）
func _处理窗口排序(操作类型: String):
	if 选中窗口 == "":
		计划.语法糖通知("未选中窗口","窗口提示")
		return
	var 解锁数组: Array = 计划.梅存档.挂机.窗口解锁#实时获取最新数组
	var 元素索引 = 解锁数组.find(选中窗口)#检查选中状态并获取索引
	if 元素索引 == -1:return
	match 操作类型:# 3. 根据操作类型执行对应逻辑
		"排序":
			计划.梅存档.挂机.窗口解锁=重排序数组(计划.梅存档.挂机.窗口解锁,计划.窗口.窗口数据.keys())
		"置顶":
			if 元素索引 == 0:
				计划.语法糖通知("提示：【%s】已是第一个元素，无需置顶" % 选中窗口,"窗口提示")
				return
			# 置顶逻辑：移除后插入到首位
			解锁数组.erase(选中窗口)
			解锁数组.insert(0, 选中窗口)
		"前移":
			if 元素索引 == 0:
				计划.语法糖通知("提示：【%s】已是第一个元素，无法前移" % 选中窗口,"窗口提示")
				return
			# 前移逻辑：手动交换当前元素和前一个元素
			var 临时存储 = 解锁数组[元素索引 - 1]
			解锁数组[元素索引 - 1] = 解锁数组[元素索引]
			解锁数组[元素索引] = 临时存储
		
		"后移":
			if 元素索引 == 解锁数组.size() - 1:
				计划.语法糖通知("提示：【%s】已是最后一个元素，无法后移" % 选中窗口,"窗口提示")
				return
			# 后移逻辑：手动交换当前元素和后一个元素
			var 临时存储 = 解锁数组[元素索引 + 1]
			解锁数组[元素索引 + 1] = 解锁数组[元素索引]
			解锁数组[元素索引] = 临时存储
		_:
			计划.语法糖通知("提示：无效的操作类型【%s】" % 操作类型,"窗口提示")
			return
	# 4. 所有有效操作后统一刷新UI
	任务栏初始化()
	if 计划.节点有效性检查("空节点"):
		计划.节点["空节点"].生成任务栏按钮()
func 重排序数组(待排序数组: Array, 标准顺序数组: Array) -> Array:
	# 步骤2：去重处理（利用字典的键唯一性，保留元素首次出现的顺序）
	var 去重后的待排序数组: Array = []
	var 临时去重字典: Dictionary = {}
	for 元素 in 待排序数组:
		# 仅保留文本类型元素，且未重复的元素
		if typeof(元素) == TYPE_STRING and not 临时去重字典.has(元素):
			临时去重字典[元素] = true
			去重后的待排序数组.append(元素)
	
	# 步骤3：按标准顺序筛选并排列元素
	var 排序结果数组: Array = []
	var 已添加元素字典: Dictionary = {}  # 标记已添加的元素，避免重复
	
	# 先添加标准顺序中存在的元素（按标准顺序排列）
	for 标准元素 in 标准顺序数组:
		if 标准元素 in 去重后的待排序数组 and not 已添加元素字典.has(标准元素):
			排序结果数组.append(标准元素)
			已添加元素字典[标准元素] = true
	
	# 再添加待排序数组中不在标准顺序里的新增元素（保留其原有相对顺序）
	for 待排序元素 in 去重后的待排序数组:
		if not 已添加元素字典.has(待排序元素):
			排序结果数组.append(待排序元素)
			已添加元素字典[待排序元素] = true
	
	return 排序结果数组
func 切换场景():
	if 选中窗口=="":
		计划.语法糖通知("未选中窗口","窗口提示")
	else:
		计划.切换场景(选中窗口)
