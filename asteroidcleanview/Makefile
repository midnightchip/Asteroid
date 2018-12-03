include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidCleanView
AsteroidCleanView_FILES = Tweak.xm
AsteroidCleanView_LIBRARIES = CSPreferencesProvider CSWeather

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
