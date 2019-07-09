JRA_DIR = pad_JRA
JRA_FILES = $(wildcard $(JRA_DIR)/friver_*.nc $(JRA_DIR)/licalvf_*.nc)
#JRA_FILES = pad_JRA/friver_input4MIPs_atmosphericState_OMIP_MRI-JRA55-do-1-4-0_gr_20180101-20181231.padded.nc
TARGS = $(subst padded.,padded.compressed.,$(notdir $(JRA_FILES)))
DEPS = ocean_hgrid.nc ocean_mask.nc runoff.daitren.clim.v2011.02.10.nc runoff.daitren.iaf.20120419.nc
COMPRESS =

all: $(TARGS) hash.md5
#	md5sum -c hash.md5

ocean_hgrid.nc ocean_mask.nc:
	wget -nv ftp://ftp.gfdl.noaa.gov/perm/Alistair.Adcroft/MOM6-testing/OM4_025/$@
	md5sum -c $@.md5

friver_%padded.nc: $(JRA_DIR)/friver_%padded.nc
	./regrid_runoff/regrid_runoff.py --fast_pickle ocean_hgrid.nc ocean_mask.nc $< --fms -r friver $(COMPRESS) $@
licalvf_%padded.nc: $(JRA_DIR)/licalvf_%padded.nc
	./regrid_runoff/regrid_runoff.py --fast_pickle ocean_hgrid.nc ocean_mask.nc $< --fms -r licalvf $(COMPRESS) $@
%padded.compressed.nc: %padded.nc
	nccopy -d 9 $< $@

hash.md5: | $(TARGS)
	md5sum $(TARGS) > $@

clean:
	rm -f $(TARGS) $(DEPS) pickle.*
