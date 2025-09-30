extends Node
class 角色背包:
	## 道具ID  数量
	var 背包=[]
	var 加密=false #记录背包是否加密
	func 获取占用数量()->int:
		return self.背包.size()
	func 获取数据()->Array:
		return self.背包
		# 添加道具到背包
	
	#数量会自动给解码可读
	func 获取索引数据(索引:int) -> Dictionary:
		if 索引 >= 0 and 索引 < self.背包.size():
			var 格子数据 = self.背包[索引].duplicate()  # 复制一份数据，避免直接修改原数组里的内容
			if self.加密 and 格子数据.has("数量"):
				var 解密后数量 = 引擎.加解密.浮点数解密(格子数据["数量"])
				格子数据["数量"] = 解密后数量
			return 格子数据
			var 操作=引擎.加解密.浮点数解密
		return {}  # 索引越界返回空字典，方便调用处处理
		
	func 添加道具(C_道具ID: String, C_操作数量: float=1):
		#print(self.背包)
		# 查找道具是否已在背包中
		var index = 获取道具索引(C_道具ID)
		if index != -1:
			# 如果存在，增加数量
			
			if self.加密:
				#加密
				if !引擎.加解密.是否作弊:
					var 操作=引擎.加解密.浮点数解密(self.背包[index]["数量"]) + C_操作数量
					self.背包[index]["数量"]=引擎.加解密.浮点数加密(操作)
					return true
				else:
					return false
			else:
				self.背包[index]["数量"] += C_操作数量
				return true
		else:
			if self.加密:
				self.背包.append({"道具ID": C_道具ID, "数量": 引擎.加解密.浮点数加密(C_操作数量)})
			else:
				# 如果不存在，添加新道具
				self.背包.append({"道具ID": C_道具ID, "数量": C_操作数量})
				
			return true

	# 获取道具在背包中的索引
	func 获取道具索引(C_道具ID: String) -> int:
		for i in self.背包.size():
			if self.背包[i]["道具ID"] == C_道具ID:
				return i
		return -1
	

	# 减少背包中的道具 ### 使用减少具时,请先判断数量
	func 减少道具(C_道具ID: String, C_操作数量: float=1):
		var index = 获取道具索引(C_道具ID)
		#self.背包[index]["数量"] -= C_操作数量
		if self.加密:
			#加密
			if !引擎.加解密.是否作弊:
				var 操作=引擎.加解密.浮点数解密(self.背包[index]["数量"]) - C_操作数量
				self.背包[index]["数量"]=引擎.加解密.浮点数加密(操作)
				return true
			else:
				return false
		else:
			self.背包[index]["数量"] -= C_操作数量
			return true
	
	# 获取道具在背包中的数量
	func 获取道具数量(C_道具ID: String) -> float:
		var index = 获取道具索引(C_道具ID)
		if index != -1:
			if self.加密:
				return 引擎.加解密.浮点数解密(self.背包[index]["数量"])
			else:
				return self.背包[index]["数量"]
		return 0
	func 获取指定类型道具(道具数据库:引擎.数据库类.道具数据库 = 引擎.数据库.加载道具库(),类型:String=""):#?
		var 新组 = []
		for i in 背包:
			if 道具数据库.获取道具分类(i["道具ID"]) == 类型:
				新组.append(i)
		return 新组
		
	func 获取指定子类道具(道具数据库:引擎.数据库类.道具数据库 = 引擎.数据库.加载道具库(),类型:String="",子类型:String=""):#?
		var 新组 = []
		for i in 背包:
			if 道具数据库.获取道具分类(i["道具ID"]) == 类型 and 道具数据库.获取道具子类(i["道具ID"]) ==子类型 :
				新组.append(i)
		return 新组

	#先排序分类,子类,在排序等级,等级相同,在排序品质,需要传入数据库
	func 背包排序(道具数据库:引擎.数据库类.道具数据库 = 引擎.数据库.加载道具库(), 是否反向排序: bool = true):
		# 按分类排序
		背包.sort_custom(func(a, b):
			var a分类 = 道具数据库.获取道具分类(a["道具ID"])
			var b分类 = 道具数据库.获取道具分类(b["道具ID"])
			if 是否反向排序:
				if a分类 < b分类:
					return true
				elif a分类 > b分类:
					return false
				else:
					# 分类相同，按子类排序
					var a子类 = 道具数据库.获取道具子类(a["道具ID"])
					var b子类 = 道具数据库.获取道具子类(b["道具ID"])
					if a子类 < b子类:
						return true
					elif a子类 > b子类:
						return false
					else:
						# 子类相同，按等级排序
						var a等级 = 道具数据库.获取道具等级(a["道具ID"])
						var b等级 = 道具数据库.获取道具等级(b["道具ID"])
						if a等级 < b等级:
							return true
						elif a等级 > b等级:
							return false
						else:
							# 等级相同，按品质排序
							var a品质 = 道具数据库.获取道具品质(a["道具ID"])
							var b品质 = 道具数据库.获取道具品质(b["道具ID"])
							if a品质 < b品质:
								return true
							elif a品质 > b品质:
								return false
							else:
								return false
			else:
				if a分类 < b分类:
					return false
				elif a分类 > b分类:
					return true
				else:
					# 分类相同，按子类排序
					var a子类 = 道具数据库.获取道具子类(a["道具ID"])
					var b子类 = 道具数据库.获取道具子类(b["道具ID"])
					if a子类 < b子类:
						return false
					elif a子类 > b子类:
						return true
					else:
						# 子类相同，按等级排序
						var a等级 = 道具数据库.获取道具等级(a["道具ID"])
						var b等级 = 道具数据库.获取道具等级(b["道具ID"])
						if a等级 < b等级:
							return false
						elif a等级 > b等级:
							return true
						else:
							# 等级相同，按品质排序
							var a品质 = 道具数据库.获取道具品质(a["道具ID"])
							var b品质 = 道具数据库.获取道具品质(b["道具ID"])
							if a品质 < b品质:
								return false
							elif a品质 > b品质:
								return true
							else:
								return false
		)
		return 背包
			
			
		
func 创建背包(加密:bool=false) -> 角色背包:
	var a=角色背包.new()
	a.加密=加密
	return a
	
	
	
	
	
###如果有附加 好麻烦
	#func 添加道具(C_道具ID: String, C_操作数量: int = 1, 回调: Callable = Callable()):
		#var 临时道具 = {
			#"道具ID": C_道具ID,
			#"数量": C_操作数量,
			#"附加": {}
		#}
		#
		#if 回调.is_valid():
			#回调.call(临时道具)
		#
		#var 回调设置的附加属性 = 临时道具.附加
		##print("回调中设置的附加属性：", 回调设置的附加属性)
		#
		#var index = 获取道具索引(C_道具ID, 回调设置的附加属性)
		##print("索引：", index, " 当前背包：", self.背包)  # 打印当前背包状态
		#if index != -1:
			#self.背包[index]["数量"] += C_操作数量
		#else:
			#背包.append(临时道具)
			##print("添加新道具后：",self.背包)  # 确认添加成功
#
	#func 获取道具索引(C_道具ID: String, 目标扩展: Dictionary = {}) -> int:
		##print("查找索引，当前背包：", 背包)  # 打印当前背包
		#for i in self.背包.size():
			#var 道具 =  self.背包[i]
			#if 道具["道具ID"] != C_道具ID:
				#continue
			#
			#var 道具扩展 = 道具["附加"]
			#if 道具扩展 == 目标扩展:
				#return i
		#return -1
