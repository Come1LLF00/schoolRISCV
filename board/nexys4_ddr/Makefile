# schoolRISCV board Makefile
#
# Stanislav Zhelnio, 2020
#

# default target to run when make is called without args
help:
	$(info Warning: targets: open, build, load use Vivado Design Suite NOT Quartus)
	$(info make help   - show this message(default))
	$(info make all    - clean, create the board project and run the synthesis)
	$(info make clean  - delete synth folder)
	$(info make create - create the board project)
	$(info make open   - open the board project)
	$(info make build  - build the board project !NOT implemented yet)
	$(info make load   - program the FPGA board  !NOT implemented yet)
	@true

CABLE_NAME   ?= "Digilent-USB-Device"
PROJECT_NAME ?= $(notdir $(CURDIR))
PROJECT_DIR  ?= project

all: create build

# make clean
#  delete <project_dirname>
clean:
	rm -rf $(PROJECT_DIR)
	rm -rf .Xil

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
#     cd project            - go to project folder 
#	  &&                    - if previous command was successfull
#     VIVADO <projectname> - open <projectname> in VIVADO 
#     &                     - run previous command in shell background
open: $(PROJECT_DIR)
	cd $(PROJECT_DIR) && $(VIVADO) $(PROJECT_NAME).xpr &

# make build
#  cd project && VIVADO_sh --flow compile <projectname>
#     cd project                              - go to project folder 
#     &&                                      - if previous command was successfull
#     VIVADO_sh --flow compile <projectname> - run VIVADO shell & perform basic compilation 
#                                               of <projectname> project
build: $(PROJECT_DIR)
	$(error target $@ is not implemented yet)
	$(VIVADO_SH) --flow compile $(PROJECT_NAME)

# make load
#  cd project && VIVADO_pgm -c "USB-Blaster" -m JTAG -o "p;<projectname>.sof"
#     cd project               - go to project folder 
#	  &&                       - if previous command was successfull
#     VIVADO_pgm              - launch VIVADO programmer
#     -c "USB-Blaster"         - connect to "USB-Blaster" cable
#     -m JTAG                  - in JTAG programming mode
#     -o "p;<projectname>.sof" - program (configure) FPGA with <projectname>.sof file
load:
	$(error target $@ is not implemented yet)
	$(VIVADO_PGM) -c $(CABLE_NAME) -m JTAG -o "p;$(PROJECT_NAME).sof"
