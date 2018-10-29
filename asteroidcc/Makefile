include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidCC
AsteroidCC_FILES = AsteroidCC.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
