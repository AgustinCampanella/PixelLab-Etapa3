#EnemigoBase.gd
class_name EnemigoBase
extends NaveBase

## Atributos
var player_objetivo:Player = null
var dir_player:Vector2

## Metodos
func _ready() -> void:
	player_objetivo = DatosJuego.get_player_actual()
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")



## Metodos Custom
func _physics_process(delta: float) -> void:
	rotar_hacia_player()


func rotar_hacia_player() -> void:
	if player_objetivo:
		dir_player = player_objetivo.global_position - global_position
		rotation = dir_player.angle()


func _on_nave_destruida(nave: NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		player_objetivo = null


## Señales internas
func _on_body_entered(body: Node) -> void:
	._on_body_entered(body)
	if body is Player:
		body.destruir()
		destruir()
