----------------------------------------------------------------------
To run the Bean Validation TCK against the Java EE 8 Reference Implementation,
follow the steps in this file.  The ant targets provided will call Maven which
will download the TCK artifacts and execute the TCK against the Java EE
Reference implementation.

----------------------------------------------------------------------
Other links:

TCK Bundle:  http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/2.0.0.Final/
TCK workspace:  https://github.com/beanvalidation/beanvalidation-tck

----------------------------------------------------------------------

Steps to run the tests
=======================
- Install Maven - http://maven.apache.org/download.cgi
  Ensure that mvn is in your path
  Set MAVEN_HOME in your environment
  Note: The test will overwrite ~/.m2/settings.xml with beanvalidation specific settings.xml. Take a backup of your settings.xml

- Install Ant - http://ant.apache.org/bindownload.cgi
  Ensure that ant is in your path

- Install V5 refer to this as GF_HOME

- Unzip the BV porting bundle in the top level of the BV TCK (not required).
    Refer to this location as PORTING_HOME

- cd to PORTING_HOME and edit the build.properties file

- set the JAVA_HOME environment variable in your shell environment

- set porting.home, and glassfish.home in build.properties

- If necessary, modify the following default property values in build.xml for your environment
    <property name="max.heap.size" value="3072m" />
    <property name="max.perm.gen.size" value="1024m" />
    On windows, try setting max.heap.size=1024 and max.perm.gen.size=512

- Invoke 'ant sigtest' to run the signature tests

- Invoke 'ant test' to run the TestNG test suite

- To run the sig tests and the TestNG tests in a single run, you can invoke
  ant run.all.tests

-If running Glassfish with a security manager (by executing
 $GF_HOME/bin/asadmin create-jvm-options -Djava.security.manager, you must add
 the following permissions to the server.policy file...

grant {
   permission java.lang.reflect.ReflectPermission "suppressAccessChecks";
   permission org.osgi.framework.AdminPermission "*", "*";
   permission java.lang.RuntimePermission "createClassLoader";
   permission javax.security.auth.AuthPermission "modifyPrincipals";
   permission org.hibernate.validator.HibernateValidatorPermission "accessPrivateMembers";
 };
