#先继承移动物体
extends CharacterBody2D
#自定义类
class_name 角色类

#var velocity = Vector2.ZERO
@export  var 角色类_重力 = 2000
@export  var 角色类_移动速度 = 300
@export  var 角色类_移动速率 = 1.0
@export  var 角色类_止停滑速 = 0.1 #越高停的越快
@export  var 角色类_跳跃高度 = 600
@export var 角色类_击退时间=1.0

@export_category("角色的跳跃功能")
@export var 角色类_限制跳跃次数=2
@export var 角色类_跳跃递增高度=50


enum 角色类_状态{
	待机,
   	移动中,
	跳跃_上升,
	跳跃_下落,
	死亡,
	攻击
}
var 角色类_攻击动作=""
signal 信号_角色类_状态已变化
var 角色类_当前状态:角色类_状态=角色类_状态.待机:
	set(value):	
		if 角色类_当前状态!=value: 
			信号_角色类_状态已变化.emit(value)
		if 角色类_操作动作!="正常":
			信号_角色类_状态已变化.emit(value)
		角色类_当前状态=value
	#	print("主角的要改的状态:",value,"主角当前状态:",角色类_当前状态)
		pass
	

#用于 注释,比如击退等
var 角色类_操作动作="正常"

#私有变量
var __角色类_角色朝向 = 1 #1或-1
var __角色类_移动方向 = 0
var __角色类_是否跳跃 = 0
var __自动接管移动=false  #接管walk_x 私有变量
var __禁止移动=false #内部操作的禁止移动,击退会禁止
var __遥控=false #内部操控的
func 角色类_循环移动(_delta):
	
	#不在平台 则重力生效
	if not is_on_floor():
		#print("不在平台")
		velocity.y += 角色类_重力 * _delta
		velocity.y = clamp(velocity.y, - 2000, 2000)
	
	if __遥控==false: #遥控的适合不需要改
		if __自动接管移动==false:#默认不变
			if __角色类_移动方向!=0:
				velocity.x = __角色类_移动方向 * 角色类_移动速度 * 角色类_移动速率
			else:
				velocity.x = move_toward(velocity.x, 0, 角色类_移动速度*角色类_止停滑速 * 角色类_移动速率)
		else:#接管移动
			
			velocity.x=velocity.move_toward(Vector2.ZERO,100/角色类_击退时间).x#/角色类_击退时间
		#	print(velocity.x)
			if velocity.x==0:
				__自动接管移动=false
				角色类_操作动作="正常"	
				__禁止移动=false
		
	
	move_and_slide()
	
	#在地板时，还原？
	if is_on_floor() :
		__角色类_是否跳跃 = 0
		velocity.y = 0
	#记录最后的角色朝向
	if __角色类_移动方向!=0:
		__角色类_角色朝向=__角色类_移动方向
	
	if __遥控==true:#断点测试
		if 角色类_操作动作=="击退": return #不记录击退
		if velocity.x<0:
			__角色类_角色朝向=1
		if velocity.x>0:
			__角色类_角色朝向=-1	

	#击飞需要禁止操作吗...	
	#击飞的时候 同时站在地面上 恢复正常
	if velocity==Vector2(0,0) and is_on_floor():
		#print("在原地了")
		if 角色类_操作动作=="击飞":
			#print("执行还原了吗")
			角色类_操作动作="正常"
			__禁止移动=false	
			
	__角色类记录状态()	#用于记录当前角色是在做什么
	
func __角色类记录状态():
	#死亡不在记录
	if 角色类_当前状态==角色类_状态.攻击 : return
	if 角色类_当前状态==角色类_状态.死亡 : return
	if __角色类_是否跳跃==0:
		if velocity.x!=0:
			角色类_当前状态=角色类_状态.移动中
		else:
			角色类_当前状态=角色类_状态.待机
			
			#if 角色类_操作动作=="击退":ces
			#	角色类_操作动作="正常"
				#__禁止移动=false
	#if __角色类_是否跳跃!=0:
	if velocity.y<0:
		角色类_当前状态=角色类_状态.跳跃_上升
	#下落修复
	if velocity.y>0:
		角色类_当前状态=角色类_状态.跳跃_下落
	#写入角色朝向
	
#用于主动发出死亡信号
func 角色类_死亡():
	角色类_当前状态=角色类_状态.死亡
	角色类_操控_中断()#有关于AI中断
	
func 角色类_移动(dire):
	#击退时的禁止移动
	if __禁止移动:
		__角色类_移动方向=0
		return 
	else:
		__角色类_移动方向 = dire

func 角色类_自动移动(_x,角色类_移动速率):#也是自动移动
	#用于击退，等不受限制的情况。怪物AI请用角色类_操控
	velocity.x-=_x
	__自动接管移动=true
	角色类_操控_中断()
	pass

###用于击飞事件##用于击退事件
func 角色类_击飞击退(_强制跳跃高度 = 0,_x=0,_角色类_击退时间=角色类_击退时间):
	velocity.y = - _强制跳跃高度
	velocity.x -= _x
	角色类_操作动作="击飞"
	__禁止移动=true
	角色类_击退时间=_角色类_击退时间
	__自动接管移动=true
	角色类_操控_中断()
