# MicroService Workshop Ruby Implementation by Fred George
Copyright 2015-17 by Fred George. May be copied with this notice, but not used in classroom training.

Ruby is one of the easiest for MicroServices since:
- Little or no ceremony to creating a service (no compile)
- Since the service is small, performance not a consideration

An editor for development is all you really need. I use Sublime or VS Code usually.
I also run my Ruby under Docker. It simplifies keeping versions and gems in synch.

## Setup
This project was setup under Ruby 2.4.

Open this directory in your favorite Ruby editor. This particular Ruby
implementation uses a RabbitMQ-specific gem for rapids and rivers support.
Look in GitHub for the open-source implementation.

## Execution
Each MicroService runs independently.

For the MonitorAll service:
- Move to the __lib__ directory
- Run `ruby monitor_all.rb <ip_address> <port>`

For the RentalNeed service:
- Move to the __lib__ directory
- Run `ruby rental_need.rb <ip_address> <port>`

## Next Steps
You're running MicroServices. Now let's write some more to run with these two.
Generally, your services will combine aspects of these first two services.
__MonitorAll__ provides sample _receiving_ code, while __RentalNeed__ provides
sample _sending_ code.

__Packet__ is a convenience class for manipulating JSON information, particularly
effective for enhancing existing information.

## Workshop outline
Write the following microservices:
1. a Need provider (already exists)
2. TWO solution providers
3. A solution collector should pick the best solution for evey offer
