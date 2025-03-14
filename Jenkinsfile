pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = "karanthakkar09/static-site"
    }
    
    stages {
        stage('Fetch Tags') {
            steps {
                sh 'git fetch --tags'
                sh 'git tag -l'
            }
        }
        
        stage('Determine Version') {
            steps {
                script {
                    env.NEXT_VERSION = nextVersion()
                    echo "Building version: ${env.NEXT_VERSION}"
                    
                    if (env.NEXT_VERSION == null || env.NEXT_VERSION.trim() == '') {
                        error "Failed to determine next version using conventional commits"
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
                        -t ${DOCKER_IMAGE}:${NEXT_VERSION} \
                        --push .
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
        }
        success {
            echo "Successfully built and published Docker image ${DOCKER_IMAGE}:${NEXT_VERSION}"
        }
    }
}
