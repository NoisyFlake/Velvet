ifneq ("$(wildcard $(THEOS)/sdks/iPhoneOS12.4.sdk)", "")
	TARGET = iphone:clang:12.4:12.4
else
	TARGET = iphone:clang:latest
endif

ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Velvet

Velvet_FILES = $(wildcard sources/*.x sources/*.m)
Velvet_FRAMEWORKS = CoreGraphics
Velvet_LIBRARIES = bulletin

Velvet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
