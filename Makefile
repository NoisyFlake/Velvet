TARGET = iphone:clang:13.0:13.0
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Velvet

Velvet_FILES = ColorSupport.m Tweak.x
Velvet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
