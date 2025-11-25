extends Node
class_name 梅声音
# 播放鼠标点击音效的封装方法
func 播放鼠标点击音效():
	# 检查配置中音量是否为0，为0则不播放
	if 计划.配置文件.has("音量") and 计划.配置文件["音量"] == 0:
		return
	# 创建音频播放器节点
	var 音频播放器 = AudioStreamPlayer.new()
	# 加载音效文件
	var 音效路径 = "res://素材/音效/点击鼠标音效_爱给网_aigei_com.mp3"
	var 音频流 = load(音效路径)
	if 音频流:
		音频播放器.stream = 音频流
		# 添加到当前节点（确保调用该方法的脚本已附加到场景节点）
		add_child(音频播放器)
		# 播放完成后自动删除节点
		音频播放器.finished.connect(音频播放器.queue_free)
		# 开始播放
		音频播放器.play()
		print("鼠标点击音效")
	else:
		print("鼠标点击音效加载失败: ", 音效路径)
