#!groovy

pipeline {
    agent {
        lavel 'dev'
    }
    environment {
        DOCKERFILE_NAME = 'Dockerfile'
        DOCKER_REGISTRY = 'registry.dso.techpark.local/khokhlov_test'
        GIT_COMMIT_SHORT = sh(
            script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
            returnStdout: true
        )
    }
    
    stages {
        stage("Docker build image") {
            steps {
                echo "=====docker login and build====="
                withCredentials([usernamePassword(credentialsId: '05e44468-b78a-4c8d-961b-6f42cf1040bc', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker build -t $DOCKER_REGISTRY:$GIT_COMMIT_SHORT -f $DOCKERFILE_NAME .
                    """
                }
            }
        }
        stage("Docker push image") {
            steps {
                echo "=====docker login and push====="
                withCredentials([usernamePassword(credentialsId: '05e44468-b78a-4c8d-961b-6f42cf1040bc', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker push $DOCKER_REGISTRY:$GIT_COMMIT_SHORT
                    """
                }
            }
        }
    }
}
