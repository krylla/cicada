# project info and directories
PROJECT		:= 	$(notdir $(CURDIR))
INCDIR		:= 	include
SRCDIR		:= 	src
BUILDDIR	:= 	build
EXEDIR		:= 	bin

# source and header extensions
HDREXT		:= 	h
SRCEXT		:= 	cpp

# compiler and flags
CXX			:= 	g++
CPPFLAGS	:=
CXXFLAGS	:= 	-g -Wall -std=c++11 -I$(INCDIR)
LDFLAGS		:=

# recursive wildcard search, example: $(call rwc, ./, *.cpp)
rwc = $(foreach d, $(wildcard $1*), $(call rwc, $d/, $2) $(filter $(subst *, %, $2), $d))

# find files
INCLUDES	:= $(call rwc, $(INCDIR), *.$(HDREXT))
SOURCES		:= $(call rwc, $(SRCDIR), *.$(SRCEXT))
OBJECTS		:= $(patsubst $(SRCDIR)/%.$(SRCEXT), $(BUILDDIR)/%.o, $(SOURCES))

# determine os, define architecture and set executable extension
ifeq ($(OS),Windows_NT)
    CPPFLAGS += -D WIN32
	EXEEXT := exe
    ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
        CPPFLAGS += -D AMD64
    else
        ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
            CPPFLAGS += -D AMD64
        endif
        ifeq ($(PROCESSOR_ARCHITECTURE),x86)
            CPPFLAGS += -D IA32
        endif
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CPPFLAGS += -D LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CPPFLAGS += -D MACOS
		EXEEXT := app
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        CPPFLAGS += -D AMD64
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
        CPPFLAGS += -D IA32
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
        CPPFLAGS += -D ARM
    endif
endif

# main target
.PHONY: all
all: $(EXEDIR)/$(PROJECT).$(EXEEXT)

# clean bin and build files
.PHONY: clean
clean:
	@rm -rf $(EXEDIR)
	@rm -rf $(BUILDDIR)
	@echo "cleaned"

# (compile) and link project
$(EXEDIR)/$(PROJECT).$(EXEEXT): $(OBJECTS)
	@mkdir -p $(EXEDIR)
	@$(CXX) $(CXXFLAGS) $(LDFLAGS) $< -o $@
	@echo "project $(PROJECT) compiled and linked to $@"

# compile objects
$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(dir $@)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(INCFLAGS) -c $< -o $@
	@echo "compiled object $@"
