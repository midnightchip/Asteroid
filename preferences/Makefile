ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:11.2:10.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = lockweather
$(BUNDLE_NAME)_FILES = LWPPreferenceController.m ../source/LWPProvider.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_CFLAGS += -fobjc-arc
$(BUNDLE_NAME)_LDFLAGS += -lCSPreferences -lCSColorPicker -lCSPreferencesProvider

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/lockweather.plist$(ECHO_END)
