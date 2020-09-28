## AWS ECS task definition module

- This module rquire from you to put the container_definitions in your resources and it should follow this path ``task-definitions/app.json``.
- This module is compatible only with fargate launch type.
- Fargate requires``execution_role_arn``, in this module we are using the default ``ecsTaskExecutionRole`` that managed by aws if it's not there please create it using the ``AmazonECSTaskExecutionRolePolicy``policy. 


The following are the module parameters.

- ``task_family`` : string and it's reuired.
- ``cpu`` : string and it's required.
- ``memory`` : string and it's reuired
- ``image_tag``: string and it's reuired
- ``app_name``: string and it's required.
- ``image_url``: string and it's required.
- ``ecs_host_policy`` : string and it's reuired.
- ``container_definitions``: string and it's reuired.

The following are the module outputs.

- ``id``  : the task id.
- ``arn`` : the task arn.




