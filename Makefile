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

prepare-image: $(BUILD)/yocto
	cp wifx-base.inc $(BUILD)/yocto/meta-wifx/recipes-wifx/images/wifx-base.inc
	rm -rf $(BUILD)/yocto/poky/build-wifx && cp -ar build-wifx $(BUILD)/yocto/poky

build-image: prepare-image
	cd $(BUILD)/yocto/poky/build-wifx && bitbake wifx-base

docker: prepare-image
	rsync -vua --progress $(BUILD)/yocto container/yocto
	cd container && docker build --rm -t cameroon-build .

docker-build: docker
	docker run --rm --name camtest -v `pwd`/build:/home/worker/build/temp cameroon-build

update-collector:
	rsync -vua --progress collector pi@192.168.0.138:
