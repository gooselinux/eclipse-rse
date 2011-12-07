#!/bin/sh

NAME=rse
TM_TAG=R3_1_2
RSE_TAG=R3_1_2

rm -rf temp
mkdir temp
pushd temp
flat=rse-${RSE_TAG}
mkdir ${flat}


VERSION="3.1.2"
TAG="201002152323"

echo "Exporting from CVS..."

MAPFILE=$NAME.map
TEMPMAPFILE=temp.map
wget "http://download.eclipse.org/dsdp/tm/downloads/drops/R-$VERSION-$TAG/directory.txt" -O $MAPFILE
dos2unix $MAPFILE
grep ^[a-z] $MAPFILE > $TEMPMAPFILE

echo "# `date`" > featureVersions.properties
echo "# `date`" > pluginVersions.properties

gawk 'BEGIN {
	FS=","
}
{
if (NF <  4) {

	split($1, version, "=");
	split(version[1], directory, "@");
	cvsdir=split($2, dirName, ":");
	printf("cvs -d %s%s %s %s %s %s %s\n", ":pserver:anonymous@dev.eclipse.org:", dirName[cvsdir], "-q export -r", version[2], "-d", directory[2], directory[2]);
	printf("cvs -d %s%s %s %s %s %s %s\n", ":pserver:anonymous@dev.eclipse.org:", dirName[cvsdir], "-q export -r", version[2], "-d", directory[2], directory[2]) | "/bin/bash";
	if (length(version[2]) > 0) {
		if (version[1] ~ /feature/) {
			printf("%s,0.0.0=%s\n", directory[2], version[2]) >> "featureVersions.properties";
		}
		else {
			printf("%s,0.0.0=%s\n", directory[2], version[2]) >> "pluginVersions.properties";
		}
	}
}
else {

	split($1, version, "=");
	split(version[1], featureName, "@");
	total=split($4, directory, "/");
	cvsdir=split($2, dirName, ":");
	printf("cvs -d %s%s %s %s %s %s %s\n", ":pserver:anonymous@dev.eclipse.org:", dirName[cvsdir], "-q export -r", version[2], "-d", directory[total], $4);
	printf("cvs -d %s%s %s %s %s %s %s\n", ":pserver:anonymous@dev.eclipse.org:", dirName[cvsdir], "-q export -r", version[2], "-d", directory[total], $4) | "/bin/bash";
	if (length(version[2]) > 0) {
		if (version[1] ~ /feature/) {
			printf("%s,0.0.0=%s\n", featureName[2], version[2]) >> "featureVersions.properties";
		}
		else {
			printf("%s,0.0.0=%s\n", directory[total], version[2]) >> "pluginVersions.properties";
		}
	}
}

}' $TEMPMAPFILE

rm $TEMPMAPFILE $MAPFILE

# Remove following feature.xml files which cause problems as pdebuild
# wants to generate them itself.
rm org.eclipse.rse.telnet-feature/sourceTemplateFeature/feature.xml
rm org.eclipse.rse.ftp-feature/sourceTemplateFeature/feature.xml

tar -czvf rse-fetched-src-$RSE_TAG.tar.gz org.*
