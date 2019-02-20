include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidServer
AsteroidServer_FILES = AsteroidServer.xm AWeatherModel.xm ../source/LWPProvider.m
$(TWEAK_NAME)_LIBRARIES = rocketbootstrap
$(TWEAK_NAME)_FRAMEWORKS = CoreLocation
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = Weather WeatherUI AppSupport
$(TWEAK_NAME)_LDFLAGS += -lCSPreferencesProvider 

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
