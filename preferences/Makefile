TARGET = iphone:clang:12.4:12.4
ARCHS = arm64
ifeq ($(shell uname -s),Darwin)
	ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Velvet

Velvet_FILES = $(wildcard *.m)
Velvet_INSTALL_PATH = /Library/PreferenceBundles
Velvet_FRAMEWORKS = UIKit
Velvet_PRIVATE_FRAMEWORKS = Preferences
Velvet_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Velvet.plist$(ECHO_END)
