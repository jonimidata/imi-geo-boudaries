TOPOJSON = node_modules/.bin/topojson
TOPOJSON = /usr/local/bin/topojson
 
all: topojson/boundaries.topojson topojson/us-counties-10m.topojson

clean:
	rm -rf shp
	rm -rf geojson
	rm -rf topojson

clobber: clean
	rm -rf zip
	rm -rf gz

topojson/boundaries.topojson: geojson/mex.json geojson/usa-can.json geojson/countries.json
	mkdir -p $(dir $@)
	topojson -o $@ -- states=geojson/mex.json geojson/usa-can.json countries=geojson/countries.json 

# convert to geojson and filter for just US, CA, and MX
geojson/usa-can.json: shp/ne_50m_admin_1_states_provinces_lakes_shp.shp
	mkdir -p $(dir $@)
	#ogr2ogr -f GeoJSON -lco COORDINATE_PRECISION=2 -simplify 0.02 -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	ogr2ogr -f GeoJSON -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('USA', 'CAN')" $@ $<
	touch $@
geojson/mex.json: shp/ne_10m_admin_1_states_provinces_lakes_shp.shp
	mkdir -p $(dir $@)
	#ogr2ogr -f GeoJSON -lco COORDINATE_PRECISION=2 -simplify 0.02 -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	ogr2ogr -f GeoJSON -simplify 0.01 -lco COORDINATE_PRECISION=2 -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('MEX')" $@ $<
	touch $@
geojson/countries.json: shp/ne_50m_admin_0_countries_lakes.shp
	mkdir -p $(dir $@)
	#ogr2ogr -f GeoJSON -lco COORDINATE_PRECISION=2 -simplify 0.02 -select "sov_a3,name,iso_a2" -where "adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	ogr2ogr -f GeoJSON -select "sov_a3,name,iso_a2" -where "adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	touch $@

# unzip 
shp/ne_10m_admin_1_states_provinces_lakes_shp.shp: zip/ne_10m_admin_1_states_provinces_lakes_shp.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@
shp/ne_50m_admin_1_states_provinces_lakes_shp.shp: zip/ne_50m_admin_1_states_provinces_lakes_shp.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@
shp/ne_50m_admin_0_countries_lakes.shp: zip/ne_50m_admin_0_countries_lakes.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@


# Download Original Data
zip/ne_10m_admin_1_states_provinces_lakes_shp.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lakes_shp.zip" -O $@.download
	mv $@.download $@
zip/ne_10m_admin_0_countries_lakes.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries_lakes.zip" -O $@.download
	mv $@.download $@
zip/ne_10m_admin_1_states_provinces_lakes_shp.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_1_states_provinces_lakes_shp.zip" -O $@.download
	mv $@.download $@
zip/ne_10m_admin_0_countries_lakes.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries_lakes.zip" -O $@.download
	mv $@.download $@
zip/ne_50m_admin_0_countries_lakes.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_0_countries_lakes.zip" -O $@.download
	mv $@.download $@
zip/ne_50m_admin_1_states_provinces_lakes_shp.zip:
	mkdir -p $(dir $@)
	wget "http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/cultural/ne_50m_admin_1_states_provinces_lakes_shp.zip" -O $@.download
	mv $@.download $@





# For the full United States:
# - remove duplicate state geometries (e.g., Great Lakes)
# - merge the nation object into a single MultiPolygon
topojson/us-counties.topojson: shp/us/counties.shp shp/us/states.shp shp/us/nation.shp
	mkdir -p $(dir $@)
	$(TOPOJSON) -q 1e5 --id-property=FIPS,STATE_FIPS -p name=COUNTY,name=STATE -- $(filter %.shp,$^) | bin/topouniq states | bin/topomerge nation 1 > $@

# A simplified version of us-counties.json.
topojson/us-counties-10m.topojson: shp/us/counties.shp shp/us/states.shp shp/us/nation.shp
	mkdir -p $(dir $@)
	$(TOPOJSON) -q 1e5 -s 7e-7 --id-property=+FIPS,+STATE_FIPS -- shp/us/counties.shp shp/us/states.shp land=shp/us/nation.shp | bin/topouniq states | bin/topomerge land 1 > $@

shp/us/counties.shp: shp/us/counties-unfiltered.shp
	rm -f $@
	ogr2ogr -f 'ESRI Shapefile' -where "FIPS NOT LIKE '%000'" $@ $<

shp/us/counties-unfiltered.shp: gz/countyp010_nt00795.tar.gz
shp/us/states.shp: gz/statep010_nt00798.tar.gz
shp/us/nation.shp: gz/nationalp010g_nt00797.tar.gz

shp/us/%.shp:
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	tar -xzm -C $(basename $@) -f $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)

gz/%.tar.gz:
	mkdir -p $(dir $@)
	curl 'http://dds.cr.usgs.gov/pub/data/nationalatlas/$(notdir $@)' -o $@.download
	mv $@.download $@
