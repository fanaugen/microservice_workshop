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
class OfferShow
  attr_reader :service_name

  def initialize(host_ip, port)
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)
    @river.require('best_offer', 'uuid')
    @river.interested_in('user_id')
    @river.forbid('shown_offer')
    @service_name = 'offer_show_' + SecureRandom.uuid
  end

  def start
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    fields = { uuid: packet.uuid, shown_offer: packet.best_offer }
    fields.merge!(user_id: packet.user_id) unless packet.user_id.nil?
    shown_offer_packet = RapidsRivers::Packet.new fields
    rapids_connection.publish shown_offer_packet
    puts " [<] Published a shown_offer on the bus:\n\t     #{shown_offer_packet.to_json}"
  end
end

OfferShow.new(ARGV.shift, ARGV.shift).start
