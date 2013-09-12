TOPOJSON = node_modules/.bin/topojson
TOPOJSON = /usr/local/bin/topojson
 
all: topojson/countries.topojson topojson/provinces.topojson topojson/us-counties-10m.topojson 

clean:
	rm -rf shp
	rm -rf geojson
	rm -rf topojson

clobber: clean
	rm -rf zip
	rm -rf gz

topojson/countries.topojson: geojson/countries.json
	mkdir -p $(dir $@)
	topojson -p --id-property=iso_a2 -o $@ -- countries=geojson/countries.json 
	touch $@

topojson/provinces.topojson: geojson/provinces.json
	mkdir -p $(dir $@)
	topojson -p --id-property=code_hasc -o $@ -- provinces=geojson/provinces.json
	touch $@

topojson/regions.topojson: geojson/regions.json
	mkdir -p $(dir $@)
	topojson -p --id-property=region_big -o $@ -- provinces=geojson/regions.json
	touch $@

topojson/us-counties-10m.topojson: shp/us/counties.shp shp/us/states.shp shp/us/nation.shp
	mkdir -p $(dir $@)
	#$(TOPOJSON) -q 1e5 -s 7e-7 --id-property=+STATE,+FIPScode_hasc -- shp/us/counties.shp shp/us/states.shp land=shp/us/nation.shp | bin/topouniq states | bin/topomerge land 1 > $@
	$(TOPOJSON) -q 1e5 -s 7e-7 --id-property=code_hasc -- shp/us/counties.shp > $@
	touch $@

geojson/provinces.json: shp/provinces.shp
	mkdir -p $(dir $@)
	ogr2ogr -f GeoJSON $@ $<
	touch $@
geojson/regions.json: shp/regions.shp
	mkdir -p $(dir $@)
	ogr2ogr -f GeoJSON $@ $<
	touch $@



shp/provinces.shp: shp/mexico.shp shp/ne_50m_admin_1_states_provinces_lakes_shp.shp
	ogr2ogr -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('USA', 'CAN')" $@ shp/ne_50m_admin_1_states_provinces_lakes_shp.shp
	ogr2ogr -update -append $@ shp/mexico.shp -nln provinces

shp/mexico.shp: shp/ne_10m_admin_1_states_provinces_lakes_shp.shp
	mkdir -p $(dir $@)
	ogr2ogr -simplify 0.01 -lco COORDINATE_PRECISION=2 -select "sr_sov_a3,iso_a2,name,code_hasc,region,region_big,postal" -where "sr_adm0_a3 IN ('MEX')" $@ $<
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

shp/region-shp.zip: zip/region-shp.zip
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
zip/region-shp.zip:
	mkdir -p $(dir $@)
	wget "https://s3.amazonaws.com/imi-model-input-XqXP6Ln7xIg8I2Of/shp/region-shp.zip?AWSAccessKeyId=ASIAI6UW7DB52LVWBEXA&Expires=1379000981&Signature=zXkaLfh/s4KONwitDxLwBTYJShw%3D&x-amz-security-token=AQoDYXdzENn//////////wEawAK%2BrHbW7hSmqdyA6eYlHVWFUZcBkhkGychmHODaR1SjU0nQSB1ahGTKeBzbyMYgiL53bpLeUcXTtCGXHWzV1UxJAamyLN%2BV40WForidvQfcYucQVKxC4oKVPKjph73ur5R0RQrD8IF5OsvvDpLQSJmFNuS1C8WrNa2kpGYcUnqdAKwclLKqT2oWHJGbEKeULU/2g6svXE/FW48oj%2BEk4TtLFRvBY8mZ09xWAObMHzGGRal8ZxeSocqiS2IlLzAovpsevI6tkl0yNg1yfjI812p0vvXcvxuOUOLa4AdQNZhD4Xn1laCLHwaIGgpR7/WwX%2BvqSTKZASWD4Wu5GkOdJ2pxkaPODKTv4OzNmbOKLaRXwXKVYBqKJDhbOppTbwFh9xRkplpb/36CzVn3u1MYeY%2BVRL1DdLD1vnzKRmK2s9DoXiCuwseRBQ%3D%3D" -O $@.download
	mv $@.download $@




# For the full United States:
# - remove duplicate state geometries (e.g., Great Lakes)
# - merge the nation object into a single MultiPolygon
topojson/us-counties.topojson: shp/us/counties.shp shp/us/states.shp shp/us/nation.shp
	mkdir -p $(dir $@)
	$(TOPOJSON) -p -q 1e5 --id-property=FIPS,STATE_FIPS -p name=COUNTY,name=STATE -- $(filter %.shp,$^) | bin/topouniq states | bin/topomerge nation 1 > $@

shp/us/counties.shp: shp/us/counties-unfiltered.shp
	rm -f $@
	ogr2ogr -f 'ESRI Shapefile' -sql "SELECT COUNTY, FIPS, SUBSTR(FIPS,3,3) as COUNTY_FIPS,STATE,STATE_FIPS, CONCAT('US.',STATE,'.',SUBSTR(FIPS,3,3)) as code_hasc FROM 'counties-unfiltered' WHERE FIPS NOT LIKE '%000'" $@ $<

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
