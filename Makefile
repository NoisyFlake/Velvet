TARGET = iphone:clang:12.4:12.4
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Velvet

Velvet_FILES = ColorSupport.m Tweak.x
Velvet_FRAMEWORKS = CoreGraphics

Velvet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
