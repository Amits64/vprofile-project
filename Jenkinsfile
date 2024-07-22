def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline {
    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
        dockerTool "Docker"
    }

    environment {
        SNAP_REPO = 'vprofile-snapshot'
        RELEASE_REPO = 'vprofile-release'
        CENTRAL_REPO = 'vpro-maven-central'
        NEXUS_LOGIN = 'nexuslogin'
        NEXUSIP = '192.168.2.20'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'vpro-maven-group'
        SONAR_SCANNER_IMAGE = 'sonarsource/sonar-scanner-cli:latest'
        SONAR_PROJECT_KEY = 'vprofile-app'
        SONAR_HOST_URL = 'http://192.168.2.20:9000/'
        SONAR_PROJECT_NAME = 'vprofile-app'
        registryCredentials = 'ecr:us-east-1:awscreds'
        appRegistry = '654654622541.dkr.ecr.us-east-1.amazonaws.com/devops-tech'
        vprofileRegistry = 'https://654654622541.dkr.ecr.us-east-1.amazonaws.com'
    }

    stages {
        stage('Debug Java Version') {
            steps {
                script {
                    sh 'echo JAVA_HOME: ${JAVA_HOME}'
                    sh 'echo PATH: ${PATH}'
                    sh 'which java'
                    sh 'java -version'
                }
            }
        }

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
                    sh 'mvn -s settings.xml checkstyle:checkstyle'
                }
            }
        }

        /*stage('Code Quality') {
            steps {
                script {
                    docker.image(env.SONAR_SCANNER_IMAGE).inside('-u root') {
                        withSonarQubeEnv('sonarqube') {
                            sh """
                            /opt/sonar-scanner/bin/sonar-scanner \
                            -Dsonar.projectKey=${env.SONAR_PROJECT_KEY} \
                            -Dsonar.projectName=${SONAR_PROJECT_NAME} \
                            -Dsonar.projectVersion=1.0 \
                            -Dsonar.sources=src/ \
                            -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                            -Dsonar.junit.reportsPath=target/surefire-reports/ \
                            -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                            -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
                            -Dsonar.analysis.mode=preview \
                            -Dsonar.report.export.path=sonar-report-task.txt
                            """
                        }
                    }
                }
            }
            post {
                always {
                    echo 'Sending Slack Notifications...'
                    script {
                        slackSend(
                            channel: '#jenkinscicd',
                            color: COLOR_MAP[currentBuild.currentResult],
                            message: """
                            SonarQube analysis for ${env.JOB_NAME} build ${env.BUILD_NUMBER}
                            Status: *${currentBuild.currentResult}*
                            More info: ${analysisLink}
                            """
                        )
                    }
                }
            }
        }*/

        stage("Upload Artifact") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexuslogin', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                        groupId: 'QA',
                        version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                        repository: "${RELEASE_REPO}",
                        credentialsId: "${NEXUS_LOGIN}",
                        artifacts: [
                            [artifactId: 'vproapp',
                             classifier: '',
                             file: 'target/vprofile-v2.war',
                             type: 'war']
                        ]
                    )
                }
            }
            post {
                always {
                    echo 'Slack Notifications.'
                    slackSend(
                            channel: '#jenkinscicd',
                            color: COLOR_MAP.get(currentBuild.currentResult),
                            message: """
                            SonarQube analysis for ${env.JOB_NAME} build ${env.BUILD_NUMBER}
                            Status: *${currentBuild.currentResult}*
                            More info: ${env.BUILD_URL}
                            """
                        )
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build(appRegistry + ":$BUILD_NUMBER", "-f Dockerfile .")
                }
            }
        }

        stage('Upload Image to ECR Registry') {
            steps {
                script {
                    docker.withRegistry(vprofileRegistry, registryCredentials) {
                        dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }
    }
}
