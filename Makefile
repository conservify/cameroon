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

docker:
	cd lorix-image && docker build --rm -t lorix-image-build .

docker-build: docker
	mkdir -p `pwd`/build/images
	rm -rf `pwd`/build/images/rootfs
	docker run --rm --name lorix-image-build \
		--mount type=bind,source=`pwd`/build/images,target=/home/worker/yocto/poky/build-wifx/tmp/deploy/images \
		--mount source=yocto-downloads,target=/home/worker/yocto/poky/build-wifx/downloads \
		--mount source=yocto-sstate-cache,target=/home/worker/yocto/poky/build-wifx/sstate-cache \
		lorix-image-build

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
