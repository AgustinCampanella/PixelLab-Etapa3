extends Node2D

#Atributos Export
export var explosion:PackedScene = null
export var meteorito:PackedScene = null
export var explosion_meteorito:PackedScene = null
export var sector_meteoritos:PackedScene = null
export var tiempo_transicion_camara:float = 1.0
export var enemigo_interceptor:PackedScene = null

## Atributos Onready
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos:Node
onready var contenedor_sector_meteoritos:Node
onready var contenedor_enemigos:Node
onready var camara_nivel:Camera2D = $CameraNivel
onready var camara_player:Camera2D = $Player/CameraPlayer

## Atributos
var meteoritos_totales:int = 0
var player:Player = null

## Metodos
func _ready() -> void:
	conectar_seniales()
	crear_contenedores()
	player = DatosJuego.get_player_actual()

## Metodos Custom
func conectar_seniales() -> void:
	Eventos.connect("disparo", self, "_on_disparo")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("spawn_meteorito", self, "_on_spawn_meteoritos")
	Eventos.connect("meteorito_destruido", self, "_on_meteorito_destruido")
	Eventos.connect("nave_en_sector_peligro", self, "_on_nave_en_sector_peligro")
	Eventos.connect("base_destruida", self, "_on_base_destruida")

func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child(contenedor_meteoritos)
	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = "ContenedorSectorMeteoritos"
	add_child(contenedor_sector_meteoritos)
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "ContenedorEnemigos"
	add_child(contenedor_enemigos)


func crear_sector_meteoritos(centro_camara:Vector2, numero_peligros:int) -> void:
	meteoritos_totales = numero_peligros
	var new_sector_meteoritos:SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, numero_peligros)
	camara_nivel.global_position = centro_camara
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = camara_player.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		camara_player.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
	)


func controlar_meteoritos_restantes() -> void:
	meteoritos_totales -= 1
	print(meteoritos_totales)
	if meteoritos_totales == 0:
		contenedor_sector_meteoritos.get_child(0).queue_free()
		camara_player.set_puede_hacer_zoom(true)
		var zoom_actual = camara_player.zoom
		camara_player.zoom = camara_nivel.zoom
		camara_player.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camaras(
		camara_nivel.global_position,
		camara_player.global_position,
		camara_player,
		tiempo_transicion_camara * 0.10
		)


func transicion_camaras(desde:Vector2, hasta:Vector2, camara_actual:Camera2D, tiempo_transicion:float) -> void:
	$Tween.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo_transicion_camara,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	$Tween.start()


func crear_posicion_aleatoria(rango_horizontal:float, rango_vertical:float) -> Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	
	return Vector2(rand_x, rand_y)


func crear_sector_enemigos(num_enemigos: int) -> void:
	for i in range(num_enemigos):
		var new_interceptor:EnemigoInterceptor = enemigo_interceptor.instance()
		var spawn_pos:Vector2 = crear_posicion_aleatoria(1000.0, 800.0)
		new_interceptor.global_position = player.global_position + spawn_pos
		contenedor_enemigos.add_child(new_interceptor)


## Conexion señales externas
func _on_disparo(proyectil:Area2D) -> void:
	contenedor_proyectiles.add_child(proyectil)

func _on_nave_destruida(nave:Player, posicion:Vector2, num_explosiones: int) -> void:
	if nave is Player:
		transicion_camaras(
			posicion,
			posicion + crear_posicion_aleatoria(-200.0, 200.0),
			camara_nivel,
			tiempo_transicion_camara
		)
	crear_explosion(posicion, num_explosiones, 0.6, Vector2(100.0, 50.0))

func _on_spawn_meteoritos(pos_spawn:Vector2, dir_meteorito:Vector2, tamanio:float) -> void:
	var new_meteorito:Meteorito = meteorito.instance()
	new_meteorito.crear(
		pos_spawn,
		dir_meteorito,
		tamanio
	)
	contenedor_meteoritos.add_child(new_meteorito)

func _on_meteorito_destruido(pos:Vector2) -> void:
	var new_explosion:ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)
	
	controlar_meteoritos_restantes()

func _on_nave_en_sector_peligro(centro_cam:Vector2, tipo_peligro:String, num_peligros:int) -> void:
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_cam, num_peligros)
	elif tipo_peligro == "Enemigo":
		crear_sector_enemigos(num_peligros)

func _on_base_destruida(pos_partes: Array) -> void:
	for posicion in pos_partes:
		crear_explosion(posicion)
		yield(get_tree().create_timer(0.5), "timeout")

func crear_explosion(
	posicion: Vector2, 
	numero: int = 1, 
	intervalo: float = 0.0, 
	rangos_aleatorios: Vector2 = Vector2(0.0, 0.0)) -> void:
		for i in range(numero):
			var new_explosion:Node2D = explosion.instance()
			new_explosion.global_position = posicion + crear_posicion_aleatoria(
				rangos_aleatorios.x,
				rangos_aleatorios.y
			)
			add_child(new_explosion)
			yield(get_tree().create_timer(intervalo), "timeout")



func _on_Tween_tween_completed(object: Object, _key: NodePath) -> void:
	if object.name == "CameraPlayer":
		object.global_position = $Player.global_position
