include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsteroidHelper
AsteroidHelper_FILES = Tweak.xm MBProgressHUD.m
AsteroidHelper_LIBRARIES = CSPUtilities
AsteroidHelper_CFLAGS += -fobjc-arc
AsteroidHelper_FRAMEWORKS += Foundation UIKit CoreGraphics QuartzCore



include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 SpringBoard"
