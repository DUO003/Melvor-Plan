extends Resource
class_name 梅提示数据

@export var 提示数组: Array[Dictionary] = []
@export var 默认字体:int=40
@export var 标题高度:int=0
var 节点:Node=null
#Color("004e82ff")
var 数值色:String="#004e82ff"
func _init() -> void:
	var 配置文件:=计划.配置文件
	var 全局配置字典:Dictionary = ProjectSettings.get_setting("global/snake_case")
	数值色=计划.配置文件.get("悬浮数值色", 全局配置字典.get("悬浮数值色","#004e82ff"))as String
func 通用解析(资源,参数:Dictionary={})->bool:
	提示数组.clear()
	if 资源 is ItemData:
		默认字体=32
		标题高度=50
		if 资源 is 物品装备:
			解析装备(资源,参数)
			return true
		elif 资源 is 标准物品:
			解析物品(资源,参数)
			return true
		elif 资源 is 物品方块:
			解析方块(资源,参数)
			return true
		elif 资源 is 物品宝石:
			解析宝石(资源,参数)
			return true
	elif 资源 is EquipmentSlotData:
		默认字体=28
		标题高度=45
		解析装备栏(资源)
		return true
	elif 资源 is 游历实体:
		默认字体=28
		标题高度=45
		解析实体(资源,参数)
		#通用提示(0,"",{"样式":{"测试":["鼠标右键"]}})
		return true
	提示数组=[{"文本":"错误解析失败"}]
	print("解析失败",资源)
	return false
func 解析装备栏(资源:EquipmentSlotData,参数:Dictionary={}):
	var 物品:物品装备 = 资源.equipped_item as 物品装备
	var 倍率:float=资源.倍率()
	提示数组.append({"文本":"[center][font_size=%d]%s[/font_size][/center]"%[默认字体+10,资源.slot_name]})
	if 物品:解析装备(物品,{"倍率":倍率,"简化":true})
	else :提示数组.append({"文本":"空的装备栏"%[]})
	var 宝石物品数组:Array=计划.装备.获得装备槽宝石(资源.slot_name,false)
	if 宝石物品数组.size()>=1:
		提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
	for 宝石 in 宝石物品数组:
		if 宝石 is 物品宝石:
			解析宝石(宝石,{"简化":true})
	var 简化:bool=参数.get("简化",false)
	if not 简化:通用提示(0,"",{"样式":{"移动":["鼠标左键","鼠标右键"]}})
func 解析物品(资源:标准物品,参数:Dictionary={}):
	提示数组.append({"文本":"[center][font_size=%d]%s[/font_size][/center]"%[默认字体+10,资源.item_name]})
	if GBIS.shop_names.has(参数.get("背包名","")):
		提示数组.append({"文本":"每次购买数量:[color=%s]%d[/color]\n购买价格:[color=%s]%d[/color] 单价:[color=%s]%d[/color]\n剩余购买次数:[color=%s]%d[/color]"%[
			数值色,资源.数量,数值色,资源.价值,数值色,(资源.价值*1.0/资源.数量),数值色,资源.商店剩余数量]})
		提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
	提示数组.append({"模式":"分栏","间距":20,
		"分栏组":["背包数量:[color=%s]%d[/color]"%[数值色,计划.检查背包物品数量(资源.item_name)],
		"阶级:[color=%s]%s[/color]"%[数值色,计划.罗马数字(资源.阶级)]]})
	提示数组.append({"文本":"标签:[color=%s]"%[数值色]+",".join(资源.标签)+"[/color]"})
	var 简化:bool=参数.get("简化",false)
	if not 简化:通用提示(计划.表格.蓝图数据(资源.item_name,"价值"),资源.简介,
		{"样式":{"移动":["鼠标右键"],"选中":["鼠标左键"],"分组":["鼠标中键"]}})
