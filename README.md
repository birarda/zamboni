# Zamboni

Zamboni is an opinionated NHL.tv viewer for Apple devices, built in SwiftUI. 

It's in extremely rough shape and basically just working enough to serve my purposes. I'll update it further but suspect even in this state it might be useful for others given that it's playoff time.

- I watch frequently delayed, so the main goal of the application is to avoid spoilers at all costs. Currently all streams should start at the beginning, and I'd like to update the AV player to hide the time bar as well.
- There is janky HTTPS proxy support which I use with a wireguarded Privoxy container

The API interaction is only possible thanks to the excellent work already done by some related projects:
https://github.com/kompot/nhl-tv-geeky-streams
https://github.com/eracknaphobia/plugin.video.nhlgcl