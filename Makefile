TARGET = iphone:clang:latest

ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Velvet

Velvet_FILES = $(wildcard sources/*.x sources/*.m)
Velvet_FRAMEWORKS = CoreGraphics
Velvet_PRIVATE_FRAMEWORKS = MediaRemote
Velvet_LIBRARIES = bulletin

Velvet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
