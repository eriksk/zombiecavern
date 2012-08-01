module ZombieCavern
	class SoundManager

		def initialize game 
			# sounds
			@sounds = {
				:hit => game.load_sound('zombie_hit'),
				:switch_weapon => game.load_sound('switch_weapon'),
				:wilhelm_scream => game.load_sound('wilhelm_scream'),
				:blood_1 => game.load_sound('blood_1'),
				:blood_2 => game.load_sound('blood_2'),
			}
			@songs = {
				:song => game.load_song('song', 'mp3')
			}
		end

		def play(name, volume = 1.0)
			@sounds[name].play(volume)
		end

		def play_song(name)
			@songs[name].volume = 0.3
			@songs[name].play(true)
		end

		def pause_song(name)
			@songs[name].pause()
		end
	end
end