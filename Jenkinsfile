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
                script {
                    // Use credentials to authenticate with Nexus repository
                    withCredentials([usernamePassword(credentialsId: 'nexuslogin', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        // Run Maven build with necessary settings
                        def mvnCmd = "mvn -s settings.xml -DskipTests install -X"
                        def mvnBuild = bat(script: mvnCmd, returnStatus: true)

                        if (mvnBuild != 0) {
                            error "Maven build failed: ${mvnBuild}"
                        }
                    }
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
                script {
                    // Run Maven tests
                    def mvnTestCmd = "mvn -s settings.xml test"
                    def mvnTest = bat(script: mvnTestCmd, returnStatus: true)

                    if (mvnTest != 0) {
                        error "Maven test execution failed: ${mvnTest}"
                    }
                }
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                script {
                    // Run Checkstyle analysis
                    def mvnCheckstyleCmd = "mvn checkstyle:checkstyle"
                    def mvnCheckstyle = bat(script: mvnCheckstyleCmd, returnStatus: true)

                    if (mvnCheckstyle != 0) {
                        error "Checkstyle analysis failed: ${mvnCheckstyle}"
                    }
                }
            }
        }
    }
}
