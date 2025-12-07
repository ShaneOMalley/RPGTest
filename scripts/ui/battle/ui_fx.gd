@tool
class_name UIFX extends Control

var test: GPUParticles2D
func _ready():
	var particles := $GPUParticles2D as GPUParticles2D

	if not Engine.is_editor_hint():
		particles.finished.connect(func(): queue_free())

	particles.restart()

func _get_configuration_warnings() -> PackedStringArray:
	var result: PackedStringArray = []

	var particles := $GPUParticles2D as GPUParticles2D
	if not particles:
		result.append("Missing a child \"GPUParticles2D\" of type GPUParticles2D")
	elif !particles.one_shot:
		result.append("GPUParticles2D is not set to one-shot. It will play forever and not disappear")

	return result