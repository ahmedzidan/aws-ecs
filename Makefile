ifndef env
	env=development
endif
env_config=environment/$(env).yaml
prefix=static-pages
build:
	docker-compose -p ${prefix} -f $(env_config) rm -vsf
	docker-compose -p ${prefix} -f $(env_config) down -v --remove-orphans
	docker-compose -p ${prefix} -f $(env_config) up --build -d
up:
	docker-compose -p ${prefix} -f $(env_config) up -d

down:
	docker-compose -p ${prefix} -f $(env_config) down
