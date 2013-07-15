
all: geojson/ne_10m_admin_1_states_provinces_lakes_shp.json geojson/ne_10m_admin_0_countries_lakes.json

clean:
	rm -rf zip
	rm -rf shp
	rm -rf geojson
	rm -rf topojson

# convert to geojson and filter for just US, CA, and MX
geojson/ne_10m_admin_1_states_provinces_lakes_shp.json: shp/ne_10m_admin_1_states_provinces_lakes_shp.shp
	mkdir -p $(dir $@)
	ogr2ogr -f GeoJSON -lco COORDINATE_PRECISION=2 -simplify 0.02 -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	touch $@
geojson/ne_10m_admin_0_countries_lakes.json: shp/ne_10m_admin_0_countries_lakes.shp
	mkdir -p $(dir $@)
	ogr2ogr -f GeoJSON -lco COORDINATE_PRECISION=2 -simplify 0.02 -select "sov_a3,name,iso_a2" -where "adm0_a3 IN ('USA', 'CAN', 'MEX')" $@ $<
	touch $@


# unzip 
shp/ne_10m_admin_1_states_provinces_lakes_shp.shp: zip/ne_10m_admin_1_states_provinces_lakes_shp.zip
	mkdir -p $(dir $@)
	unzip -d shp $<
	touch $@
shp/ne_10m_admin_0_countries_lakes.shp: zip/ne_10m_admin_0_countries_lakes.zip
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
