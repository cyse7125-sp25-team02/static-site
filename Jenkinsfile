pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = "karanthakkar09/static-site"
    }
    
    stages {
        stage('Determine next version') {
            steps {
                git branch: 'master', url: 'https://github.com/cyse7125-sp25-team02/static-site'
                env.NEXT_VERSION = nextVersion()
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
