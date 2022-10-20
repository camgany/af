extends Node

export (PackedScene) var mario

func _ready():
	reaparecer()

func morir():
	get_tree().get_nodes_in_group("player")[0].queue_free() 
	gamehandler.vidas -= 1 
	if(gamehandler.vidas >= 0): 
		get_tree().reload_current_scene() 
	if(gamehandler.vidas == 0):
		get_tree().reload_current_scene() 
		
func reaparecer():
	var newmario = mario.instance() 
	add_child(newmario) 
	if(gamehandler.CheckPoint == Vector2(0,0)):
		newmario.global_position = get_tree().get_nodes_in_group("spawn")[0].global_position 
	else:
		newmario.global_position.x = gamehandler.CheckPoint.x 
		

func _on_Timer_timeout():
	gamehandler.set_time()
