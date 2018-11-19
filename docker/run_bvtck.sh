#!/bin/bash -xe

VER="2.0"
unzip -o ${WORKSPACE}/bundles/bv-tck-glassfish-porting-2.0_latest.zip -d ${WORKSPACE}

export TS_HOME=${WORKSPACE}/bv-tck-glassfish-porting

#Install Glassfish
echo "Download and install GlassFish 5.0.1 ..."
if [ -z "${GF_BUNDLE_URL}" ]; then
  export GF_BUNDLE_URL="http://download.oracle.com/glassfish/5.0.1/nightly/latest-glassfish.zip"
fi
wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
unzip -o ${WORKSPACE}/latest-glassfish.zip -d ${WORKSPACE}

which ant
ant -version

REPORT=${WORKSPACE}/bvtck-report

mkdir -p ${REPORT}/beanvalidation-$VER-sig
mkdir -p ${REPORT}/beanvalidation-$VER

#Edit Glassfish Security policy
cat ${WORKSPACE}/docker/BV.policy >> ${WORKSPACE}/glassfish5/glassfish/domains/domain1/config/server.policy

#Edit test properties
sed -i "s#porting.home=.*#porting.home=${TS_HOME}#g" ${TS_HOME}/build.properties
sed -i "s#glassfish.home=.*#glassfish.home=${WORKSPACE}/glassfish5/glassfish#g" ${TS_HOME}/build.properties
sed -i "s#report.dir=.*#report.dir=${REPORT}#g" ${TS_HOME}/build.properties
sed -i "s#admin.user=.*#admin.user=admin#g" ${TS_HOME}/build.properties

#Run Tests
cd ${TS_HOME}
ant -Duser.home=$HOME sigtest
ant -Duser.home=$HOME test

#List dependencies used for testing
cd ${TS_HOME}/glassfish-tck-runner
mvn dependency:tree
#Generate Reports
echo "<pre>" > ${REPORT}/beanvalidation-$VER-sig/report.html
cat $REPORT/bv_sig_test_results.txt >> $REPORT/beanvalidation-$VER-sig/report.html
echo "</pre>" >> $REPORT/beanvalidation-$VER-sig/report.html
cp $REPORT/beanvalidation-$VER-sig/report.html $REPORT/beanvalidation-$VER-sig/index.html

cp -R ${TS_HOME}/glassfish-tck-runner/target/surefire-reports/* ${REPORT}/beanvalidation-${VER}
cp ${REPORT}/beanvalidation-$VER/test-report.html ${REPORT}/beanvalidation-${VER}/report.html

tar zcvf ${WORKSPACE}/bvtck-results.tar.gz ${REPORT} ${WORKSPACE}/bv-tck-glassfish-porting/glassfish-tck-runner/target/surefire-reports ${WORKSPACE}/glassfish5/glassfish/domains/domain1/config ${WORKSPACE}/glassfish5/glassfish/domains/domain1/logs
