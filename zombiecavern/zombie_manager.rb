module ZombieCavern
	class ZombieManager

		attr_accessor :zombies, :wave

		def initialize textures
			@textures = textures
			@zombies = []
			@wave = 0
		end

		def clear
			@zombie_count = 1
			@zombies.clear
			@wave = 0
		end

		def spawn_zombies			
			@zombie_count.to_i.times do |i|
				type = :normal
				type_val = rand()
				if type_val > 0.9
					type = :brute
				elsif type_val > 0.8
					type = :runner
				end
				z = Zombie.new(@textures[type], type)
				left = rand() > 0.5
				if left
					z.position.x = -100 * rand()
					z.position.y = rand() * $HEIGHT
				else
					z.position.x = $WIDTH + 100 * rand()
					z.position.y = rand() * $HEIGHT
				end
				@zombies.push z
			end
			@zombie_count *= 1.6
			@wave += 1
		end

		def spawn_children position		
			4.times do |i|
				z = Zombie.new(@textures[:normal], :normal)
				z.position.x = position.x + (-0.5 + rand()) * 64
				z.position.y = position.y + (-0.5 + rand()) * 64
				@zombies.push z
			end
		end

		def update dt, player

			if @zombies.size == 0
				spawn_zombies()
			end

			# zombies
			@zombies.each do |z|
				z.update dt, player
			end	

		end

		def draw
			@zombies.each do |z|
				z.draw
			end	
		end
	end
end