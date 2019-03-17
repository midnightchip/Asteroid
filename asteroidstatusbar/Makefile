include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidStatusBar
AsteroidStatusBar_FILES = AsteroidStatusBar.xm ../source/UIImage+ScaledImage.m ../source/LWPProvider.m
AsteroidStatusBar_LIBRARIES = rocketbootstrap
AsteroidStatusBar_PRIVATE_FRAMEWORKS = AppSupport
AsteroidStatusBar_LDFLAGS += -lCSPreferencesProvider 

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
