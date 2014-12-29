sourcemod-nt-hudReload
======================

SourceMod plugin for Neotokyo to reload players' HUD view.

Commands:
  - <i>sm_hud</i> : Reload HUD manually

Cvars:
  - <i>sm_hud_behaviour</i> : If 0, only reload HUD upon player's !hud command. If positive integer, reload HUD automatically every X rounds. Default: 0.

Note that hud reloading will mess up the chat temporarily, so you may not want to do it every round.
