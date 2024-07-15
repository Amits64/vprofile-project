pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }

    environment {
        SNAP_REPO = 'vprofile-snapshot'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUSIP = '192.168.2.20'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
    }

    stages {
        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexuslogin', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh 'mvn -s settings.xml -DskipTests install -X'
                }
            }
            post {
                success {
                    echo "Now archiving..."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }

        stage('Test') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexuslogin', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh 'mvn -s settings.xml test'
                }
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexuslogin', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh 'mvn checkstyle:checkstyle'
                }
            }
        }
    }
}
