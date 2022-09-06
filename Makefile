include config.env

ifneq ($(shell uname -m),x86_64)
DOCKER_PLATFORM ?= linux/amd64
endif

ifndef NSO_INSTALL_FILE
$(error NSO_INSTALL_FILE is not set)
endif

ifndef DEBUG_PACKAGE
$(error DEBUG_PACKAGE is not set)
endif

CONTAINER_NAME = nso_debug_nso_1
TEMP_CONTAINER_NAME = nso_debug_nso_temp_1
IMAGE_NAME = nso_debug_nso
TEMP_IMAGE_NAME = nso_debug_nso_temp

.PHONY: verify start clean reload-package shell package

verify:
	@echo 'Selected $(NSO_INSTALL_FILE) for the installation'

clean:
	-@docker rm -f $(CONTAINER_NAME)
	-@docker image rm $(IMAGE_NAME):latest

reload-package:
	docker cp packages/$(DEBUG_PACKAGE) $(CONTAINER_NAME):/var/opt/ncs/packages
	docker exec -it $(CONTAINER_NAME) bash -lc 'source /opt/ncs/current/ncsrc \
	&& make clean all -C /var/opt/ncs/packages/$(DEBUG_PACKAGE)/src \
	&& su - nsoadmin -c "source /opt/ncs/current/ncsrc \
	&& echo packages reload force | ncs_cli -C"'

shell:
	@docker exec -it $(CONTAINER_NAME) bash -lc 'su - nsoadmin -c "source /opt/ncs/current/ncsrc \
	&& ncs_cli -C"'

start:
	@sh scripts/check_package_dir.sh
	@DEBUG_PACKAGE=$(DEBUG_PACKAGE) NSO_INSTALL_FILE=$(NSO_INSTALL_FILE) \
	CONTAINER_NAME=$(CONTAINER_NAME) IMAGE_NAME=$(IMAGE_NAME) docker-compose up -d
	@CONTAINER_NAME=$(CONTAINER_NAME) sh scripts/start_ncs.sh
	@CONTAINER_NAME=$(CONTAINER_NAME) sh scripts/check_nso_status.sh
	@output=`docker exec -it $(CONTAINER_NAME) bash -lc 'source /opt/ncs/current/ncsrc \
	&& ncs_load -lm /tmp/nso_config.xml' 2>&1` && echo 'Configuration Loaded!' \
	|| echo "No configuration loaded..."
	@docker exec -it $(CONTAINER_NAME) bash -lc 'source /opt/ncs/current/ncsrc \
	&& su - nsoadmin -c "source /opt/ncs/current/ncsrc \
	&& echo show packages package oper-status | ncs_cli -C"'

package:
	@docker build --build-arg NSO_INSTALL_FILE=$(NSO_INSTALL_FILE) --build-arg NEW_PACKAGE_NAME=$(NAME) -t $(TEMP_IMAGE_NAME) -f Dockerfile.package .
	@docker run -itd --name $(TEMP_CONTAINER_NAME) $(TEMP_IMAGE_NAME)
	@NEW_PACKAGE_NAME=$(NAME) TEMP_CONTAINER_NAME=$(TEMP_CONTAINER_NAME) sh scripts/copy_package_from.sh
	@docker rm -f $(TEMP_CONTAINER_NAME) > /dev/null 2>&1
	@docker image rm $(TEMP_IMAGE_NAME):latest > /dev/null 2>&1
