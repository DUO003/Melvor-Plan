@tool  # 关键：让脚本在编辑器内运行，实现实时预览
extends Panel
class_name 梅资源加点
## 设定资源字典中的其中一种资源
@onready var 回复速度: Label = $回复速度
@onready var 点数: Label = $点数
@onready var 增加: Button = $"+"
@onready var 减少: Button = $"-"
@onready var 贴图: TextureRect = $贴图
var 类型
var 增加回复速度:float=0
var 资源点数:int=0
@export var 资源名称: String = "木材":
	set(值):
		资源名称=值
		if Engine.is_editor_hint():
			更新文本()
func _ready() -> void:
	if not Engine.is_editor_hint():
		增加.pressed.connect(尝试加点.bind(1))
		减少.pressed.connect(尝试加点.bind(-1))
		类型=计划.手工.检查资源类(资源名称)
		更新文本()
		计划.更新_UI.connect(更新文本)
		var 纹理 = 计划.表格.道具贴图(资源名称)
		贴图.texture=纹理
	else :
		类型="基础"
		回复速度.text="回复+%.2f"%[增加回复速度]
func 更新文本():
	if not Engine.is_editor_hint():
		更新回复速度()
	if 回复速度 and 点数:
		if Engine.is_editor_hint():
			回复速度.text="回复+%.2f"%[增加回复速度]
		else :
			var 制作力:float=计划.装备.制作力
			var 上限:int
			if 类型=="特殊":
				上限=int(pow(制作力, 1.0 / 1.5))
				回复速度.text=tr("<自动制作加点>")%[增加回复速度,上限]
			else :
				上限=int(计划.装备.制作力)+5
				回复速度.text=tr("<资源回复加点>")%[增加回复速度,上限]
		点数.text="%d"%资源点数
func 更新回复速度():
	资源点数=计划.梅存档.手工.基础资源加点.get(资源名称,0)
	增加回复速度=计划.手工.资源公式(资源名称,资源点数)
func 尝试加点(值:int):
	if 计划.手工.基础资源加点(资源名称,值):
		更新回复速度()
		if 值>0:计划.语法糖通知(tr("<加点成功>")%[资源名称,资源点数],"资源加点")
		else :计划.语法糖通知(tr("<代币退还>")%[资源点数],"资源加点")
		计划.手工.重算资源回复()
		计划.更新_UI.emit()
	else :计划.语法糖通知(tr("<操作失败>"),"资源加点")
