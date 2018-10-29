include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidHome
AsteroidHome_FILES = AsteroidHome.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
