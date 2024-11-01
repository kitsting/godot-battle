extends Node

var music_enabled = false


func play_music(song, volume = 0):
	if !System.disablemusic:
		if !$Music.playing:
			$Music.volume_db = volume
			$Music.stream = load(song)
			$Music.play()
		else:
			await stop_song()
			play_music(song)


func stop_song():
	if $Music.playing:
		var tween = create_tween()
		tween.tween_property($Music,"volume_db",-80,0.4)
		await tween.finished
		$Music.stop()
		$Music.volume_db = 0
		
		
func play_sound(sound, channel = "ui_misc", volume = 0):
	get_node(channel).stream = load(sound)
	get_node(channel).volume_db = volume
	get_node(channel).play()


func pause_overworld_music(fade_time = 0.4):
	var tween = create_tween()
	tween.tween_property($OverworldMusic,"volume_db",-80,fade_time)
	await tween.finished
	$OverworldMusic.stream_paused = true
	
func resume_overworld_music():
	$OverworldMusic.stream_paused = false
	var tween = create_tween()
	tween.tween_property($OverworldMusic,"volume_db",0,0.4)
	
func stop_overworld_music(fade_time = 1):
	var tween = create_tween()
	tween.tween_property($OverworldMusic,"volume_db",-80,fade_time)
	await tween.finished
	$OverworldMusic.stop()

func set_overworld_music(file):
	if file != "":
		var loaded_stream = load(file)
		if loaded_stream != $OverworldMusic.stream:
			var out_tween = create_tween()
			out_tween.tween_property($OverworldMusic,"volume_db",-80,1)
			await out_tween.finished
			
			$OverworldMusic.stop()
			$OverworldMusic.stream = loaded_stream
			$OverworldMusic.play()
			
			var in_tween = create_tween()
			in_tween.tween_property($OverworldMusic,"volume_db",0,1)
