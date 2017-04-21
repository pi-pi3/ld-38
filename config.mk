
# These must variables be in sync with vars in butler.sh
VERSION = 0.1
GAME = ld-38
AUTHOR = pi_pi3
ITCH = $(AUTHOR)

LINUX_PATH = release/linux
WINDOWS_PATH = release/windows
MAC_PATH = release/mac

LINUX_NAME = $(LINUX_PATH)/$(GAME).love
WINDOWS_NAME = $(WINDOWS_PATH)/$(GAME).exe
MAC_NAME = $(MAC_PATH)/$(GAME).app
