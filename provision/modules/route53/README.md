## Route 53
- This module will create an A record and alias it to the load balancer.
The following are the module parameters.

- ``domain_name`` : string and it's required.
- ``zone_id`` : string and it's reuired.
- ``alb_dns_name``: string and it's reuired
- ``alb_zone_id``: string and it's required.

The following are the module outputs.

- ``name``: the name of the domain.
