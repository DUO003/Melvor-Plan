extends Panel
class_name 梅收藏卡片
@onready var 图标: TextureRect = $图标
@onready var 数据: Label = $数据
@onready var 简介: RichTextLabel = $简介
@onready var 提交: Button = $提交
@export var 物品名称:String
var 文案="%s\r背包数量:%d\r提交:%d"
var 提交数量: SpinBox
var 单卡价值:float=0
func _ready() -> void:
	if not 物品名称:
		return
	计划.更新_UI.connect(更新UI)
	提交.pressed.connect(提交卡片)
	更新UI()
func 更新UI():
	图标.texture=计划.表格.道具贴图(物品名称)
	数据.text=文案%[物品名称,计划.检查背包物品数量(物品名称),计划.原罪_贪婪(物品名称,"卡片数量")]
	简介.text=计划.表格.蓝图数据(物品名称,"简介")
	检查可提交()
	#图标.mouse_entered.connect(检查可提交)
	#图标.mouse_exited.connect(func():提交.visible=false)
	#提交.visible=false
func 检查可提交():
	提交.visible=计划.检查背包物品数量(物品名称)>=1
func 提交卡片():
	var 提交次数=1
	if 提交数量:
		提交次数=提交数量.value
	var 背包=计划.检查背包物品数量(物品名称)
	if 提交次数==0 and 背包>=1:
		提交次数=背包
	if 背包>=提交次数:
		计划.语法糖通知("提交%s成功"%物品名称,"贪婪提示")
		计划.语法糖消耗物品(物品名称,提交次数)
		计划.原罪_贪婪(物品名称,"卡片数量",提交次数)
		var 贪婪值=计划.数据状态("贪婪")
		if 贪婪值<=10:
			计划.数据原罪("原罪值","贪婪",单卡价值*提交次数*(10-贪婪值)/10)
			计划.数据状态("贪婪",0,1+贪婪值)
		计划.更新_UI.emit()
		计划.保存存档("提交卡片")
		计划.steam.解锁成就("无尽贪婪")
	else :
		计划.语法糖通知("提交%s失败,物品不足%d"%[物品名称,提交次数],"贪婪提示")
		
