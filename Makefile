BUILD := build
TEST_SOURCE := postgres://loraserver_as_data:asdfasdf@192.168.0.30/loraserver_as_data
TEST_DESTINATION := postgres://lora-combined:asdfasdf@127.0.0.1/lora-combined?sslmode=disable
PI := 192.168.0.159

all: binaries lorix-image pi-image

binaries: $(BUILD)/db-sync $(BUILD)/db-read

clean:
	rm -rf $(BUILD)

$(BUILD)/db-sync: db-sync/*.go
	go build -o $@ $^

$(BUILD)/db-read: db-read/*.go
	go build -o $@ $^

test-sync: binaries
	$(BUILD)/db-sync --source $(TEST_SOURCE) --destination $(TEST_DESTINATION)

test-read: binaries
	$(BUILD)/db-read --url $(TEST_DESTINATION)

collector-build:
	rsync -vua --progress collector $(BUILD)

collector-arm-tools: $(BUILD)/collector/db-sync $(BUILD)/collector/db-read

$(BUILD)/collector/db-sync: db-sync/*.go
	env GOOS=linux GOARCH=arm go build -o $@ $^

$(BUILD)/collector/db-read: db-read/*.go
	env GOOS=linux GOARCH=arm go build -o $@ $^

update-collector: collector-build collector-arm-tools
	rsync -vua --progress $(BUILD)/collector pi@$(PI):

lorix-docker:
	cd lorix-image && docker build --rm -t lorix-image-build .

lorix-image/meta/recipes-conservify/cameroon-ucla/files/id_rsa lorix-image/meta/recipes-conservify/cameroon-ucla/files/id_rsa.pub lorix-image/meta/recipes-conservify/cameroon-ucla/files/authorized_keys:
	echo missing ssh keys

lorix-keys: lorix-image/meta/recipes-conservify/cameroon-ucla/files/id_rsa lorix-image/meta/recipes-conservify/cameroon-ucla/files/id_rsa.pub lorix-image/meta/recipes-conservify/cameroon-ucla/files/authorized_keys

lorix-image: lorix-keys lorix-docker
	mkdir -p `pwd`/build/images
	rm -rf `pwd`/build/images/lorix-rootfs
	docker run --rm --name lorix-image-build \
		--mount type=bind,source=`pwd`/build/images,target=/home/worker/yocto/poky/build-wifx/tmp/deploy/images \
		--mount source=yocto-downloads,target=/home/worker/yocto/poky/build-wifx/downloads \
		--mount source=yocto-sstate-cache,target=/home/worker/yocto/poky/build-wifx/sstate-cache \
		lorix-image-build ./build.sh

pi-docker:
	cd pi-image && docker build --rm -t pi-image-build .

pi-image: pi-docker
	mkdir -p `pwd`/build/images
	rm -rf `pwd`/build/images/pi-rootfs
	rm -rf `pwd`/build/images/raspberrypi3
	docker run --rm --name pi-image-build \
		--mount type=bind,source=`pwd`/build/images,target=/home/worker/yocto/poky/build/tmp/deploy/images \
		--mount source=yocto-downloads,target=/home/worker/yocto/poky/build/downloads \
		--mount source=yocto-sstate-cache,target=/home/worker/yocto/poky/build/sstate-cache \
		pi-image-build ./build.sh

lorix-build-shell: lorix-docker
	docker run -it --rm --name lorix-image-shell lorix-image-build /bin/bash

pi-build-shell: pi-docker
	docker run -it --rm --name pi-image-shell pi-image-build /bin/bash

lorix-flash-ready:
	if [ ! -d $(BUILD)/sam-ba_3.1.4 ]; then                                    \
		cd $(BUILD) && tar xf ../lorix-flash/sam-ba_3.1.4-linux_x86_64.tar.gz; \
	fi

lorix-flash: lorix-flash-ready
	sudo $(BUILD)/sam-ba_3.1.4/sam-ba -x lorix-flash/nandflash-usb-lorixone-512.qml

.PHONY: lorix-flash
