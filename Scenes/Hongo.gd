extends KinematicBody2D

export (float) var VELOCIDADMOVIMIENTO
var Velocidad = Vector2() 
var tipo = 0 


func _ready():
	pass
	
func _physics_process(delta):
	Velocidad.y += gamehandler.GRAVEDAD * delta 
	
	if(get_node("Sprite").flip_h):
		Velocidad.x = -VELOCIDADMOVIMIENTO
	else:
		Velocidad.x = VELOCIDADMOVIMIENTO
	
	move_and_slide(Velocidad, Vector2(0,-1)) 
	
	if(is_on_wall()): #Si esta en pared
		get_node("Sprite").flip_h = !get_node("Sprite").flip_h 
		
	if(get_slide_collision(get_slide_count()-1 > 0)): 
		var hongocolision = get_slide_collision(get_slide_count()-1).collider 
		if(hongocolision.is_in_group("player")): 
			if(tipo != 2): 
				hongocolision.transformar() 
			else:
				gamehandler.vidas += 1 
				get_tree().get_nodes_in_group("sfx")[0].get_node("2").play()
			free()
	

