extends Node3D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var character: CharacterBody3D = $Character
@onready var speed: HSlider = $SkillAssignments/AssignableSkills/SpeedContainer/Speed
@onready var health: HSlider = $SkillAssignments/AssignableSkills/HealthContainer/Health

func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _on_speed_drag_ended(value_changed: bool) -> void:
	if value_changed:
		character.update_stat(Enums.StatType.SPEED, speed.value)


func _on_health_drag_ended(value_changed: bool) -> void:
	if value_changed:
		character.update_stat(Enums.StatType.HEALTH, health.value)
