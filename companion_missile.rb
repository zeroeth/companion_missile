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
  def self.ship
    self.ship_tiles.first
  end

  def self.random_ship
    self.ship_tiles.sample
  end

  def self.ship_tiles
    @@ship_tiles ||= load_ships
  end

  def self.load_ships
    @@ship_tiles = Gosu::Image.load_tiles($window, Gosu::Image["ship_tiles.png"], 28, 28, true)
  end
end


# Started coding at BohConf at Railsconf
class BohShmup < Chingu::Window
  def setup
    super
    self.input = {escape: :exit}
    push_game_state Level
  end
end


class Ship < Chingu::GameObject
  traits :velocity, :vector
  traits :bounding_circle, :collision_detection

  attr_accessor :turn_thruster, :main_thruster

  # TODO do blocks!
  def setup
    super
    self.image = ShipLoader.ship

    self.x = $window.width/2
    self.y = $window.height/2
    self.angle = 0

    self.turn_thruster = 1
    self.main_thruster = 1
  end

  def turn_left
      self.angle = (angle - turn_thruster) % 360
  end

  def turn_right
      self.angle = (angle + turn_thruster) % 360
  end
end


class RandomShip < Ship
  def setup
    super
    self.image = ShipLoader.random_ship

    self.x = rand $window.width
    self.y = rand $window.height
    self.angle = rand 360

    self.turn_thruster = rand * 5.0
    self.main_thruster = rand * 5.0
  end
end


class DizzyShip < Ship
  attr_accessor :target

  def setup
    super

    self.input = {space: :missile_spread}
  end

  def update
    super
    turn_left

    self.velocity = vector main_thruster
  end

  def missile_spread
    5.times do |n|
      left  = TrackingShip.create
      right = TrackingShip.create

       left.x,  left.y = self.x, self.y
      right.x, right.y = self.x, self.y

       left.target = self.target
      right.target = self.target

      spread = n * 4
      speed = 10
      turn = 4

       left.angle = self.angle - spread
      right.angle = self.angle + spread

       left.turn_thruster = turn
      right.turn_thruster = turn

       left.main_thruster = speed
      right.main_thruster = speed
    end
  end
end


class TrackingShip < RandomShip
  traits :velocity, :vector
  #traits :particle # smoke puffer
  attr_accessor :target

  def update
    target_angle   = (- Math::atan2(x - target.x, y - target.y) * (180/Math::PI)) % 360
    angle_to_front = (target_angle - self.angle) % 360

    self.turn_thruster *= 1.0
    # TODO slower as reaches target angle

    if angle_to_front < 180
      self.turn_right
    else
      self.turn_left
    end

    self.velocity = vector main_thruster
    # accelerate with age
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


class MissileSpread
  # get angle to target
  # spread + and - x steps
  # give each a sharper turning radius
end


# Time is always a good variable to have in all accessors.
class TimeDilation
  # delta + rate
end


# TODO make larger than screeeeeeeeeeeen
class Level < Chingu::GameState
  def setup
    super

    mouse_ship = MouseShip.create
    dizzy_ship = DizzyShip.create
    dizzy_ship.target = mouse_ship #temporary

    (rand(3)+1).times do
      ship = TrackingShip.create
      ship.target = mouse_ship
    end
  end

  def update
    super

    MouseShip.each_collision(TrackingShip) do |mouse_ship, tracking_ship|
      tracking_ship.destroy
    end
  end
end


BohShmup.new.show
