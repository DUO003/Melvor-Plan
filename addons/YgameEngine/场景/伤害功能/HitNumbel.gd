extends Node


#使用一 绘制一次伤害
	
#	HitNumbel.draw(
#		randi() % 100000,
#		"命中",
#		"正常",
#		Vector2(500,300)
#	)
#使用2 用数组一次性绘制多次伤害
#	var _position=Vector2(300,300)
#	var _count=4
#	var _numbelarr=[["命中", 20478], ["命中", 20278], ["暴击", 24311], ["暴击", 22333]]
#	HitNumbel.drawArr(_position,_numbelarr,_count)		

func drawArr(_position,_numbeiArr):#解析多次伤害
	for i in _numbeiArr.size():
		await get_tree().create_timer(0.03).timeout
		draw(_numbeiArr[i][1],_numbeiArr[i][0],"正常",_position,i)
	
func draw(_numbel,_Type="命中",_Mode="正常",_position:Vector2=Vector2(0,0),ii=0):#用于解析一次伤害
	#没有return 
	#_type 暴击,躲避,命中
	#_mode 0正常,1受伤,2补血,3补蓝
	var _png="res://addons/YgameEngine/场景/伤害功能/伤害数字/r2.png"
	#选择图片
	if _Mode=="正常":
		if _Type=="命中":
			_png="res://addons/YgameEngine/场景/伤害功能/伤害数字/r1.png"
		elif _Type=="暴击":
			_png="res://addons/YgameEngine/场景/伤害功能/伤害数字/r4.png"
		elif _Type=="躲避":
			
			pass
	elif _Mode=="受伤":
		_png="res://addons/YgameEngine/场景/伤害功能/伤害数字/d2.png"
	elif _Mode=="补血":
		_png="res://addons/YgameEngine/场景/伤害功能/伤害数字/g2.png"
	elif _Mode=="补蓝":
		_png="res://addons/YgameEngine/场景/伤害功能/伤害数字/i2.png"
	var p=load(_png)
	var _height=p.get_height()#图片高度
	var _width=p.get_width()/10#图片宽度
		
	_numbel+=randi_range(-3,2) as int #随机浮动数字
	var _numbel_str=str(_numbel) #制转到字符串
	var sjx=randi_range(-10,10) #随机X轴
	var sjy=randi_range(-5,5)  #随机Y轴
	#设置动画模式 0是静态的放大缩小,1是上飘
	var mode=randi() % 2#让他0-1随机
	for i in _numbel_str.length():
		#打印伤害
		var cd=i*(_width)#计算伤害长度
		var a=load("res://addons/YgameEngine/场景/伤害功能/伤害.tscn").instantiate()
		a.position.x=_position.x+sjx+cd
		a.position.y=_position.y+sjy+(ii*-(_height))
		a.numbel=_numbel_str[i] as int#打印数字
		a.mode=mode #动画模式
		a._png=_png
		self.add_child(a)
