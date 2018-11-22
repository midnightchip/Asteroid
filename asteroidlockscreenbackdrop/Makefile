include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidLockscreenBackdrop
AsteroidLockscreenBackdrop_FILES = Tweak.xm ../source/LWPProvider.m
AsteroidLockscreenBackdrop_LDFLAGS += -lCSPreferencesProvider

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
