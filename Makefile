#-------------------------------------------------------------------------------
# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

.PHONY: test test-sites

TMP        = ../tmp

OSITES     = $(TMP)/sites
ISITES     = ../sample-sites

OSHELLS    = $(TMP)/shells
ISHELLS    = ../sample-shells

OFFL_SITE  = node ../offl-site
OFFL_SHELL = node ../offl-shell

VERBOSE    = 

#-------------------------------------------------------------------------------
test: check-cwd test-init test-sites test-shells

#-------------------------------------------------------------------------------
test-init:
	@rm -rf $(TMP)
	@mkdir  $(TMP)
	@mkdir  $(OSITES)
	@mkdir  $(OSHELLS)

#-------------------------------------------------------------------------------
test-sites: 
	@mkdir                   $(OSITES)/simple-html
	$(OFFL_SITE) $(VERBOSE) $(ISITES)/simple-html $(OSITES)/simple-html

	@mkdir                   $(OSITES)/simple-md
	$(OFFL_SITE) $(VERBOSE) $(ISITES)/simple-md   $(OSITES)/simple-md

	@mkdir                   $(OSITES)/ms-html
	$(OFFL_SITE) $(VERBOSE) $(ISITES)/ms-html     $(OSITES)/ms-html

	@mkdir                   $(OSITES)/ms-md
	$(OFFL_SITE) $(VERBOSE) $(ISITES)/ms-md       $(OSITES)/ms-md

#-------------------------------------------------------------------------------
test-shells: 
	@mkdir                    $(OSHELLS)/simple-shell
	$(OFFL_SHELL) $(VERBOSE) $(ISHELLS)/simple-shell $(OSHELLS)/simple-shell

#-------------------------------------------------------------------------------
MakefileName := $(wildcard ../test/Makefile*)

#-------------------------------------------------------------------------------
check-cwd:
ifneq ($(MakefileName),../test/Makefile)
	$(error This command must be run in the directory with the makefile)
endif