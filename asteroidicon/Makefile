ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:11.2:10.0

DEBUG = 0
FINALPACKAGE = 0
GO_EASY_ON_ME = 0

PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-$(VERSION.INC_BUILD_NUMBER)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Asteroid
$(TWEAK_NAME)_FILES = $(wildcard source/*.m source/*.xm source/*.x)
$(TWEAK_NAME)_FRAMEWORKS = 
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = Weather WeatherUI
$(TWEAK_NAME)_LIBRARIES = CSPreferencesProvider CSWeather
$(TWEAK_NAME)_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source
#$(TWEAK_NAME)_LDFLAGS += -lCSPreferencesProvider -lCSWeather

include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"