Resources:
- vpc
- public subnet for nat gateway
- nat gateway
- 2 public subnets for ALB
- ALB
- private subnet for ecs cluster
- ECS cluster 
- fargate


## VPC. 
- create a new vpc with cidr "10.0.0.0/16"
- create an internet gateway to be able to access the internet form this vpc
## public subnet for nat gateway
  
## nat gateway

## public subnet for alb.

## alb.

## private subnet.

## ECS cluster. 

## ECS service.

## ECS task.
- Fargate task require ``execution_role_arn`` which you can start with the AWS managed role ``ecsTaskExecutionRole`` if it's not there you can create it from aws console.
go to ``IAM`` service then choose Role then create new role and give it the managed AWS policy.
