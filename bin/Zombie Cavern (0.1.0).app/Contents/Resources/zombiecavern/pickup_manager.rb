module ZombieCavern
	class PickupManager

		attr_accessor :pickups

		TYPES = [:gun, :smg, :cannon, :granade]

		def initialize game
			@pickups = []
			@timer = Timer.new(5000, lambda{
				spawn_pickup()
			})
			@pickup_textures = game.load_image_tiles('guns', 16, 16)
			spawn_pickup()
		end

		def spawn_pickup
			pickup = Pickup.new(@pickup_textures, next_pickup_type)
			pickup.position.x = (200 + ($WIDTH - 400)) * rand()
			pickup.position.y = (200 + ($WIDTH - 400)) * rand()
			@pickups.push(pickup)
		end

		def next_pickup_type
			(rand() * TYPES.size).to_i
		end

		def update dt
			@pickups.each do |p|
				p.update dt
			end
			@timer.update dt
		end

		def draw
			@pickups.each do |p|
				p.draw()
			end		
		end
	end
end