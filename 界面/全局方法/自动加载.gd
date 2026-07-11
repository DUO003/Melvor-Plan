@tool
extends Node
class_name 梅自动加载

#region 固定配置
## 技能存放目录
const 技能资源目录: String = "res://数据包/实体/技能/"
#endregion 固定配置

#region 技能
## 技能容器，键=技能名称，值=技能数据资源
@export var 技能字典: Dictionary[String, 梅技能数据_回合制] = {}
#endregion 技能

#region 手动控制器
## 检视面板开关：勾选后手动重新加载全部技能
@export var 手动重载技能开关: bool = false:
	set(值):
		手动重载技能开关 = false
		加载全部技能数据()
#endregion 手动控制器

#region 内置变量
# 目录读取工具缓存
var 目录读取器: DirAccess
#endregion 内置变量

#region 场景引用
@export var 工具: 梅工具
#endregion 场景引用

#region 外部信号
func _ready():
	if Engine.is_editor_hint():
		加载全部技能数据()  # 仅在项目加载时执行
#endregion 外部信号

## 重新加载技能字典
func 加载全部技能数据():
	print("开始重载技能数据")

	# 第一步：验证目录是否可访问
	var 目录检查: DirAccess = DirAccess.open(技能资源目录)
	if 目录检查 == null:
		push_error("【梅自动加载】技能目录不存在或无法访问：" + 技能资源目录+"\n请检查路径是否正确，目录是否已创建")
		return
	# 第二步：获取目录中的资源文件（仅 .tres / .res）
	var 文件列表: PackedStringArray = DirAccess.get_files_at(技能资源目录)
	var 资源文件列表: Array[String] = []
	for 文件名 in 文件列表:
		if 文件名.ends_with(".tres") or 文件名.ends_with(".res"):
			资源文件列表.append(文件名)

	if 资源文件列表.is_empty():
		print("技能目录为空，未加载任何技能")
		技能字典.clear()
		return

	# 第三步：逐个加载到临时数组，同时进行初步校验
	var 临时技能数组: Array[梅技能数据_回合制] = []
	var 名称路径记录: Dictionary[String, String] = {}  # 技能名称→文件路径，用于排查重复

	for 文件名 in 资源文件列表:
		var 完整路径: String = 技能资源目录 + 文件名
		var 加载结果: Resource = load(完整路径)

		# 校验①：加载失败（损坏文件 / 非资源文件）
		if 加载结果 == null:
			push_error("【梅自动加载】无法加载资源：" + 完整路径)
			push_error("  文件可能已损坏或不是有效的资源文件")
			return

		# 校验②：类型不匹配（无关资源误入目录）
		if not 加载结果 is 梅技能数据_回合制:
			push_error("【梅自动加载】文件类型不匹配：" + 完整路径)
			push_error("  期望类型：梅技能数据_回合制")
			push_error("  实际类型：" + 加载结果.get_class())
			return

		var 技能数据: 梅技能数据_回合制 = 加载结果

		# 校验③：技能名称为空
		if 技能数据.技能名称 == "":
			push_error("【梅自动加载】技能名称为空：" + 完整路径)
			push_error("  请为该技能资源填写技能名称属性")
			return

		# 校验④：技能名称重复
		if 名称路径记录.has(技能数据.技能名称):
			push_error("【梅自动加载】技能名称重复：「" + 技能数据.技能名称 + "」")
			push_error("  第一次出现在：" + 名称路径记录[技能数据.技能名称])
			push_error("  第二次出现在：" + 完整路径)
			push_error("  请修改其中一个技能的名称以消除冲突")
			return

		名称路径记录[技能数据.技能名称] = 完整路径
		临时技能数组.append(技能数据)

	# 第四步：所有校验通过 → 写入字典（存储引用，非拷贝）
	技能字典.clear()
	for 技能数据 in 临时技能数组:
		技能字典[技能数据.技能名称] = 技能数据

	print("技能数据重载完成，共加载 " + str(技能字典.size()) + " 个技能")
