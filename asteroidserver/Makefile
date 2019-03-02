include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidServer
AsteroidServer_FILES = AsteroidServer.xm AWeatherModel.xm ../source/LWPProvider.m
AsteroidServer_LIBRARIES = CSPreferencesProvider  #rocketbootstrap
AsteroidServer_FRAMEWORKS = CoreLocation
AsteroidServer_PRIVATE_FRAMEWORKS = Weather WeatherUI #AppSupport


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
