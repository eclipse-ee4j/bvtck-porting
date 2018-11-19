#!/bin/bash -x

echo "ANT_HOME=$ANT_HOME"
echo "export JAVA_HOME=$JAVA_HOME"
echo "export MAVEN_HOME=$MAVEN_HOME"
echo "export PATH=$PATH"

cd $WORKSPACE
WGET_PROPS="--progress=bar:force --no-cache"
wget $WGET_PROPS $GF_BUNDLE_URL -O ${WORKSPACE}/latest-glassfish.zip
unzip -o ${WORKSPACE}/latest-glassfish.zip -d ${WORKSPACE}

which ant
ant -version

which mvn
mvn -version


sed -i "s#^porting\.home=.*#porting.home=$WORKSPACE#g" "$WORKSPACE/build.xml"
sed -i "s#^glassfish\.home=.*#glassfish.home=$WORKSPACE/glassfish5/glassfish#g" "$WORKSPACE/build.xml"

ant -version
ant dist.sani

mkdir -p ${WORKSPACE}/bundles
chmod 777 ${WORKSPACE}/dist/*.zip
cd ${WORKSPACE}/dist/
for entry in `ls bv-tck-glassfish-porting-2.0_*.zip`; do
  date=`echo "$entry" | cut -d_ -f2`
  strippedEntry=`echo "$entry" | cut -d_ -f1`
  echo "copying ${WORKSPACE}/dist/$entry to ${WORKSPACE}/bundles/${strippedEntry}_latest.zip"
  cp ${WORKSPACE}/dist/$entry ${WORKSPACE}/bundles/${strippedEntry}_latest.zip
  chmod 777 ${WORKSPACE}/bundles/${strippedEntry}_latest.zip
done