func 解析方块(资源:物品方块, 参数:Dictionary={}):
	提示数组.append({"文本": "[center][font_size=%d]%s[/font_size][/center]" % [默认字体+10, 资源.item_name]})
	提示数组.append({
		"文本": "堆叠上限:[color=%s]%d[/color]\n尺寸:[color=%s]%d列 × %d排[/color]" % [
			数值色, 资源.堆叠上限,数值色, 资源.columns, 资源.rows]})
	var 简化:bool=参数.get("简化",false)
	if not 简化:通用提示(0,资源.简介,{"样式":{"移动":["鼠标右键"],"选中":["鼠标左键"],"分组":["鼠标中键"]}})
func 解析装备(资源:物品装备,参数:Dictionary={}):
	var 倍率:float=参数.get("倍率",1.0)
	var 装备名:String=资源.item_name
	var 装备阶级=计划.表格.蓝图数据(装备名,"阶级")
	var 倍率文本:String=""
	var 简化:bool=参数.get("简化",false)
	if 倍率>1:倍率文本="x%.2f"%倍率
	if not 简化:
		提示数组.append({"文本":"[center][font_size=%d]%s[/font_size][/center]%s"%[默认字体+10,装备名,倍率文本]})
	else :
		提示数组.append({"文本":"[center]%s[/center]%s"%[装备名,倍率文本]})
	提示数组.append({"模式":"分栏","间距":20,
		"分栏组":["等级:[color=%s]%d[/color]/%d"%[数值色,资源.等级,资源.阶级*5],"阶级:%s"%[计划.罗马数字(装备阶级)]]})
	提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
	提示数组.append({"文本": "[font_size=%d]【装备属性】[/font_size]" % [默认字体+2]})
	var 分类=资源.分类
	var 字典:Dictionary=资源.基础数值[资源.类型]
	if ["武器"].has(分类):
		提示数组.append({"模式":"分栏","间距":10,"分栏组":[
			"攻击倍率x [color=%s]%.2f[/color]"%[数值色,(字典["攻击"])],
			"攻击距离x [color=%s]%.1f[/color]"%[数值色,(字典["攻击距离"])]]})
		提示数组.append({"文本":"攻速: [color=%s]%.1f[/color]%%"%[数值色,(字典["攻速"]*100)]})
	elif 字典.has("攻击"):
		提示数组.append({"文本":"攻击倍率 [color=%s]%.1f[/color]%%"%[数值色,(字典["攻击"]*100)]})
	if 字典.has("减伤"):
		提示数组.append({"文本":"减伤: [color=%s]%.1f[/color]%%"%[数值色,(字典["减伤"]*100)]})
	if 字典.has("血量"):
		提示数组.append({"文本":"生命上限:+ [color=%s]%.1f[/color]%%"%[数值色,(字典["血量"]*100)]})
	if 字典.has("魔法"):
		提示数组.append({"文本":"魔法上限:+ [color=%s]%.1f[/color]%%"%[数值色,(字典["魔法"]*100)]})
	var 基础属性:Dictionary=资源.基础属性
	for 属性名 in 基础属性:
		提示数组.append({"模式":"分栏","间距":0,
		"分栏组":[(基础属性[属性名]/资源.当前最大属性(属性名)),
		" %s:+ [color=%s]%.1f[/color]"%[属性名,数值色,基础属性[属性名]*倍率]]})
	if not 简化:通用提示(资源.出售价格())
