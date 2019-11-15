BUILD := build
TEST_SOURCE := postgres://loraserver_as_data:asdfasdf@192.168.0.30/loraserver_as_data
TEST_DESTINATION := postgres://lora-combined:asdfasdf@127.0.0.1/lora-combined?sslmode=disable

all: $(BUILD)/db-sync $(BUILD)/db-read image

$(BUILD)/db-sync: db-sync/*.go
	go build -o $@ $^

$(BUILD)/db-read: db-read/*.go
	go build -o $@ $^

test-sync: all
	$(BUILD)/db-sync --source $(TEST_SOURCE) --destination $(TEST_DESTINATION)

test-read: all
	$(BUILD)/db-read --url $(TEST_DESTINATION)

image: $(BUILD)/yocto

$(BUILD)/poky-wifx-glibc-x86_64-wifx-base-sdk-cortexa5hf-neon-toolchain-2.1.2.tar.bz2:
	curl https://www.lorixone.io/yocto/sdk/2.1.2/poky-wifx-glibc-x86_64-wifx-base-sdk-cortexa5hf-neon-toolchain-2.1.2.tar.bz2 -o $@

$(BUILD)/yocto:
	mkdir -p $(BUILD)/yocto
	cd $(BUILD)/yocto && git clone git://git.yoctoproject.org/poky -b krogoth
	cd $(BUILD)/yocto && git clone git://git.openembedded.org/meta-openembedded -b krogoth
	cd $(BUILD)/yocto && git clone git://github.com/Wifx/meta-wifx.git -b krogoth
	cd $(BUILD)/yocto && git clone git://github.com/Wifx/meta-golang.git golang/meta-golang -b master
	cd $(BUILD)/yocto && git clone git://git.yoctoproject.org/meta-maker -b master
	cd $(BUILD)/yocto/meta-maker && git checkout -b working c039fafa7a0276769d0928d16bdacd2012f2aff6
	cd $(BUILD)/yocto && git clone git://github.com/brocaar/chirpstack-gateway-os.git

prepare-image: $(BUILD)/yocto
	cp wifx-base.inc $(BUILD)/yocto/meta-wifx/recipes-wifx/images/wifx-base.inc
	rm -rf $(BUILD)/yocto/poky/build-wifx && cp -ar build-wifx $(BUILD)/yocto/poky

build-image: prepare-image
	cd $(BUILD)/yocto/poky/build-wifx && bitbake wifx-base

docker: prepare-image
	rsync -vua --progress $(BUILD)/yocto/ container/yocto/
	rsync -vua --progress meta/ container/yocto/conservify/
	cd container && docker build --rm -t cameroon-build .

docker-build: docker
	mkdir -p `pwd`/build/images
	rm -rf `pwd`/build/images/rootfs
	docker run --rm --name camtest \
		--mount type=bind,source=`pwd`/build/images,target=/home/worker/yocto/poky/build-wifx/tmp/deploy/images \
		--mount source=yocto-sstate-cache-camtset,target=/home/worker/yocto/poky/build-wifx/sstate-cache \
		cameroon-build

collector-build:
	rsync -vua --progress collector $(BUILD)

collector-arm-tools: $(BUILD)/collector/db-sync $(BUILD)/collector/db-read

$(BUILD)/collector/db-sync: db-sync/*.go
	env GOOS=linux GOARCH=arm go build -o $@ $^

$(BUILD)/collector/db-read: db-read/*.go
	env GOOS=linux GOARCH=arm go build -o $@ $^

update-collector: collector-build collector-arm-tools
	rsync -vua --progress combined-db/schema $(BUILD)/collector
	rsync -vua --progress $(BUILD)/collector pi@192.168.0.138:
