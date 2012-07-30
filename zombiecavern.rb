require 'gosu'
require_relative 'zombiecavern/helpers'
require_relative 'zombiecavern/entity'
require_relative 'zombiecavern/player'
require_relative 'zombiecavern/zombie'
require_relative 'zombiecavern/vec2'
require_relative 'zombiecavern/bullet'
require_relative 'zombiecavern/bullet_manager'
require_relative 'zombiecavern/timer'

$WIDTH = 800
$HEIGHT = 600

module ZombieCavern
	class Game < Gosu::Window


		def initialize
			super $WIDTH, $HEIGHT, false
			self.caption = "Zombie Cavern"

			@corsair = load_image('corsair')
			@corsair_rotation = 0.0

			@player = Player.new(load_image('player'))
			@player.position.x = $WIDTH / 2.0
			@player.position.y = $HEIGHT / 2.0

			@bullet_manager = BulletManager.new(load_image('bullet'))

			@zombies = []
			@zombie_tex = load_image('zombie')

			@zombie_spawn_timer = Timer.new(1000, lambda{
				spawn_zombies()
			})
			@zombie_count = 1
		end

		def spawn_zombies			
			@zombie_count.to_i.times do |i|
				z = Zombie.new(@zombie_tex)
				left = rand() > 0.5
				if left
					z.position.x = -100 
					z.position.y = rand() * $HEIGHT
				else
					z.position.x = $WIDTH + 100 
					z.position.y = rand() * $HEIGHT
				end
				@zombies.push z
			end
			@zombie_count *= 1.1
		end

		def load_image name
			Gosu::Image.new(self, "content/gfx/#{name}.png", false)
		end

		def update
			if button_down? Gosu::KbEscape
				exit
			end

			dt = 16.0
			@corsair_rotation += 0.15 * dt
			@zombie_spawn_timer.update dt
			
			# bullets
			if button_down? Gosu::MsLeft
				angle = @player.rotation + (0.5 + rand()) * 0.3
				@bullet_manager.fire(
					@player.position.clone, 
					Vec2.new(Math::cos(angle), 
						     Math::sin(angle)) * 0.5)
			end

			# player
			@player.update dt	
			@player.rotation = Math::atan2(mouse_y - @player.position.y, 
										   mouse_x - @player.position.x)	

			# zombies
			@zombies.each do |z|
				z.update dt, @player
			end	

			@bullet_manager.update dt

			# collision
			@bullet_manager.bullets.each do |b|
				@zombies.each do |z|
					if z.intersect? b
						@bullet_manager.bullets.delete b
						@zombies.delete z
						# TODO: effects
					end
				end
			end
		end

		def draw
			@zombies.each do |z|
				z.draw
			end	

			@bullet_manager.draw

			@player.draw

			@corsair.draw_rot(mouse_x, mouse_y, 0.0, @corsair_rotation)
			@corsair.draw_rot(mouse_x, mouse_y, 0.0, -@corsair_rotation, 0.5, 0.5, 0.6, 0.6)
		end
	end
end

# entry point
$game = ZombieCavern::Game.new
$game.show