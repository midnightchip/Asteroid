include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidStatusBar
AsteroidStatusBar_FILES = AsteroidStatusBar.xm#$(wildcard *.m *.xm *.mm *.x) #../source/LWPProvider.m
#$(TWEAK_NAME)_FRAMEWORKS = CoreLocation
#AsteroidStatusBar_LIBRARIES = rocketbootstrap
#AsteroidStatusBar_PRIVATE_FRAMEWORKS = AppSupport
#AsteroidStatusBar_LDFLAGS +=-Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
