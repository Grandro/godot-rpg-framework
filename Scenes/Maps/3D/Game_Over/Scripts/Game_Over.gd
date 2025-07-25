extends MapBase3D

func load_data_init():
	super()
	
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	audio_manager_si.flatten_bgm()
