#===============================================================================
# Description:
#   ~ Cross-compiler Makefile
#   ~ Compiles C++ sources into executable for ARM architecture
#===============================================================================




TARGET          := main


CROSS_COMPILE   := arm-linux-gnueabihf-
CFLAGS          := -g -Wall -I ${SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib/include
LDFLAGS         := -g -Wall
CC              := $(CROSS_COMPILE)g++
ARCH            := arm

.PHONY: clean build


build: $(TARGET)

$(TARGET): main.o
	$(CC) $(LDFLAGS) $^ -o $@

main.o : main.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) *.a *.o *~