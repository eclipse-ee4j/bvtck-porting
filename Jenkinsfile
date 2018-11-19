env.label = "bv-tck-ci-pod-${UUID.randomUUID().toString()}"
pipeline {
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  agent {
    kubernetes {
      label "${env.label}"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
spec:
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "localhost.localdomain"
  containers:
  - name: bv-tck-ci
    image: anajosep/cts-base:0.1
    command:
    - cat
    tty: true
    imagePullPolicy: Always
    env:
      - name: JAVA_TOOL_OPTIONS
        value: -Xmx2G
    resources:
      limits:
        memory: "8Gi"
        cpu: "2.0"
"""
    }
  }
  parameters {
    string(name: 'GF_BUNDLE_URL', 
           defaultValue: 'https://repo1.maven.org/maven2/org/glassfish/main/distributions/glassfish/5.1.0-RC1/glassfish-5.1.0-RC1.zip',
           description: 'URL required for downloading GlassFish Full/Web profile bundle' )
  }
  environment {
    JAVA_HOME = "/opt/jdk1.8.0_171/"
    ANT_HOME = "/usr/share/ant"
    MAVEN_HOME = "/usr/share/maven"
    PATH = "${MAVEN_HOME}/bin:${ANT_HOME}/bin:${JAVA_HOME}/bin:${PATH}"
    ANT_OPTS = "-Djavax.xml.accessExternalStylesheet=all -Djavax.xml.accessExternalSchema=all -Djavax.xml.accessExternalDTD=file,http" 
    MAVEN_OPTS="-Duser.home=$HOME"
  }
  stages {
    stage('bv-tck-build') {
      steps {
        container('bv-tck-ci') {
          sh """
            env
            bash -x ${WORKSPACE}/docker/build_bvtck.sh
          """
          archiveArtifacts artifacts: 'bundles/*.zip'
        }
      }
    }
  
    stage('bv-tck-run') {
      steps {
        container('bv-tck-ci') {
          sh """
            env
            bash -x ${WORKSPACE}/docker/run_bvtck.sh
          """
          archiveArtifacts artifacts: "bvtck-results.tar.gz"
          junit testResults: 'bvtck-report/beanvalidation-2.0/*.xml', allowEmptyResults: true
        }
      }
    }
  }
}
