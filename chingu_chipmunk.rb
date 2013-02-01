#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require :default

# TODO trait dependency?
module Chingu
  module Traits
    module Vector
      def vector(magnitude=1.0)
        ajusted_angle = angle - 90
        radians = ajusted_angle * Math::PI/180.0
        return Math::cos(radians)*magnitude, Math::sin(radians)*magnitude
      end

      def velocity_magnitude
        Math::sqrt(velocity_x**2 + velocity_y**2)
      end
    end
  end
end

class ShipLoader
  def self.random_ship
    @@ship_tiles ||= load_ships
    @@ship_tiles.sample
  end

  def self.load_ships
    @@ship_tiles = Gosu::Image.load_tiles($window, Gosu::Image["ship_tiles.png"], 28, 28, true)
  end
end


class BohShmup < Chingu::Window
  def setup
    self.input = {escape: :close}
    push_game_state Level
  end
end


class Ship < Chingu::GameObject
  def setup
    self.image = ShipLoader.random_ship
    self.x = rand $window.width
    self.y = rand $window.height
    self.angle = rand 360
  end

  def turn_left
      self.angle = (angle - 1) % 360
  end

  def turn_right
      self.angle = (angle + 1) % 360
  end
end

class RandomShip < Ship
end

class PlayerShip < Ship
  traits :velocity, :vector
  attr_accessor :target

  # TODO do blocks!
  def setup
    super
    # turny shooty input here
    self.angle = 0
    self.x = $window.width/2
    self.y = $window.height/2
    self.velocity_x = 1
    self.velocity_y = 1
  end

  def update
    # NOTE this is linear.. would it be better to taper off? or just let it
    turn_left

    self.velocity = vector()
  end
end

class TrackingShip < Ship
  traits :velocity, :vector
  #traits :particle # smoke puffer
  attr_accessor :target

  def setup
    super
    self.x = $window.width/2
    self.y = $window.height/2
  end

  def update
     target_angle = ((- Math::atan2(target.x - x, target.y - y) * (180/Math::PI)) + 180)# % 360
    between_angle = (   Math::atan2(x - target.x, y - target.y) * (180/Math::PI)) # % 360

    puts between_angle + angle
    #self.velocity = vector()

    # angle of ship to me
    # my rotation angle.
  end

end

class MouseShip < Ship
  traits :velocity

  def update
    self.x = $window.mouse_x
    self.y = $window.mouse_y
    if previous_x != x || previous_y != y
      self.angle = - Math::atan2(previous_x - x, previous_y - y) * (180/Math::PI)
    end

    # hold last x positions for angle smoothing
  end
end

class HomingMissile < Chingu::GameObject
  # angle to
  # turn left
  # turn right
end



# TODO make larger than screeeeeeeeeeeen
class Level < Chingu::GameState
  def setup
    #rand(50).times{ RandomShip.create }

       mouse_ship =    MouseShip.create
      player_ship =   PlayerShip.create
    tracking_ship = TrackingShip.create

      player_ship.target = mouse_ship
    tracking_ship.target = mouse_ship
  end
end


BohShmup.new.show
