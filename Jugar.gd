extends Button


func _on_Jugar_pressed():
	get_tree().change_scene("res://Instrucciones.tscn")


func _on_Salir_pressed():
	get_tree().quit()
