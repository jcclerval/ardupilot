# top level makefile to build SITL for primary vehicle targets. 
# Useful for static analysis tools

all: sitl

sitl: TARGET=sitl
sitl: plane copter rover antennatracker

linux: TARGET=linux
linux: plane copter rover antennatracker

clean: TARGET=clean
clean: plane copter rover antennatracker

.PHONY: plane copter rover antennatracker

plane:
	make -C ArduPlane $(TARGET)
