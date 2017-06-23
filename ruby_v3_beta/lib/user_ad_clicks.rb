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
class UserAdClicks
  attr_reader :service_name

  def initialize(host_ip, port)
    @service_name = 'user_ad_clicks_' + SecureRandom.uuid
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    @river.require('shown_offer')
    @river.forbid('clicked')
  end

  def start
    puts " [*] #{@service_name} listening for user ad clicks..."
    @river.register(self)
  end

  def packet rapids_connection, packet, warnings
    if click?(packet)
      packet.clicked = true
      rapids_connection.publish packet
      puts " [<] Clicked an ad: \n\t     #{packet.to_json}"
    end
  end

  private

  def click?(packet)
    rand <= packet.shown_offer['chance']
  end

end

UserAdClicks.new(ARGV.shift, ARGV.shift).start
