class_name Escudo
extends Area2D

## Atributos Export
export var energia:float = 8.0
export var radio_desgaste:float = -1.6


## Variables
var esta_activado:bool = false setget, get_esta_activado
var energia_original:float


## Setters y Getters
func get_esta_activado() -> bool:
	return esta_activado


## Metodos
func _ready() -> void:
	energia_original = energia
	set_process(false)
	controlar_colisionador(true)


func _process(delta: float) -> void:
	controlar_energia(radio_desgaste * delta)


## Metodos Custom
func controlar_colisionador(esta_desactivado:bool) -> void:
	$CollisionShape2D.set_deferred("disabled", esta_desactivado)


func controlar_energia(consumo:float) -> void:
	energia += consumo
	
	if energia > energia_original:
		energia = energia_original
	elif energia <= 0.0:
		desactivar()


func activar() -> void:
	if energia <= 0.0:
		return
	
	controlar_colisionador(false)
	esta_activado = true
	$AnimationPlayer.play("activandose")
	print("Activado")


func desactivar():
	set_process(false)
	esta_activado = false
	controlar_colisionador(true)
	$AnimationPlayer.play_backwards("activandose")


## Señales Internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "activandose" and esta_activado:
		$AnimationPlayer.play("activado")
		set_process(true)


func _on_body_entered(body: Node) -> void:
	body.queue_free()
