export ARCHS = arm64 arm64e
export TARGET = iphone:clang:11.2:10.0

#DEBUG = 0
FINALPACKAGE = 0
GO_EASY_ON_ME = 0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Asteroid
Asteroid_FILES = $(wildcard source/*.m source/*.xm source/*.mm source/*.x source/SetupWindow/*.m source/SetupWindow/*.xm source/SetupWindow/*.x)
Asteroid_FRAMEWORKS = CoreLocation 
Asteroid_LIBRARIES = rocketbootstrap CSPreferencesProvider 
Asteroid_EXTRA_FRAMEWORKS = AsteroidSetup
Asteroid_PRIVATE_FRAMEWORKS = Weather WeatherUI AppSupport
Asteroid_CFLAGS += -fobjc-arc -I$(THEOS_PROJECT_DIR)/source

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
SUBPROJECTS += asteroidlockscreen
SUBPROJECTS += asteroidstatusbar
SUBPROJECTS += defaultweather
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
