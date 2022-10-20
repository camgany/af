extends KinematicBody2D
export (float) var VEL_DESPL 
export (float) var VEL_SALTO 
onready var state_machine = $AnimationTree.get("parameters/playback")
export (Texture) var mario_c 
export (Texture) var mario_g
export (PackedScene) var trans_c 
export (PackedScene) var trans_g
var Velocidad = Vector2() 
var saltando = false
enum estados {idle, caminando, muriendo, agachado}
var estado_actual = estados
var transformacion = 0 
var puede_disparar = true
var inmunidad = false


func _ready():
	estado_actual = estados.idle 

func _physics_process(delta):
	Velocidad.y += gamehandler.GRAVEDAD * delta 
	if(Input.is_action_just_pressed("tecla_s") && transformacion > 0):
		estado_actual = estados.agachado
		state_machine.travel("agachado")
	
	if(Input.is_action_just_pressed("tecla_d")):
		estado_actual = estados.caminando
		get_node("Sprite").flip_h = false 
		if(!saltando):
			state_machine.travel("caminando")
	
	if(Input.is_action_just_pressed("tecla_a")):
		estado_actual = estados.caminando
		get_node("Sprite").flip_h = true 
		if(!saltando):
			state_machine.travel("caminando")
		
	if(Input.is_action_just_released("tecla_d")):
		estado_actual = estados.idle
		if(!saltando):
			state_machine.travel("idle")
		
	if(Input.is_action_just_released("tecla_a")):
		estado_actual = estados.idle	
		if(!saltando):
			state_machine.travel("idle")
		
	if(Input.is_action_just_pressed("tecla_w") && !saltando): 
		get_tree().get_nodes_in_group("sfx")[0].get_node("1").play()
		saltando = true
		Velocidad.y = -VEL_SALTO
		state_machine.travel("jump")
		

	
	moverse() 
	
	Velocidad.y = clamp(Velocidad.y, -300,100) 
	
	var movimiento = Velocidad  
	move_and_slide(movimiento) 
	
	if(get_node("CollisionShape2D/RayCast2D").is_colliding()): 
		var obj_colisionado = get_node("CollisionShape2D/RayCast2D").get_collider() 
		if(obj_colisionado.is_in_group("cubo")): 
			Velocidad.y += VEL_SALTO / 6
			if(obj_colisionado.cantidad > 0 && !obj_colisionado.cooldown):
				obj_colisionado.romper_cubo() 
			elif(obj_colisionado.cantidad == 0 && !obj_colisionado.cooldown):
				obj_colisionado.golpear_vacio()
		elif(obj_colisionado.is_in_group("brick")): 
			Velocidad.y += VEL_SALTO / 6
			if(transformacion > 0): 
				get_tree().get_nodes_in_group("sfx")[0].get_node("4").play()
				gamehandler.set_puntos(30)
				var newexp = get_tree().get_nodes_in_group("lista_obj")[0].ladrillo_exp.instance()
				newexp.global_position = obj_colisionado.global_position 
				obj_colisionado.free() 
				get_tree().get_nodes_in_group("nivel")[0].add_child(newexp)
				yield(get_tree().create_timer(3.0),"timeout") 
				newexp.queue_free() 
	
	
	if(get_node("CollisionShape2D/RayCast2P").is_colliding()):	
		var obj_colisionado = get_node("CollisionShape2D/RayCast2P").get_collider()
		if(obj_colisionado.is_in_group("enemigo")):
			obj_colisionado.recibir_golpe()
			Velocidad.y = -VEL_SALTO /3
	
	if(get_slide_collision(get_slide_count()-1 > 0)): 
		var obj_colisionado = get_slide_collision(get_slide_count()-1).collider 
		if(obj_colisionado == null):
			return 
		if(obj_colisionado.is_in_group("suelo") && saltando): 
			get_node("animaciones").play("idle")
			saltando = false
			if(Velocidad.x != 0): 
				get_node("animaciones").play("caminando")
		elif(obj_colisionado.is_in_group("hongo")): 
			if(obj_colisionado.tipo == 0): 
				transformar()
			elif(obj_colisionado.tipo == 2): 
				gamehandler.vidas += 1 
				get_tree().get_nodes_in_group("sfx")[0].get_node("2").play()
			obj_colisionado.free() 
		elif(obj_colisionado.is_in_group("flor")): 
			transformar() #Transforma
			obj_colisionado.free()
		elif(obj_colisionado.is_in_group("enemigo") && obj_colisionado.vivo): 
			if(obj_colisionado.is_in_group("tortuga")):
				if(obj_colisionado.pateada):
					destransformar()
				else:
					dar_inmunidad()
					obj_colisionado.pateada = true
					if(obj_colisionado.global_position.x > global_position.x): 
						obj_colisionado.get_node("Sprite").flip_h = true 
					else:
						obj_colisionado.get_node("Sprite").flip_h = false
			else:
				destransformar()

	
func moverse():
	if(estado_actual == estados.caminando): 
		if(get_node("Sprite").flip_h): 
			Velocidad.x = -VEL_DESPL 
		else: 
			Velocidad.x = VEL_DESPL 
	elif(estado_actual == estados.idle): 
		Velocidad.x = 0 
func transformar():
	get_tree().get_nodes_in_group("sfx")[0].get_node("10").play()
	if(transformacion < 2):
		get_node("Sprite").texture = mario_g
		
		
	
func destransformar():
	if(inmunidad):
		return 
	if(transformacion > 0):
		get_node("Sprite").texture = mario_c
			
	else:
		get_tree().get_nodes_in_group("main")[0].morir()
	dar_inmunidad()
	
func dar_inmunidad():
	inmunidad = true
	yield(get_tree().create_timer(1.0),"timeout")
	inmunidad = false
		


func _on_VisibilityNotifier2D_screen_exited():
	if(!gamehandler.win):
		get_tree().get_nodes_in_group("main")[0].morir() 
	
