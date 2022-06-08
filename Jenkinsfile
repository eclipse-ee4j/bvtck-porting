/*
 * Copyright (c) 2018, 2022 Oracle and/or its affiliates. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0, which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the
 * Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
 * version 2 with the GNU Classpath Exception, which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 */

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
    image: jakartaee/cts-base:0.3
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
           defaultValue: 'https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.0-SNAPSHOT-nightly.zip',
           description: 'URL required for downloading GlassFish Full/Web profile bundle' )
    string(name: 'TCK_BUNDLE_BASE_URL',
           defaultValue: '',
           description: 'Base URL required for downloading prebuilt binary TCK Bundle from a hosted location' )
    string(name: 'TCK_BUNDLE_FILE_NAME', 
           defaultValue: 'bv-tck-glassfish-porting-3.0.0.zip', 
           description: 'Name of bundle file to be appended to the base url' )
    string(name: 'BV_TCK_BUNDLE_URL', 
           defaultValue: 'https://download.eclipse.org/ee4j/bean-validation/3.0/beanvalidation-tck-dist-3.0.1.zip', 
  	   description: 'BV TCK bundle url' )
    string(name: 'BV_TCK_VERSION', 
           defaultValue: '3.0.1', 
           description: 'version of bundle file' )
    choice(name: 'JDK', choices: 'JDK11\nJDK17',
           description: 'Java SE Version to be used for running TCK either JDK11 or JDK17' )
  }
  environment {
    ANT_HOME = "/usr/share/ant"
    MAVEN_HOME = "/usr/share/maven"
    ANT_OPTS = "-Djavax.xml.accessExternalStylesheet=all -Djavax.xml.accessExternalSchema=all -Djavax.xml.accessExternalDTD=file,http -Duser.home=$HOME" 
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
          archiveArtifacts artifacts: "bvtck-results.tar.gz,bvtck-report/**/*.xml,bvtck-report/**/*.html"
          junit testResults: 'bvtck-report/**/*.xml', allowEmptyResults: true
        }
      }
    }
  }
}
