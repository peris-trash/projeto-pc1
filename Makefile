# [Directories] ------------------------------------------------------------------
TARGETDIR = bin
SOURCEDIR = src
OBJECTDIR = bin/obj
INCLUDEDIR = include

# [App] -------------------------------------------------------------------------
APP_NAME = EX1

# [General] ----------------------------------------------------------------------
OPTIMIZATION = -O2

BUILD_TYPE ?= debug

DEBUG_OUTPUT ?= true

# Parallel compile (use "$ nproc" to find out how many threads you have)
MAX_PARALLEL = 6

# [Compiler/Linker] --------------------------------------------------------------
CC = gcc
CXX = g++

# [Flags] ------------------------------------------------------------------------
CFLAGS =
CXXFLAGS =

LDLIBS =

# /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/
# file search
STRUCT := $(shell find $(SOURCEDIR) -type d)

SOURCEDIRSTRUCT := $(filter-out %/include, $(STRUCT))
INCLUDEDIRSTRUCT := $(filter %/include, $(STRUCT)) $(DEVICEDIR)/ $(COREDIR)/
OBJECTDIRSTRUCT := $(subst $(SOURCEDIR), $(OBJECTDIR), $(SOURCEDIRSTRUCT))

# Compillers & Linker flags
CFLAGS += $(addprefix -I,$(INCLUDEDIRSTRUCT)) -Wall -Wextra -std=gnu11
CXXFLAGS += $(addprefix -I,$(INCLUDEDIRSTRUCT)) -Wall -Wextra -std=gnu++11

LDLIBS +=

ifeq ($(BUILD_TYPE), debug)
CFLAGS += -g
CXXFLAGS += -g
endif

ifeq ($(DEBUG_OUTPUT), true)
CFLAGS += -D__DEBUG_OUTPUT__
CXXFLAGS += -D__DEBUG_OUTPUT__
endif

# Target
TARGET = $(TARGETDIR)/$(APP_NAME)

# Sources & objects
SRCFILES := $(addsuffix /*, $(SOURCEDIRSTRUCT))
SRCFILES := $(wildcard $(SRCFILES))

CSOURCES := $(filter %.c, $(SRCFILES))
COBJECTS := $(subst $(SOURCEDIR), $(OBJECTDIR), $(CSOURCES:%.c=%.o))

CXXSOURCES := $(filter %.cpp, $(SRCFILES))
CXXOBJECTS := $(subst $(SOURCEDIR), $(OBJECTDIR), $(CXXSOURCES:%.cpp=%.o))

SOURCES = $(ASSOURCES) $(CSOURCES) $(CXXSOURCES)
OBJECTS = $(ASOBJECTS) $(COBJECTS) $(CXXOBJECTS)

DEPENDENCIES = $(OBJECTS:.o=.d)

all: clean-bin make-dir compile

compile:
	@$(MAKE) --no-print-directory -j${MAX_PARALLEL} $(TARGET)

$(TARGET): $(OBJECTS)
	@echo Compiling App \'$@\'...
	@$(CXX) -o $@ $(OBJECTS) $(CXXFLAGS) $(LDLIBS)

$(OBJECTDIR)/%.o: $(SOURCEDIR)/%.c
	@echo Compilling C file \'$<\' \> \'$@\'...
	@$(CC) $(CFLAGS) -c -o $@ $<

$(OBJECTDIR)/%.o: $(SOURCEDIR)/%.cpp
	@echo Compilling C++ file \'$<\' \> \'$@\'...
	@$(CXX) $(CXXFLAGS) -c -o $@ $<

make-dir:
	@mkdir -p $(OBJECTDIRSTRUCT)

clean-bin:
	@rm -f $(TARGETDIR)/*.lss
	@rm -f $(TARGETDIR)/*.hex
	@rm -f $(TARGETDIR)/*.bin
	@rm -f $(TARGETDIR)/*.map
	@rm -f $(TARGETDIR)/*.elf

clean: clean-bin
	@rm -rf $(OBJECTDIR)/*

-include $(OBJECTS:.o=.d)

.PHONY: clean clean-bin make-dir debug compile all