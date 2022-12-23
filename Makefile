.PHONY: docker_env purge

docker_build:
	./dock-run.sh ./ec_build.sh $(TARGET)

docker_env:
	./dock-run.sh bash

native_build:
	./ec_build.sh $(TARGET) native

purge:
	cd openwrt && rm -rf * && rm -rf .*
	@echo Done