func 解析宝石(资源:物品宝石, 参数:Dictionary={}):
	var 简化:bool=参数.get("简化",false)
	var 宝石阶级 = 计划.表格.蓝图数据(资源.item_name, "阶级") # 从外部表格获取阶级
	var 阶级 = 计划.罗马数字(宝石阶级) # 调用外部罗马数字转换
	var 倍率值:float = 资源.倍率() # 抽离为外部函数，基于宝石资源计算
	if 简化:
		var 核心文本:String = "倍率:[color=%s]+%.1f%%[/color]" % [数值色, 倍率值]
		提示数组.append({"模式":"分栏","间距":0,"分栏组": [资源.item_name,资源.数值,核心文本]})
	else:
		var 核心文本:String = "增强装备栏:[color=%s]%.1f%%[/color]" % [数值色, 倍率值]
		提示数组.append({"文本": "[center][font_size=%d]%s[/font_size][/center]" % [默认字体+10, 资源.item_name]})
		提示数组.append({"文本":"阶级:%s"%阶级})
		提示数组.append({"模式":"分栏","间距":0,"分栏组": [资源.数值,核心文本]})
	if 简化:
		pass
	elif 资源.宝石词条.is_empty():
		提示数组.append({"文本": "宝石词条开发中..."})
	else :
		提示数组.append({"模式":"分隔线","边距":10,"宽度":3})
		提示数组.append({"文本": "[font_size=%d]【随机词条】[/font_size]" % [默认字体+2]})
		# 遍历宝石资源中的词条配置
		for 词条名 in 资源.宝石词条:
			if 资源.随机词条.has(词条名):
				# 所有数据从传入的宝石资源中获取
				var 属性 = 资源.宝石词条[词条名]["属性"]
				var 激活值 = 资源.宝石词条[词条名]["激活"]
				var 强度 = 资源.宝石词条[词条名]["强度"]
				var 词条模板 = 资源.随机词条[词条名]["词条名"] + 计划.罗马数字(强度)
				var 需求属性 = 资源.随机词条[词条名]["需求属性"]
				var 需求属性文本 = "+".join(需求属性)
				var 后缀 = ""
				# 富文本格式处理（兼容参数）
				if 参数.has("富文本"):
					后缀 = "(激活需%s:%d)" % [需求属性文本, 激活值]
					if 参数.has("简化"):
						后缀 = " %s>=%d" % [需求属性文本, 激活值]
					后缀 = "[font_size=%d]%s[/font_size]" % [int(0.75*参数["富文本"]), 后缀]
				else:
					后缀 = "(激活需%s:%d)" % [需求属性文本, 激活值]
				# 拼接词条文本
				var 拼接词条 = ""
				if 参数.has("富文本"):
					拼接词条 = 词条模板 % ("[color=%s]%s[/color]" % ["#222222", 属性])
				else:
					拼接词条 = 词条模板 % 属性
				提示数组.append({"文本":拼接词条 + 后缀})
	if not 简化:通用提示()
func 解析实体(实体:游历实体,_参数:Dictionary={}):
	提示数组.append({"文本":"[center][font_size=%d]%s[/font_size][/center]"%[默认字体+10,实体.实体名称]})
	提示数组.append({"文本":"攻击力:%.0f"%实体.攻击力})
	提示数组.append({"文本":"暴击力:%.0f"%实体.暴击力})
	提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
	提示数组.append({"文本":"武器:%s"%实体.武器名称})
	提示数组.append({"文本":"攻击距离:%d"%实体.近战攻击距离})
	提示数组.append({"文本":"攻速:%.1f"%实体.攻击间隔})
func 通用提示(价格:int=0,简介:String="",参数:Dictionary={"样式":{"移动":["鼠标右键"],"选中":["鼠标左键"]}}):
	if 简介.is_empty():
		if 价格>=1:
			提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
			提示数组.append({"文本":"回收价:[color=%s]%d[/color]"%[数值色,价格]})
	else :
		if 价格>=1:
			提示数组.append({"文本":"回收价:[color=%s]%d[/color]"%[数值色,价格]})
		提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
		提示数组.append({"宽度":500,"文本":"简介:%s"%[简介]})
	if 参数.has("样式"):
		# 1. 初始化分栏组，固定以“操作说明:”开头
		var 分栏组: Array = ["操作说明:"]
		# 2. 获取样式字典并提取所有操作项（键值对）
		var 样式字典: Dictionary = 参数["样式"]
		var 操作列表: Array = 样式字典.keys()  # 比如 ["移动", "选中"]
		
		# 3. 遍历每个操作，动态构建分栏组元素
		for 索引 in 操作列表.size():
			var 操作名称: String = 操作列表[索引]  # 比如 "移动"
			var 图片名称列表: Array = 样式字典[操作名称]  # 比如 ["鼠标右键","鼠标左键"]
			
			# 3.1 添加操作名称文本（比如 "移动"）
			分栏组.append(操作名称)
			
			# 3.2 遍历该操作对应的所有图片，生成图片字典并添加
			for 图片名称 in 图片名称列表:
				var 图片项: Dictionary = {"类型": "图片","图片": 截取图片(图片名称)}  # 调用已有图片截取函数
				分栏组.append(图片项)
		# 4. 将动态构建的分栏组添加到提示数组
		提示数组.append({"模式":"分栏","间距":5,"分栏组":分栏组})
