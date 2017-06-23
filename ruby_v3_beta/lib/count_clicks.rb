#!/usr/bin/env ruby
# encoding: utf-8

# Copyright (c) 2017 by Fred George.
# May be used freely except for training; license required for training.

# For debugging...
require 'pry'
require 'pry-nav'
require 'pp'

require 'securerandom'
require 'rapids_rivers'

# Understands car rental offer needs
class ClickCount
  attr_reader :service_name, :offer_stats

  def initialize(host_ip, port)
    @service_name = 'click_count_' + SecureRandom.uuid
    rapids_connection = RapidsRivers::RabbitMqRapids.new(host_ip, port)
    @river = RapidsRivers::RabbitMqRiver.new(rapids_connection)

    @river.require('shown_offer')
    @river.interested_in('clicked', 'user_id')

    @offer_stats = Hash.new { |h, key| h[key] = Hash.new(0) }
    @packet_count = 0
  end

  def start
    puts " [*] #{@service_name} counting user ad clicks..."
    @river.register(self)
  end

  def packet(rapids_connection, packet, warnings)
    count_event(packet.shown_offer, clicked: packet.clicked)
  end

  private

  def count_event(offer, clicked: false)
    if clicked
      offer_stats[offer["name"]][:clicked] += 1
    else
      offer_stats[offer["name"]][:shown] += 1
    end

    @packet_count += 1
    if (@packet_count % 10).zero?
      pp offer_stats
    end
  end
end

ClickCount.new(ARGV.shift, ARGV.shift).start
