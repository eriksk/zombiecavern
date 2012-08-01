require 'gosu'
require_relative 'zombiecavern/helpers'
require_relative 'zombiecavern/entity'
require_relative 'zombiecavern/player'
require_relative 'zombiecavern/zombie'
require_relative 'zombiecavern/vec2'
require_relative 'zombiecavern/bullet'
require_relative 'zombiecavern/bullet_manager'
require_relative 'zombiecavern/particle'
require_relative 'zombiecavern/particle_manager'
require_relative 'zombiecavern/timer'
require_relative 'zombiecavern/weapon'
require_relative 'zombiecavern/zombie_manager'
require_relative 'zombiecavern/message_box'
require_relative 'zombiecavern/blood_splat'
require_relative 'zombiecavern/collision_manager'
require_relative 'zombiecavern/sound_manager'
require_relative 'zombiecavern/hud'
require_relative 'zombiecavern/pickup'
require_relative 'zombiecavern/pickup_manager'

$WIDTH = 800
$HEIGHT = 600

module ZombieCavern
	class Game < Gosu::Window

		attr_accessor :zombie_manager, 
					  :sound_manager, 
					  :player, 
					  :particle_manager, 
					  :bullet_manager, 
					  :collision_manager,
					  :pickup_manager, 
					  :hud,
					  :total_time,
					  :kill_count,
					  :paused

		STATES = [:start_screen, :running]

		def initialize
			super $WIDTH, $HEIGHT, false
			self.caption = "Zombie Cavern"

			# misc
			@bg = load_image('bg')
			@filter = load_image('filter')
			@corsair = load_image('corsair')
			@corsair_rotation = 0.0

			# player
			@player = Player.new(load_image('player'), self)
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0
			
			# managers
			@bullet_manager = BulletManager.new(self)
			@particle_manager = ParticleManager.new(self)
			@zombie_manager = ZombieManager.new(self)
			@collision_manager = CollisionManager.new(self)
			@sound_manager = SoundManager.new(self)
			@pickup_manager = PickupManager.new(self)

			# sound
			@sound_manager.play_song(:song)

			@splat_tex = load_image('splat')
			@splats = []

			# gui
			@hud = Hud.new(self)

			# states & stats
			@paused = false
			@total_time = 0.0
			@kill_count = 0
			@time = Gosu::milliseconds
			@last_frame_time = 0.0
			@delta = @time
			@state = :start_screen

			# start game
			reset()
		end

		def add_splat(position)
			@splats.push BloodSplat.new(position, rand(20.0))
		end

		def load_image name
			Gosu::Image.new(self, "content/gfx/#{name}.png", false)
		end

		def load_image_tiles name, tile_width, tile_height
			Gosu::Image.load_tiles(self, "content/gfx/#{name}.png", tile_width, tile_height, true)
		end

		def load_sound name
			Gosu::Sample.new(self, "content/audio/#{name}.wav")
		end

		def load_song name, extension = "wav"
			Gosu::Song.new(self, "content/audio/#{name}.#{extension}")
		end

		def reset
			@zombie_manager.clear
			@bullet_manager.clear
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0
			@splats.clear
			@player.reset
			@zombie_manager.spawn_zombies()
			@total_time = 0.0
			@kill_count = 0
			@hud.message_box.show_message("Survive!")
			@state = :start_screen
		end

		def zombie_killed
			@kill_count += 1
		end

		def button_down(id)
			case id
			when Gosu::KbSpace
				if @state == :running
					@paused = !@paused
				end
			when Gosu::KbEscape
				exit
			end
		end

		def update_delta
			@last_frame_time = @time
			@time = Gosu::milliseconds
			@delta = @time - @last_frame_time
		end

		def update
			update_delta
			dt = @delta

			if !@paused
				case @state
					when :running
						@total_time += dt
						@corsair_rotation += 0.15 * dt
						
						@player.update dt	
						@zombie_manager.update(dt, @player)
						@bullet_manager.update dt
						@particle_manager.update dt
						@collision_manager.update dt
						@pickup_manager.update dt
					when :start_screen
						if button_down?Gosu::KbSpace
							@state = :running
						end
				end
			end

			@hud.update dt
		end

		def draw
			@bg.draw(0,0,0)

			case @state
				when :running
					@splats.each do |splat|
						@splat_tex.draw_rot(splat.position.x, splat.position.y, 0, splat.rotation.to_degrees)
					end

					@pickup_manager.draw
					@zombie_manager.draw
					@bullet_manager.draw
					@particle_manager.draw

					@player.draw
					@filter.draw(0, 0, 0)

					@corsair.draw_rot(mouse_x, mouse_y, 0.0, @corsair_rotation, 0.5, 0.5, Math::sin(@total_time * 0.01), Math::sin(@total_time * 0.005))
					@corsair.draw_rot(mouse_x, mouse_y, 0.0, -@corsair_rotation, 0.5, 0.5, 1, 1)

					@hud.draw()
				when :start_screen
					@filter.draw(0, 0, 0)
					@hud.draw_start_screen()
			end
		end
	end
end

# entry point
game = ZombieCavern::Game.new
game.show