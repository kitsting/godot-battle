extends Control


func collect():
	$HBoxContainer/Count.text = String(System.registry_lookup("money"))
	$CoinAnim.stop()
	$CoinAnim.play("collect")
