extends 基类梅窗口
var 种子
var 订单更新计时器: Timer=null
var UI更新计时器: Timer=null
var 订单上限=3
var 生成间隔:int=300
var 网格容器
func _ready() -> void:
	super._ready()
	网格容器=%"网格容器"
	种子=randi()
	检查生成订单()
	加载订单()
	UI更新计时器=初始化.创建计时器(1,更新UI)
func _exit_tree() -> void:
	if not 订单更新计时器==null:
		订单更新计时器.queue_free()
	if not UI更新计时器==null:
		UI更新计时器.queue_free()
func 更新UI():
	var 当前时间: float=Time.get_unix_time_from_system()
	var 订单时间戳: float = 初始化.梅存档["挂机"].get("订单时间戳",当前时间-生成间隔*3)
	var 剩余时间 = max(1,生成间隔 - int(当前时间 - 订单时间戳) % 生成间隔)
	$"内容节点/订单/控制区/订单信息".text="订单上限:"+str(初始化.梅存档["挂机"].get("订单存档",[]).size())+"/"+str(订单上限)+"
刷新倒计时:"+初始化.格式化时间(剩余时间,2)
func 检查生成订单():
	var 当前时间: float=Time.get_unix_time_from_system()
	var 订单时间戳: float = 初始化.梅存档["挂机"].get("订单时间戳",当前时间-生成间隔*3)
	var 新增订单数量:int = int((当前时间 - 订单时间戳) / 生成间隔)  # 显式取整
	if 新增订单数量>=1:
		订单时间戳+=新增订单数量*生成间隔
	初始化.梅存档["挂机"]["订单时间戳"]=订单时间戳
	if 订单更新计时器==null or 订单更新计时器.is_queued_for_deletion():
		if not is_queued_for_deletion():#预防最后一帧触发导致没有对象
			var 剩余时间 = max(1,生成间隔 - int(当前时间 - 订单时间戳) % 生成间隔)
			订单更新计时器=初始化.创建计时器(剩余时间,func():
				检查生成订单(),false)
	if 新增订单数量>=1:
		新增订单(新增订单数量)
	更新UI()
func 加载订单():
	# 第一步：检查并清理没有唯一ID的订单
	var 订单存档 = 初始化.梅存档["挂机"].get("订单存档", [])
	var 有效订单 = []
	for 订单信息 in 订单存档:
		if 订单信息.get("ID", "") != "":  # 检查ID是否为空
			有效订单.append(订单信息)
		else:
			print("发现无效订单（缺少ID）：", 订单信息)
	# 更新存档（只保留有效订单）
	if 有效订单.size() != 订单存档.size():
		初始化.梅存档["挂机"]["订单存档"] = 有效订单
		初始化.保存存档("清理无效订单")
		print("已清理无效订单，原数量：", 订单存档.size(), "，现数量：", 有效订单.size())
	# 第二步：加载有效订单
	清除子节点(%"网格容器")
	var 随机生成器: RandomNumberGenerator= RandomNumberGenerator.new()
	随机生成器.seed = 种子
	for 订单信息 in 有效订单:
		var 订单场景实例:订单卡片 = preload("res://界面/插件/订单.tscn").instantiate()
		订单场景实例.订单字典 = 订单信息
		订单场景实例.装饰随机数=随机生成器.randi() % 订单场景实例.装饰词数组.size()
		%"网格容器".add_child(订单场景实例)
		
func 新增订单(订单数量:int=1,订单池=["铁锭","纤维","鞣革"],订单标记=0):
	订单数量=min(订单上限,订单数量)#避免你挂几百年
	var 缓存订单=初始化.梅存档["挂机"].get("订单存档",[])
	if 缓存订单.size()<订单上限:
		for i in 订单数量:
			if 缓存订单.size()<订单上限:
				var 随机索引 = randi() % 订单池.size()
				缓存订单+=[{"名称":订单池[随机索引],
			"ID":初始化.唯一ID(缓存订单.size()),
			"订单量":10+5*(randi() % 4),
			"幸运值":max(5*(-5+randi() % 10),0),
			"订单标记":订单标记,
			#"时限":Time.get_unix_time_from_system()+7200
			}]
	初始化.梅存档["挂机"]["订单存档"]=缓存订单
	加载订单()
	初始化.保存存档("测试资源订单")
