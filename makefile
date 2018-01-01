# Specify the device and the SDK that you want to run the tests on
# Options for SDK :
# 1. iphoneos : The device
# 2. iphonesimulator<version> : The simulator with the specified version. For example : iphonesimulator8.3
SDK ?= iOS Simulator
OS ?= 11.1

# Options for Device
# 1. If you are running on a connected device, the name of the device. For example, HS iPhone 6
# 2. Name of the simulator on which to run. For example, iPhone 6
DEVICE ?= iPhone 8

setup:
	$(MAKE) setup-pods

setup-pods:
	pod install; cd Example; pod install

build:
	xcodebuild -workspace LiveGQL.xcworkspace -scheme LiveGQL-iOS build
	xcodebuild -workspace LiveGQL.xcworkspace -scheme LiveGQL-macOS build
	xcodebuild -workspace Example/LiveGQLExample.xcworkspace -scheme LiveGQLExample build

clean:
	xcodebuild -workspace LiveGQL.xcworkspace -scheme LiveGQL-iOS clean
	xcodebuild -workspace LiveGQL.xcworkspace -scheme LiveGQL-macOS clean
	xcodebuild -workspace Example/LiveGQLExample.xcworkspace -scheme LiveGQLExample clean

format:
	swiftformat .;
