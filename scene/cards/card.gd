extends Control
class_name card

var velocity = Vector2.ZERO
var damping = 0.35
var stiffness = 500

var preDeck:deck

var cardType:GameType.CardType

@export var cardClass:String
@export var cardName:String
@export var maxStackNum:int
@export var cardWeight:float
@export var cardInfo:Dictionary

@export var pickButton:Button
var dup
var num = 1



enum cardState{following,dragging,vfs,fake,focus}
@export var cardCurrentState=cardState.following

@export var follow_target:Node
var whichDeckMouseIn

func _ready() -> void:
	add_to_group("card")

func _process(delta: float) -> void:
	match  cardCurrentState:
		cardState.dragging:
			follow(get_global_mouse_position()-size/2,delta)
			
			var mouse_position = get_global_mouse_position()
			var nodes = get_tree().get_nodes_in_group("cardDropable")
			for node in nodes:
				if node.get_global_rect().has_point(mouse_position)&&node.visible==true:
					whichDeckMouseIn=node
			
		cardState.following:
			if follow_target!=null:
				follow(follow_target.global_position,delta)
		cardState.vfs:
			follow(get_global_mouse_position()-size/2,delta)
				
func follow(target_position:Vector2,delta:float):
		var displacement = target_position - global_position
		var force = displacement * stiffness
		velocity += force * delta
		velocity *= (1.0 - damping)
		global_position += velocity * delta

func cardStack(cardToStack):
	var stackNum=cardToStack.num
	if num+stackNum > maxStackNum:
		return false
	else:
		num=num+stackNum
		paintCard()
		print("卡牌被堆叠了")
		return true

func _on_button_button_down() -> void:
	if cardCurrentState==cardState.following:
		var numc=num
		num=1
		paintCard()
		dup=self.duplicate() as card
		VfSlayer.add_child(dup)
		dup.global_position=global_position
		dup.cardCurrentState=cardState.vfs
		cardCurrentState = cardState.dragging
		get_parent().get_parent().update_weight()#在满的时候就要先检测一下了，相对于提前删除这部分重量
		if numc!=1&&numc!=null:
			var c:card = PlayerInfo.add_new_card(cardName,get_parent().get_parent(),self)
			c.follow_target.queue_free()
			c.follow_target=follow_target
			c.global_position=global_position
			c.num=numc-1
			c.paintCard()
		elif follow_target!=null:
			follow_target.queue_free()
		get_parent().get_parent().update_weight()
		
		pass # Replace with function body.


func _on_button_button_up() -> void:
	if dup!=null:
		dup.queue_free()
	
	if whichDeckMouseIn!=null:
		whichDeckMouseIn.add_card(self)
	else:
		if preDeck!=null:
			preDeck.add_card(self)
		else:
			print("有一张卡牌没有preDeck，也没有whichDeckMouseIn，一般是由于点的太快导致的")
			
	cardCurrentState = cardState.following
		
	pass # Replace with function body.

func initCard(Nm) -> void:
	cardInfo=CardsInfo.itemCard[Nm]
	cardWeight=float(cardInfo["base_cardWeight"])
	cardClass=cardInfo["base_cardClass"]
	cardName=cardInfo["base_cardName"]
	maxStackNum=int(cardInfo["base_maxStack"])
	cardCurrentState=cardState.following
	cardType=GameType.get_cardType(cardInfo['base_cardType'])
	paintCard()


func paintCard():
	
	#print(cardInfo)
	pickButton=$Button
	var imgPath="res://assets/image/cardImg/"+str(cardName)+".png"
	$Control/ColorRect/itemImg.texture=load(imgPath)
	$Control/ColorRect/name.text=cardInfo[ "base_displayName"]
	$allButton.text = "X"+str(num)

func _on_all_button_button_down() -> void:
	dup=self.duplicate()
	VfSlayer.add_child(dup)
	dup.global_position=global_position
	dup.cardCurrentState=cardState.vfs
	cardCurrentState = cardState.dragging
	if follow_target!=null:
		follow_target.queue_free()	
	pass # Replace with function body.


func is_card_following() -> bool:
	if cardCurrentState == cardState.following:
		return true
	return false
	
func _on_button_mouse_entered() -> void:
	if dup == null:
		dup=self.duplicate() as card
		VfSlayer.add_child(dup)
		dup.global_position=global_position
		dup.cardCurrentState=cardState.focus
		dup.scale = Vector2(1.2, 1.2)
	pass
	
func _on_button_mouse_exited() -> void:
	if dup!=null:
		dup.queue_free()
	pass
	
func get_card_type() -> GameType.CardType:
	return cardType
	pass
	
func set_card_type(setType: GameType.CardType) -> void:
	cardType = setType
