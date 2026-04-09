extends Panel
@export var 快捷键:Key=Key.KEY_0
@export var 快捷编号:int=-1
@onready var 快捷文本: Label = $快捷键
@onready var 物品数量: Label = $物品数量
@onready var 按钮: Button = $按钮
@onready var 贴图: TextureRect = $贴图
var 背包检查器: 检查器背包
var 光标图标=preload("res://素材/豆包AI素材/图标/光标.png")
var 删除图标=preload("res://素材/豆包AI素材/图标/删除图标.png")
var 替换字典: Dictionary = {
	"None": "无",
	"Escape": "ESC",
	"Tab": "Tab",
	"BackTab": "Shift+Tab",
	"Backspace": "退格",
	"Enter": "回车",
	"KpEnter": "小键盘回车",
	"Insert": "插入",
	"Delete": "删除",
	"Pause": "暂停",
	"Print": "打印屏幕",
	"SysReq": "系统请求",
	"Clear": "清除",
	"Home": "主页",
	"End": "末尾",
	"Space": "空格",
	# 方向键/翻页键
	"Left": "左方向",
	"Up": "上方向",
	"Right": "右方向",
	"Down": "下方向",
	"PageUp": "上翻页",
	"PageDown": "下翻页",
	# 修饰键
	"Shift": "Shift",
	"Ctrl": "Ctrl",
	"Meta": "主键",#(Win/Command)
	"Alt": "Alt",
	"Hyper": "超级键",#(Linux)
	# 锁定键
	"CapsLock": "大写锁定",
	"NumLock": "小键盘锁定",
	"ScrollLock": "滚动锁定",
	# 小键盘专属键
	"KpMultiply": "(*)",
	"KpDivide": "(/)",
	"KpSubtract": "(-)",
	"KpPeriod": "(.)",
	"KpAdd": "(+)",
	"Kp0": "(0)",
	"Kp1": "(1)",
	"Kp2": "(2)",
	"Kp3": "(3)",
	"Kp4": "(4)",
	"Kp5": "(5)",
	"Kp6": "(6)",
	"Kp7": "(7)",
	"Kp8": "(8)",
	"Kp9": "(9)",
	# 菜单/帮助/导航键
	"Menu": "上下文",
	"Help": "帮助",
	"Back": "后退",
	"Forward": "前进",
	"Stop": "停止",
	"Refresh": "刷新",
	# 媒体控制键
	"VolumeDown": "音量减",
	"VolumeMute": "静音",
	"VolumeUp": "音量加",
	"MediaPlay": "媒体播放",
	"MediaStop": "媒体停止",
	"MediaPrevious": "上一曲",
	"MediaNext": "下一曲",
	"MediaRecord": "媒体录制",
	# 浏览器/快捷启动键
	"HomePage": "主页",
	"Favorites": "收藏",
	"Search": "搜索",
	"Standby": "待机",
	"OpenUrl": "打开网址",
	"LaunchMail": "启动邮箱",
	"LaunchMedia": "启动媒体",
	"Launch0": "快捷0",
	"Launch1": "快捷1",
	"Launch2": "快捷2",
	"Launch3": "快捷3",
	"Launch4": "快捷4",
	"Launch5": "快捷5",
	"Launch6": "快捷6",
	"Launch7": "快捷7",
	"Launch8": "快捷8",
	"Launch9": "快捷9",
	"LaunchA": "快捷A",
	"LaunchB": "快捷B",
	"LaunchC": "快捷C",
	"LaunchD": "快捷D",
	"LaunchE": "快捷E",
	"LaunchF": "快捷F",
	# 多语言/设备专属键
	"Globe": "地球键",#(Mac/iPad)
	"Keyboard": "屏幕键盘",#(iPad)
	"JisEisu": "英数键",#(Mac)
	"JisKana": "假名键",#(Mac)
	# 特殊符号键（直观符号保留，仅翻译英文名称）
	"Exclam": "!",
	"QuoteDbl": "\"",
	"NumberSign": "#",
	"Dollar": "$",
	"Percent": "%",
	"Ampersand": "&",
	"Apostrophe": "'",
	"ParenLeft": "(",
	"ParenRight": ")",
	"Asterisk": "*",
	"Plus": "+",
	"Comma": ",",
	"Minus": "-",
	"Period": ".",
	"Slash": "/",
	"Colon": ":",
	"Semicolon": ";",
	"Less": "<",
	"Equal": "=",
	"Greater": ">",
	"Question": "?",
	"At": "@",
	"BracketLeft": "[",
	"Backslash": "\\",
	"BracketRight": "]",
	"AsciiCircum": "^",
	"Underscore": "_",
	"QuoteLeft": "`",
	"BraceLeft": "{",
	"Bar": "|",
	"BraceRight": "}",
	"AsciiTilde": "~",
	"Yen": "¥",
	"Section": "§",
	# 其他
	"Unknown": "未知键"}
func _ready() -> void:
	await get_tree().process_frame
	背包检查器=横版单例.背包检查器
	var 快捷键资源:Shortcut=Shortcut.new()
	按钮.shortcut=快捷键资源
	var 按键:=InputEventKey.new()
	快捷键资源.events=[按键]
	按键.keycode=快捷键
	var 显示文本:String=OS.get_keycode_string(按键.keycode)
	快捷文本.text=替换字典.get(显示文本,显示文本)
	按钮.pressed.connect(切换物品栏)
	横版单例.更新_快捷键栏.connect(更新物品栏)
	更新物品栏()
func 切换物品栏():
	if 快捷编号==-2:
		背包检查器.切换()
	else :
		横版单例.快捷栏编号=快捷编号
		横版单例.更新_快捷键栏.emit()
func 更新物品栏():
	var 快捷键字典:=横版单例.快捷键字典
	if 快捷键字典.has(快捷编号):
		var 物品:物品方块=快捷键字典[快捷编号]
		贴图.texture=物品.icon
		物品数量.text=str(物品.数量)
	else :
		物品数量.text=""
		if 快捷编号==0:贴图.texture=光标图标
		elif 快捷编号==-1:贴图.texture=删除图标
		elif 快捷编号==-2:贴图.texture=计划.表格.道具贴图("背包")
		else :贴图.texture=null
	if 快捷编号==横版单例.快捷栏编号:
		切换边框颜色(Color(0.451, 0.329, 0.086))
	else :
		切换边框颜色(Color(0.67, 0.543, 0.288, 1.0))
func 切换边框颜色(颜色:Color):
	var 获取样式:StyleBox=get_theme_stylebox("panel").duplicate()
	获取样式.border_color=颜色
	add_theme_stylebox_override("panel",获取样式)
