.PHONY: all clean

DPIS=48 96
ALL_ICONS=$(foreach dpi, $(DPIS), $(shell ls *.svg | sed "s/\.svg/-$(dpi)dpi.png/g"))
ALL_ICONS:=$(ALL_ICONS)

%.png:
	@bash -c './export-png-from-svg "$$(echo $@ | sed -E 's/-[[:digit:]]\+dpi.png/.svg/g')" "$@" "$$(echo $@ | cut -d. -f1 | rev | cut -d- -f1 | rev | sed 's/dpi//g')"'

$(ALL_ICONS):

all: $(ALL_ICONS)

clean:
	rm -f *.png
