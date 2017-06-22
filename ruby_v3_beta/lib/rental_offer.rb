#!/usr/bin/env ruby
# encoding: utf-8

# Copyright (c) 2017 by Fred George.
# May be used freely except for training; license required for training.

# For debugging...
# require 'pry'
# require 'pry-nav'

require 'securerandom'
require 'rapids_rivers'

# Understands car rental offer needs
class RentalOffer
  attr_reader :service_name

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    @river.require_values(need: 'car_rental_offer')
    @river.forbid('offer')
    @river.interested_in('membership_level')
    @service_name = 'rental_offer_' + SecureRandom.uuid
  end

  def start
    puts " [*] #{@service_name} waiting for traffic on RabbitMQ event bus ... To exit press CTRL+C"
    @river.register(self)
  end

  def packet rapids_connection, packet, warnings
    puts " [*] #{warnings}"
    packet.offer = if packet.membership_level.nil?
                     member_offer
                   else
                     offer
                   end
    rapids_connection.publish packet
  end

  def on_error rapids_connection, errors
    # puts " [x] #{errors}"
  end

  private

  def member_offer
    { name:   'Mercedes SL for members only',
      price:  50_000,
      chance: 1 }
  end

  def offer
    { name:   'Mercedes SL',
      price:  10_000,
      chance: 0.5 }
  end
end

RentalOffer.new(ARGV.shift, ARGV.shift).start
