extends Node2D

## Atributos Onready
onready var contenedor_proyectiles:Node

## Metodos
func _ready() -> void:
	conectar_seniales()
	crear_contenedores()

## Metodos custom
func conectar_seniales() -> void:
	Eventos.connect("disparo", self, "_on_disparo")

func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)

func _on_disparo(proyectil:Area2D) -> void:
	add_child(proyectil)
