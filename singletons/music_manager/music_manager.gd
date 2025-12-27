extends AudioStreamPlayer

enum {
	BASS,
	PAD,
	DRONE,
	MELODY,
	SPACENINJA,
	RHYTHMBLIP,
	KICK,
	TOP
}

@export var bpm: float = 124

## not an actual beat, equal to 32 beats
var beat = 0

var aggrod_enemies: Array = []

func _ready() -> void:
	$Timer.wait_time = 32 * 60 / bpm
	$MicroTimer.wait_time = 4 * 60 / bpm
	
	SignalBus.game_started.connect(setup)
	SignalBus.player_death.connect(_on_player_death)
	SignalBus.player_repair.connect(_on_player_repair)
	
	for i in range(stream.stream_count):
		stream.set_sync_stream_volume(i, -80)

func setup() -> void:
	var volume: float = AudioServer.get_bus_volume_linear(1)
	
	var t: Tween = get_tree().create_tween()
	t.tween_method(set_music_bus_volume, volume, 0, 2)
	
	await t.finished
	$MainMenuMusic.stop()
	
	get_tree().create_tween().tween_method(set_music_bus_volume, 0.0, volume, 1)
	
	$Timer.start()
	$MicroTimer.start()
	fade_in(BASS)
	fade_in(DRONE)
	fade_in(SPACENINJA)
	
	play()

func set_music_bus_volume(vol: float) -> void:
	AudioServer.set_bus_volume_linear(1, vol)

func set_playback(target: int, status: bool) -> void:
	if status:
		fade_in(target)
	else:
		fade_out(target)

func fade_in(target: int) -> void:
	if not target == KICK:
		var t: Tween = get_tree().create_tween()
		t.tween_method(
			func(vol: float): 
				stream.set_sync_stream_volume(target, vol),
			stream.get_sync_stream_volume(target),
			0,
			.3
		)
	else:
		stream.set_sync_stream_volume(target, 0)

func fade_out(target: int) -> void:
	var t: Tween = get_tree().create_tween()
	
	t.tween_method(
		func(vol: float): 
			stream.set_sync_stream_volume(target, vol),
		stream.get_sync_stream_volume(target),
		-80,
		.25
	)

func toggle_sidechain(_status: bool) -> void:
	var _sidechained_audioplayers: Array[int] = [
		BASS,
		PAD
	]
	
	#for audio: int in sidechained_audioplayers:
		#if not stream.get("playbacks")[audio].get_sync_stream(audio).get_current_clip_index() == 1 if status else 0:
			#stream.get("playbacks")[audio].get_sync_stream(audio).switch_to_clip(status)

func _on_timer_timeout() -> void:
	beat += 1
	
	if beat >= 4:
		if beat % 2 == 0:
			set_playback(PAD, randf() > .5)
			set_playback(SPACENINJA, randf() > .6)
		set_playback(RHYTHMBLIP, true)
	
	if stream.get_sync_stream_volume(KICK) == -10 or stream.get_sync_stream_volume(TOP) > -10:
		if beat % 2 == 0:
			set_playback(MELODY, randf() > .3)
	else:
		set_playback(MELODY, false)


func _on_micro_timer_timeout() -> void:
	if Gamedata.core.linear_velocity.length() > 30:
		fade_in(KICK)
		toggle_sidechain(true)
	else:
		fade_out(KICK)
		toggle_sidechain(false)
	
	
	for enemy in aggrod_enemies:
		if not is_instance_valid(enemy):
			aggrod_enemies.erase(enemy)
	set_playback(TOP, len(aggrod_enemies))

func _on_player_death() -> void:
	get_tree().create_tween().tween_property(AudioServer.get_bus_effect(0,0), "cutoff_hz", 400, .5)

func _on_player_repair() -> void:
	get_tree().create_tween().tween_property(AudioServer.get_bus_effect(0,0), "cutoff_hz", 20500, 4)
