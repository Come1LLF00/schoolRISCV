# schoolRISCV board Makefile
#
# Stanislav Zhelnio, 2020
#

# default target to run when make is called without args
help:
	$(info Warning: targets: open, synthesis, implementation, bitstream and program uses Vivado Design Suite NOT Quartus)
	$(info make help           - show this message(default))
	$(info make all            - clean, create the board project and run the synthesis)
	$(info make clean          - delete synth folder)
	$(info make create         - create the board project)
	$(info make open           - open the board project)
	$(info make synthesis      - synthesis the design                !NOT implemented yet)
	$(info make implementation - implement the design                !NOT implemented yet)
	$(info make bitstream      - write bitstream from implementation !NOT implemented yet)
	$(info make program        - program the FPGA board              !NOT implemented yet)
	@true

CABLE_NAME   ?= "Digilent-USB-Device"
PROJECT_NAME ?= $(notdir $(CURDIR))
PROJECT_DIR  ?= project

all: create synthesis

# make clean
#  delete <project_dirname>
clean:
	rm -rf $(PROJECT_DIR)
	rm -rf .Xil
	rm -f vivado*.jou
	rm -f vivado*.log

VIVADO     := vivado
VIVADO_SH  := vivado_sh
VIVADO_PGM := vivado_pgm

# when we run VIVADO bins from WSL it can be installed on host W10
# it this case we have to add .exe to the executed binary name
ifdef WSL_DISTRO_NAME
 ifeq (, $(shell which $(VIVADO)))
  VIVADO     := $(VIVADO).exe
  VIVADO_SH  := $(VIVADO_SH).exe
  VIVADO_PGM := $(VIVADO_PGM).exe
 endif
endif

# make create
#  delete and create <project_dirname>
create: clean $(PROJECT_DIR)

# make project
#  - if folder "project" does not exist
#  - create folder "project"
#  - copy all the project template files to new folder renaiming its extensions
$(PROJECT_DIR):
	mkdir  $(PROJECT_DIR)
	cp $(PROJECT_NAME).xdc_ $(PROJECT_DIR)/$(PROJECT_NAME).xdc
	$(VIVADO) -mode batch -source nexys4_ddr.tcl


# make open
#  cd project && VIVADO <projectname> &
#     cd project               - go to project folder 
#	  &&                       - if previous command was successfull
#     VIVADO <projectname>.xpr - open <projectname> in VIVADO 
#     &                        - run previous command in shell background
open: $(PROJECT_DIR)
	cd $(PROJECT_DIR) && $(VIVADO) $(PROJECT_NAME).xpr &

# make synthesis
synthesis: $(PROJECT_DIR)
	$(error target $@ is not implemented yet)

# make implementation
implementation: synthesis
	$(error target $@ is not implemented yet)

# make bitstream
bitstream: implementation
	$(error target $@ is not implemented yet)

# make program
program: bitstream
	$(error target $@ is not implemented yet)

