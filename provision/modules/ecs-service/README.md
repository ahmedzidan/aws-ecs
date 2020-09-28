## ECS service
- This module will create an ECS service with it's own security group.
The following are the module parameters.

- ``vpc_id`` : string and it's required.
- ``service_name`` : string and it's reuired.
- ``ecs_cluster_id``: string and it's reuired
- ``task_arn``: string and it's required.
- ``target_group_id``: string and it's required.
- ``subnets_id``: List(string) and it's required.

The following are the module outputs.

- ``name``: the name of the service.


