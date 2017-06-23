#!/usr/bin/env ruby

Dir.glob("lib/*.rb").each do |µS|
  puts "Starting #{µS}"
  fork { require_relative µS }
end
