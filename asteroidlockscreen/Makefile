include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidLockScreen
AsteroidLockScreen_FILES = $(wildcard *.xm *.m) ../source/LWPProvider.m
AsteroidLockScreen_FRAMEWORKS = CoreLocation 
AsteroidLockScreen_PRIVATE_FRAMEWORKS = Weather WeatherUI
AsteroidLockScreen_LDFLAGS += -lCSPreferencesProvider  

include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 SpringBoard"
