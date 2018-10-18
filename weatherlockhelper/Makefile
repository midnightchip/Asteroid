include $(THEOS)/makefiles/common.mk

TWEAK_NAME = weatherLockHelper
weatherLockHelper_FILES = Tweak.xm MBProgressHUD.m
weatherLockHelper_LIBRARIES = CSPUtilities
weatherLockHelper_CFLAGS += -fobjc-arc
weatherLockHelper_FRAMEWORKS += Foundation UIKit CoreGraphics QuartzCore
#weatherLockHelper_EXTRA_FRAMEWORKS = AFNetworking

BUNDLE_NAME = lockWeatherAssets
lockWeatherAssets_INSTALL_PATH = /Library/PreferenceBundles/lockweather.bundle

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
