include ../common/Makedefs

CONFIG_DIR:=$(shell pwd)
DOCKER_COMPOSE_YML=./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML=./docker-compose-bootstrap.yml
DOCKER_PROJECT=cordpod
BOOTSTRAP_PROJECT=cordpodbs
XOS_BOOTSTRAP_PORT=81
XOS_UI_PORT=80
ADMIN_USERNAME=TriplePoint@adtran.com
ADMIN_PASSWORD=adtran
RUN_TOSCA_BOOTSTRAP=python ../common/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA=python ../common/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

.PHONY: xos
xos: prereqs dirs download_xos download_services bootstrap onboarding podconfig

prereqs:
	sudo make -f ../common/Makefile.prereqs

dirs:
	# if this directory doesn't exist, then docker-compose will create it with root permission
	mkdir -p key_import
	mkdir -p onboarding-docker-compose

bootstrap:
	@echo "[BOOTSTRAP]"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ./adtran_deployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos.yaml

download_xos:
	make -f ../common/Makefile.services xos_core

download_services:
	make -f ../common/Makefile.services

update_services:
	make -f ../common/Makefile.services update

update_xos:
	make -f ../common/Makefile.services update_xos

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) ../common/disable-onboarding.yaml
	sudo cp id_rsa key_import/vsg_rsa
	sudo cp id_rsa.pub key_import/vsg_rsa.pub
	sudo cp id_rsa key_import/volt_rsa
	sudo cp id_rsa.pub key_import/volt_rsa.pub
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa.pub key_import/onos_rsa.pub
	sudo cp id_rsa key_import/vaos_rsa
	sudo cp id_rsa.pub key_import/vaos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vaosservice/xos/vaosservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/olt/xos/volt-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	#$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/fabric-onboard.yaml
	#$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtr/xos/vtr-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) ../common/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vaosservice
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/volt
	#bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	#bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	#bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtr
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	$(RUN_TOSCA) setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

vtn: vtn-external.yaml
	$(RUN_TOSCA) vtn-external.yaml

fabric: fabric.yaml
	$(RUN_TOSCA) fabric.yaml

.PHONY: cord
#cord: vsg_custom_images
cord:
	$(RUN_TOSCA) mgmt-net.yaml
	#$(RUN_TOSCA) vaosservice.yaml
	#$(RUN_TOSCA) cord-services.yaml
	#$(RUN_TOSCA) cord-vsg-services.yaml
	#$(RUN_TOSCA) cord-volt-devices.yaml

cord-subscriber:
	$(RUN_TOSCA) cord-test-subscriber.yaml

clean-nodes:
	rm -f nodes.yaml

update-nodes: nodes.yaml
	$(RUN_TOSCA) nodes.yaml

new-nodes: clean-nodes update-nodes vtn

rebuild:
	bash ../common/rebuild.sh $(XOS_BOOTSTRAP_PORT)
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

exampleservice: onboard-exampleservice
	$(RUN_TOSCA) pod-exampleservice.yaml

onboard-exampleservice:
	sudo cp id_rsa key_import/exampleservice_rsa
	sudo cp id_rsa.pub key_import/exampleservice_rsa.pub
	$(RUN_TOSCA_BOOSTRAP) $(SERVICE_DIR)/exampleservice/exampleservice-onboard.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/exampleservice
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

cord-monitoringservice: ceilometer_custom_images onboard-monitoringservice
	$(RUN_TOSCA) monitoringservice.yaml
	$(RUN_TOSCA) monitoringtenant.yaml

onboard-monitoringservice: download-monitoringservice
	sudo cp id_rsa key_import/monitoringservice_rsa
	sudo cp id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) monitoring_synchronizer.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

download-monitoringservice:
	make -f ../common/Makefile.services monitoring_services

nodes.yaml:
	export SETUPDIR=.; bash ./make-nodes-yaml.sh

images.yaml:
	export SETUPDIR=.; bash ./make-images-yaml.sh

vtn-external.yaml:
	export SETUPDIR=.; bash ./make-vtn-external-yaml.sh

fabric.yaml:
	export SETUPDIR=.; bash ./make-fabric-yaml.sh

virtualbng_json:
	export SETUPDIR=.; bash ./make-virtualbng-json.sh

vtn_network_cfg_json:
	export SETUPDIR=.; bash ./make-vtn-networkconfig-json.sh

stop:
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) stop
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) stop

rm: stop
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) rm -f
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) rm -f

showlogs:
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) logs

showlogs_bootstrap:
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) logs

cleanup: stop rm
	./cleanup.sh
	bash -c "source ./admin-openrc.sh; nova list --all-tenants; neutron net-list"

ceilometer_custom_images: images/ceilometer-service-trusty-server-multi-nic.img images/ceilometer-trusty-server-multi-nic.img
	#TODO: Add logic for service VM custom image (ceilometer-service-trusty-server-multi-nic)
	bash -c "source ./admin-openrc.sh; glance image-show ceilometer-trusty-server-multi-nic || glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file ./images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare"

vsg_custom_images: images/vsg-1.0.img
	bash -c "source ./admin-openrc.sh; glance image-show vsg-1.0 || glance image-create --name vsg-1.0 --disk-format qcow2 --file ./images/vsg-1.0.img --container-format bare"

images/ceilometer-trusty-server-multi-nic.img: images
	bash -c "source ../setup/admin-openrc.sh; glance image-show ceilometer-trusty-server-multi-nic || wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P ./images"

images/ceilometer-service-trusty-server-multi-nic.img: images
	#TODO: Add logic for service VM custom image (ceilometer-service-trusty-server-multi-nic) once image is uploaded into vicci portal
	#bash -c "source ../setup/admin-openrc.sh; glance image-show ceilometer-service-trusty-server-multi-nic || wget http://www.vicci.org/cord/ceilometer-service-trusty-server-multi-nic.compressed.qcow2 -P ./images"

images/vsg-1.0.img: images
	[ -s images/vsg-1.0.img ] || wget http://www.vicci.org/cord/vsg-1.0.img -P ./images

images:
	mkdir -p ./images

.PHONY: local_containers
local_containers: prereqs download_xos
	make -f ../common/Makefile.containers update_certs xos_base xos_devel synchronizer onboarding_synchronizer

