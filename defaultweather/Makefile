include $(THEOS)/makefiles/common.mk

TWEAK_NAME = defaultweather
defaultweather_FILES = $(wildcard *.xm *.m) ../source/LWPProvider.m
defaultweather_LDFLAGS += -lCSPreferencesProvider
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 com.apple.weather"
