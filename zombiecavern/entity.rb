module ZombieCavern
	class Entity

		attr_accessor :texture, :position, :origin, :rotation, :scale, :width, :height
		
		def initialize texture
			@position = Vec2.new
			@texture = texture
			@width = texture.width
			@height = texture.height
			@origin = Vec2.new(0.5, 0.5)
			@rotation = 0.0
			@scale = 1.0
		end

		def intersect? other
			if @position.x > other.position.x + other.width
				return false
			end
			if @position.x + @width < other.position.x
				return false
			end
			if @position.y > other.position.y + other.height
				return false
			end
			if @position.y + @height < other.position.y
				return false
			end
			return true
		end

		def update dt
		end

		def draw
			@texture.draw_rot(@position.x, @position.y, 0.0, @rotation.to_degrees, @origin.x, @origin.y, @scale, @scale)
		end
	end
end