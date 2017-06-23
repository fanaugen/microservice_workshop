#!/usr/bin/env ruby
# encoding: utf-8

# Copyright (c) 2017 by Fred George.
# May be used freely except for training; license required for training.

# For debugging...
# require 'pry'
# require 'pry-nav'

require 'securerandom'
require 'rapids_rivers'

# Understands the complete stream of messages on an event bus
class RentalNeed
  attr_reader :service_name

  NEED = 'car_rental_offer'

  def initialize(host_ip, port)
    @rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @service_name = 'rental_need_ruby_' + SecureRandom.uuid
  end

  def start
    loop do
      @rapids_connection.publish need_packet
      puts " [<] published a need: #{need_packet.to_json}"
      sleep 5
    end
  end

  private

  def need_packet
    fields = { need: NEED, uuid: SecureRandom.uuid }
    fields.merge!(user_id: user_id) if rand > 0.5
    RapidsRivers::Packet.new fields
  end

  def user_id
    rand(100)
  end

end

RentalNeed.new(ARGV.shift, ARGV.shift).start
