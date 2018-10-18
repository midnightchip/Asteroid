include $(THEOS)/makefiles/common.mk

TWEAK_NAME = weatherLockHelper
weatherLockHelper_FILES = Tweak.xm MBProgressHUD.m
weatherLockHelper_LIBRARIES = CSPUtilities
weatherLockHelper_CFLAGS += -fobjc-arc
weatherLockHelper_FRAMEWORKS += Foundation UIKit CoreGraphics QuartzCore



include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 SpringBoard"
