BUILD := build
TEST_SOURCE := postgres://loraserver_as_data:asdfasdf@192.168.0.30/loraserver_as_data
TEST_DESTINATION := postgres://lora-combined:asdfasdf@127.0.0.1/lora-combined?sslmode=disable

all: $(BUILD)/sync image

$(BUILD)/sync: *.go
	go build -o $@ $^

test: all
	$(BUILD)/sync --source $(TEST_SOURCE) --destination $(TEST_DESTINATION)

image: $(BUILD)/poky-wifx-glibc-x86_64-wifx-base-sdk-cortexa5hf-neon-toolchain-2.1.2.tar.bz2

$(BUILD)/poky-wifx-glibc-x86_64-wifx-base-sdk-cortexa5hf-neon-toolchain-2.1.2.tar.bz2:
	curl https://www.lorixone.io/yocto/sdk/2.1.2/poky-wifx-glibc-x86_64-wifx-base-sdk-cortexa5hf-neon-toolchain-2.1.2.tar.bz2 -o $@
