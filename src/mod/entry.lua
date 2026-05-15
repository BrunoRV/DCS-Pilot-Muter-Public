local self_ID = "DCS Pilot Muter"

declare_plugin(self_ID,
{
	image		 = "MuterIcon.png",
	installed	 = true,
	dirName		 = current_mod_path,
	load_immediately = true,

	displayName	 = "DCS Pilot Muter",
	shortName	 = "DCS Muter",
	fileMenuName = "DCS Muter",

	version		 = "2.0.0",
	state		 = "installed",
	developerName= "Bruno V",
	info		 = _("Non-invasive player voice muter. Disables the player character's radio voice directory and overrides speech events to ensure radio silence while keeping radio commands functional."),
})

plugin_done()
