pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = "karanthakkar09/static-site"
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Determine next tag version') {
            steps {
                git branch: 'master', url: 'https://github.com/cyse7125-sp25-team02/static-site', credentialsId: 'github-credentials'
                script {
                    env.NEXT_VERSION = nextVersion()
                }
            }
        }

        stage('Push new tag version') {
            steps {
                script {
                    sh 'git config --global user.email "jenkins@jkops.com"'
                    sh 'git config --global user.name "Jenkins"'

                    if (env.NEXT_VERSION) {
                        sh "git tag -a ${env.NEXT_VERSION} -m 'Release version ${env.NEXT_VERSION}'"
                        sh "git push origin ${env.NEXT_VERSION}"
                    } else {
                        error("NEXT_VERSION is not defined. Cannot create a tag.")
                    }
                }
            }
        }

        stage('Setup BuildX') {
            steps {
                sh '''
                    docker buildx create --use
                    docker buildx inspect --bootstrap
                '''
            }
        }
        
        stage('Login and Build') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'

                script {
                    sh """
                        docker buildx build --platform linux/amd64,linux/arm64 \
                        -t ${DOCKER_IMAGE}:latest \
                        -t ${DOCKER_IMAGE}:${env.NEXT_VERSION} \
                        --push .
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
            sh 'docker builder prune -f'
            cleanWs()
        }
        success {
            echo "Successfully built and published Docker image ${DOCKER_IMAGE}:${env.NEXT_VERSION}"
        }
    }
}
