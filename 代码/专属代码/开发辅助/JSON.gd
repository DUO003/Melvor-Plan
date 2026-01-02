@tool  # 标记为工具脚本，支持在编辑器中运行
extends EditorScript
class_name json检查器  # 中文类名
const 标签检查规则:Dictionary = {
	"装备": [],          # 装备暂无需要检查的键
	"贵重":[],
	"材料":[],
	"符文":[],
	"资源":[],
	"手工":[],
	"收藏品":[],
	"灾厄":[],
	"元素":[],
	"维度传送液":[],
	"失败品":[],
	"颜料":[],
	"礼盒": ["使用","礼盒"],
	"物资": ["使用"],
	"炼金": ["炼金属性","类型"],
	"药水": ["药水倾向"],
	"装备魔药":["药水数量"],
	"食物": ["卡路里","美味度"],
	"食材": ["食材"],
	"调料": ["口味"],
	"料理": ["代币","菜谱"]
}
var 待检查数据字典:Dictionary = {}

func _run():
	# 初始化表格数据
	var start_init = Time.get_ticks_usec()
	表格初始化()
	var end_init = Time.get_ticks_usec()
	print("表格初始化() 耗时: %d 微秒" % (end_init - start_init))
	# 第一步：检查JSON格式是否合法
	var start_check = Time.get_ticks_usec()
	批量检查JSON格式()
	var end_check = Time.get_ticks_usec()
	print("批量检查JSON格式() 耗时: %d 微秒" % (end_check - start_check))


func 表格初始化():
	待检查数据字典.clear()
	var 表格单例:梅表格 = 梅表格.new()
	表格单例.表格初始化()
	
	var 创世蓝图 = 表格单例.创世蓝图
	var 属性序号 = 表格单例.蓝图表头["属性"]
	var 标签序号 = 表格单例.蓝图表头["标签"]  # 获取标签列序号
	var 序号 = 1
	
	for 蓝图 in 创世蓝图:
		if 序号 >= 3:
			# 存储蓝图代号、属性文本、标签文本
			待检查数据字典[蓝图[0]] = {
				"属性文本": 蓝图[属性序号],
				"标签文本": 蓝图[标签序号]
			}
		else:
			序号 += 1


func 批量检查JSON格式():
	if 待检查数据字典.is_empty():
		print("⚠️ 待检查数据字典为空")
		return
	
	print("========== 开始检查标签对应JSON键 ==========")
	var 键缺失数量 = 0
	var 匹配到的标签数量 = 0  # 新增：统计匹配到的标签数
	
	for 代号 in 待检查数据字典:
		var 数据项 = 待检查数据字典[代号]
		var 属性文本 = 数据项["属性文本"]
		var 标签文本 = 数据项["标签文本"].strip_edges()  # 统一清理首尾空格
		# 空属性文本跳过检查
		if 属性文本 == "":
			continue
		# 先解析JSON（避免格式错误导致键检查失败）
		var json解析器 = JSON.new()
		var 解析状态 = json解析器.parse(属性文本)
		if 解析状态 != OK:
			print("ℹ️ 代号%s: JSON格式错误，无法进行标签键检查" % 代号)
			continue
		
		var json数据 = json解析器.get_data()
		# 确保JSON解析结果是字典（键检查仅针对字典类型）
		if not json数据 is Dictionary:
			print("❌ 代号%s: JSON解析结果不是字典类型，无法检查键" % 代号)
			print("   JSON文本: %s\n" % 属性文本)
			continue
		
		# 核心修改：不分割标签文本，直接用 `in` 判断标签是否存在于标签文本中
		var 当前代号匹配的标签:Array = []
		for 检查标签 in 标签检查规则:
			# 用 in 语法判断检查标签是否存在于标签文本中（忽略大小写可选，如需开启则加 .to_lower()）
			if 检查标签 in 标签文本:
				当前代号匹配的标签.append(检查标签)
		
		# 无匹配标签的情况
		if 当前代号匹配的标签.is_empty():
			continue
		# 遍历匹配到的标签，检查对应键
		匹配到的标签数量 += len(当前代号匹配的标签)
		for 匹配标签 in 当前代号匹配的标签:
			var 需要检查的键列表 = 标签检查规则[匹配标签]
			# 无需要检查的键则跳过（如装备标签）
			if 需要检查的键列表.is_empty():
				continue
			
			# 检查每个必填键是否存在
			for 检查键 in 需要检查的键列表:
				if 检查键 not in json数据:
					键缺失数量 += 1
					print("❌ 代号%s: 匹配标签'%s'要求包含键'%s'，但JSON中缺失" % [代号, 匹配标签, 检查键])
					print("   标签文本: %s" % 标签文本)
					print("   JSON文本: %s\n" % 属性文本)
	print("错误标签总数: %d/%d 个"%[键缺失数量,匹配到的标签数量])