var 瓦片字典:Dictionary={
	"图标集":{"图片":preload("res://素材/综合/图标集.png"),
	"瓦片尺寸":Vector2(64,64),
	"瓦片位置":{"鼠标左键":Vector2(0,0),"鼠标右键":Vector2(1,0),"鼠标中键":Vector2(2,0),}}}
func 截取图片(瓦片名:String, 图名:String="图标集") -> Texture2D:
	if not 瓦片字典.has(图名):
		push_error("图名不存在: " + 图名)
		return null
	var 图数据 = 瓦片字典[图名]
	if not 图数据.has_all(["图片", "瓦片尺寸", "瓦片位置"]):
		push_error("图数据不完整: " + 图名)
		return null
	if not 图数据["瓦片位置"].has(瓦片名):
		push_error("瓦片名不存在: " + 瓦片名)
		return null
	var 源纹理:Texture2D = 图数据.图片
	var 瓦片尺寸:Vector2 = 图数据.瓦片尺寸
	var 位置:Vector2 = 图数据.瓦片位置[瓦片名]
	var 瓦片区域:Rect2 = Rect2(位置 * 瓦片尺寸, 瓦片尺寸)
	var 纹理 = AtlasTexture.new()
	纹理.atlas = 源纹理
	纹理.region = 瓦片区域
	return 纹理
#func 截取图片(瓦片名:String, 图名:String="图标集") -> Texture2D:
	## 1. 参数验证
	#if not 瓦片字典.has(图名):
		#push_error("图名不存在: " + 图名)
		#return null
	#var 图数据 = 瓦片字典[图名]
	#if not 图数据.has_all(["图片", "瓦片尺寸", "瓦片位置"]):
		#push_error("图数据不完整: " + 图名)
		#return null
	#if not 图数据["瓦片位置"].has(瓦片名):
		#push_error("瓦片名不存在: " + 瓦片名)
		#return null
	## 2. 生成缓存文件名
	#var 缓存文件名 := 图名 + "_" + 瓦片名 + ".png"
	#var 文件路径 := "user://缓存/" + 缓存文件名
	## 3. 检查缓存是否已存在
	#if FileAccess.file_exists(文件路径):
		#print("从缓存加载:", 文件路径)
		## 从缓存文件加载
		#var 加载图像 := Image.load_from_file(文件路径)
		#if 加载图像 == null:
			#push_error("加载缓存图片失败: " + 文件路径)
			#return null
		#return ImageTexture.create_from_image(加载图像)
	## 4. 准备数据
	#var 源纹理:Texture2D = 图数据.图片
	#var 瓦片尺寸:Vector2 = 图数据.瓦片尺寸
	#var 位置:Vector2 = 图数据.瓦片位置[瓦片名]
	#var 瓦片区域:Rect2 = Rect2(位置 * 瓦片尺寸, 瓦片尺寸)
	## 5. 创建 AtlasTexture
	#var 纹理 = AtlasTexture.new()
	#纹理.atlas = 源纹理
	#纹理.region = 瓦片区域
	## 6. 获取图像并保存到缓存
	#var 图像 := 纹理.get_image()
	## 确保缓存目录存在
	#var 目录 := DirAccess.open("user://")
	#if not 目录.dir_exists("user://缓存"):
		#目录.make_dir("user://缓存")
	## 保存到缓存
	#var 错误 := 图像.save_png(文件路径)
	#if 错误 != OK:
		#push_error("保存缓存失败: " + str(错误))
		## 即使保存失败，也返回生成的纹理
		#return 纹理
	#print("已创建并缓存:", 文件路径)
	#return 纹理