##用于击退事件
func 角色类_击退(_x,_角色类_击退时间=角色类_击退时间):
	__禁止移动=true
	velocity.x -= _x
	角色类_击退时间=_角色类_击退时间
	__自动接管移动=true
	角色类_操作动作="击退"
	角色类_操控_中断()
	
###用于击飞事件
func 角色类_击飞(_强制跳跃高度 = 0):
	if _强制跳跃高度 != 0: #脚本的强制跳跃
		velocity.y = - _强制跳跃高度
		角色类_操作动作="击飞"
		__禁止移动=true
		角色类_操控_中断()
		

func 角色类_强制跳跃(_强制跳跃高度):
	if _强制跳跃高度 != 0: #脚本的强制跳跃
		velocity.y = - _强制跳跃高度
		角色类_操控_中断()

func 角色类_跳跃():#_强制跳跃高度 = 0):
	if __禁止移动:
		return 

	if is_on_floor() and __角色类_是否跳跃 == 0:
		velocity.y = - 角色类_跳跃高度
		__角色类_是否跳跃 = 1
	
	elif __角色类_是否跳跃>0:
		if __角色类_是否跳跃<角色类_限制跳跃次数:
			__角色类_是否跳跃+=1
			velocity.y = - 角色类_跳跃高度 - 角色类_跳跃递增高度
			

#内部遥控用，适用于怪物AI
@export_category("AI操控类")
@export var 操控AI每秒行走距离:float=300.0
var ___AI缓动节点:Tween
signal ___AI缓动删除通知;
signal ___AI缓动节点完成或中断通知;
var ___移动的距离=0
func 角色类_操控(移动的距离:int): #从高到地缓慢移动
	___移动的距离=移动的距离
	
	var 到达的时间:float=abs(移动的距离)/操控AI每秒行走距离
	#print("移动的距离:",移动的距离,"到达的时间:",到达的时间)
	#受地心引力的影响，距离并不是真是X轴距离
	#print("操控开始:",___移动的距离,"到达时间:",到达的时间)
	__遥控=true
	#print("遥控前positon.x:",position,"操控距离:",abs(移动的距离),"AI行走距离:",操控AI每秒行走距离,"花费时长:",到达的时间)
	#velocity.x=操控AI每秒行走距离
	___AI缓动节点 = get_tree().create_tween()
	___AI缓动节点.set_ease(Tween.EASE_OUT_IN)
	#tween.tween_property(self, "velocity", Vector2(0,0), 到达的时间)#.as_relative()
	___AI缓动节点.tween_method(角色类_操控_缓动,0,abs(移动的距离),到达的时间)
	#tween.tween_property(self, "velocity", Vector2(移动的距离,0), 到达的时间).as_relative()
	#缓动结束后链接操控 发送已完毕
	___AI缓动节点.finished.connect(角色类_操控_通知) 
	
	#链接监听中断
	if ___AI缓动删除通知.is_connected(角色类_操控_通知)==false:
		___AI缓动删除通知.connect(角色类_操控_通知)
	
	#等待缓动完成 或者 中断在往下执行
	await ___AI缓动节点完成或中断通知
	#print("操控完成")
	#print("遥控后positon.x:",position)
#	print("代码已结束")
	__遥控=false
#返回
func 角色类_操控_缓动(补间值):
	#print(___移动的距离)
	if ___移动的距离>0:
		velocity.x=操控AI每秒行走距离
		#if 角色类_操作动作=="击退": return #不记录击退
		#__角色类_角色朝向=1
	if ___移动的距离<0:
		velocity.x=-操控AI每秒行走距离
		#if 角色类_操作动作=="击退": return #不记录击退
		#__角色类_角色朝向=-1
	
func 角色类_操控_中断():
	if ___AI缓动节点!=null:
		if ___AI缓动节点.is_valid():
			___AI缓动节点.kill() #中断补间
			___AI缓动删除通知.emit()
func 角色类_操控_通知():#告知已删除
	___AI缓动节点完成或中断通知.emit()
	pass
func 角色类_操控_待机(待机时间:float):#毫无用处的等待时间
	var 计时器=Timer.new()
	add_child(计时器)
	计时器.autostart=true
	计时器.start(待机时间)
	await 计时器.timeout
	计时器.queue_free()	
	pass
func 角色类_进入攻击(时间长度,攻击动画):
	角色类_当前状态=角色类_状态.攻击
	角色类_攻击动作=攻击动画
	#测试进入的攻击后的返回待机状态
	var 计时器=Timer.new()
	add_child(计时器)
	计时器.autostart=true
	计时器.start(时间长度)
	await 计时器.timeout
	计时器.queue_free()
	#返回待机
	角色类_当前状态=角色类_状态.待机
	pass
	
func 角色类_取状态():
	return 角色类_当前状态

func 角色类_取状态文本调试():
	printt("当前状态:%s" % [角色类_当前状态],"跳跃次数:%s" % [__角色类_是否跳跃],"操作动作:%s" % [角色类_操作动作],"角色最后朝向:%s" % [__角色类_角色朝向],"VEL:%s" % [velocity],"攻击动作:%s" %[ 角色类_攻击动作])
	pass

func 角色类_取已跳跃次数():
	return __角色类_是否跳跃
func 角色类_取角色朝向方向():
	return __角色类_角色朝向
func 角色类_取是否禁止移动():
	return __禁止移动
func 角色类_取是否在平台上():
	return is_on_floor()
