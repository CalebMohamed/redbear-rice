# redbear-rice

A repo for all of my rices managed with chezmoi.
- littlebear: minimal dwl + waybar rice
- smoothbear: niri + quickshell rice (abandoned)
- waterbear: hypr + quickshell rice

## Overall Setup
Currently I have it so that there is a start-session
script which takes the name of a profile.
This profile then changes the XDG\_CONFIG\_HOME
and XDG\_CACHE\_HOME to ~/.config/profile/ and
~/.cache/profile respectively. The script also
expects an executable env in .config/profiles/profile/env
which should set the environment variables appropriately
for that session's WM and graphical backend.

I consequently, have all of the configs separated,
but managed by one chezmoi. And the sessions should
be of the form:

[Desktop Entry]
Name=profile
Exec=/home/caleb/.local/bin/start-session profile
Type=Application

## Packages 
I will continue to add to this and plan to write an 
installer in the future for each profile.