func 生成蓝图(配方名称:String):
	var 手工:=计划.手工
	var 表格:=计划.表格
	var 配方等级 = 手工.数据合成配方(配方名称)
	var 配方升星 = 手工.数据合成配方(配方名称,"升星")
	var 残缺图纸数量:int = 手工.数据合成配方(配方名称,"残缺图纸数量")
	var 缓存升星字符:String=""
	if 配方升星>=1:缓存升星字符="升星:"+"★".repeat(配方升星)
	提示数组.append({"文本":"[center][font_size=%d]%s %s[/font_size][/center]"%[默认字体+10,配方名称,缓存升星字符]})
	if 配方等级>0:
		var 精通:int=手工.数据合成配方(配方名称,"精通")
		var 精通需求:int=计划.结算升级("手工",计划.玩法枚举.合成,配方名称,true)
		提示数组.append({"模式":"分栏","间距":10,
			"分栏组":["LV:[color=%s]%d[/color]"%[数值色,配方等级],
			"(%d/%d)"%[精通,精通需求]]})
	var 制作耗时:float=float(表格.蓝图数据(配方名称,"冷却"))
	提示数组.append({"文本":"自动最低:[color=%s]%.1f[/color]秒"%[数值色,制作耗时]})
	if 残缺图纸数量>=1:
		var 研究力:=计划.装备.研究力
		var 阶级:int=计划.表格.蓝图数据(配方名称,"阶级")
		var 蓝图纸点数:int=int(阶级*(2+0.5*研究力))
		提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
		提示数组.append({"文本":"残缺图纸:[color=%s]%d[/color]次"%[数值色,残缺图纸数量]})
		提示数组.append({"文本":"蓝图纸点数+[color=%s]%d[/color]"%[数值色,蓝图纸点数]})
		提示数组.append({"文本":"点数来源(基础%d+研究力%d)"%[阶级*2,int(阶级*0.5*研究力)]})
	# 构建内容字符串
	var 分栏组:Array=[]
	var 精华:bool=false
	for 键 in 手工.资源字典.keys():
		if 表格.蓝图数据(配方名称,键) > 0:
			var 材料数量:float=float(表格.蓝图数据(配方名称,键))
			if 配方升星>=1:材料数量=材料数量*0.9
			if 手工.资源字典.has(键):
				分栏组.append("[img=30x30]%s[/img]:[color=%s]%d[/color]"%[
					手工.资源字典[键]["贴图"].resource_path,数值色,材料数量])
			else :
				分栏组.append("%s:[color=%s]%d[/color]"%[键,数值色,材料数量])
			if 键=="精华":精华=true
	if 分栏组.size()>=1:
		提示数组.append({"模式":"分隔线","边距":10,"宽度":5})
		提示数组.append({"文本": "[font_size=%d]【制作材料】[/font_size]" % [默认字体+2]})
		提示数组.append({"模式":"分栏","间距":10,"分栏组":分栏组})
	if 精华:
		提示数组.append({"文本":"自动制作需要占用1精华"%[]})
func 队列消息(制作参数:Array,队列序号:int):
	默认字体=30
	if 队列序号+1>制作参数.size():
		标题高度=0
		提示数组=[{"文本":"空的制作格子"}]
	else :
		var 制作时长=制作参数[队列序号]["制作时长"]
		var 制作物品名=制作参数[队列序号]["名称"]
		#Color("402200ff")
		标题高度=50
		提示数组=[{"文本":"[center][font_size=40]<%s>[/font_size][/center]"%[制作物品名]}]
		var 冷却:float=计划.表格.蓝图数据(制作物品名,"冷却")
		提示数组.append({"模式":"分栏","分栏组":[冷却/制作时长,
			"需要[color=%s]%.1f[/color]秒制作(最低%.0f秒)"%[数值色,制作时长,冷却]]})
		提示数组.append({"文本":"增加物质回复速度可以减少制作时间"})
		var 消耗精华:int=int(计划.表格.蓝图数据(制作物品名,"精华"))
		if 消耗精华>=1:
			提示数组.append({"文本":"需要占用[color=%s]%d[/color]个制作精华"%[数值色,消耗精华]})
		var 简介:String=计划.表格.蓝图数据(制作物品名,"简介")
		通用提示(0,简介,{"样式":{"取消":["鼠标右键"]}})
