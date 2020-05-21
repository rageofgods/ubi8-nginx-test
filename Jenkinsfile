#!groovy

pipeline {
    agent {
        label 'dev'
    }
    environment {
        DOCKERFILE_NAME = 'Dockerfile'
        DOCKER_REGISTRY = 'registry.dso.techpark.local/dso.ext_test'
        RH_REGISTRY = 'rh-registry.dso.techpark.local'
        GIT_COMMIT_SHORT = sh(
            script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
            returnStdout: true
        )
    }
    
    stages {
        stage("Docker registry login") {
            steps {
                echo "=====docker login registry====="
                withCredentials([usernamePassword(credentialsId: '345c1db8-4753-4d13-8a98-24bbf9ad130f', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker login $RH_REGISTRY -u $USERNAME -p $PASSWORD
                    docker login $DOCKER_REGISTRY -u $USERNAME -p $PASSWORD
                    """
                }
            }
        }
        stage("Docker build image") {
            steps {
                echo "=====docker login and build====="
                withCredentials([usernamePassword(credentialsId: '345c1db8-4753-4d13-8a98-24bbf9ad130f', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker build -t $DOCKER_REGISTRY:$GIT_COMMIT_SHORT -f $DOCKERFILE_NAME .
                    """
                }
            }
        }
        stage("Docker push image") {
            steps {
                echo "=====docker login and push====="
                withCredentials([usernamePassword(credentialsId: '345c1db8-4753-4d13-8a98-24bbf9ad130f', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    docker push $DOCKER_REGISTRY:$GIT_COMMIT_SHORT
                    """
                }
            }
        }
    }
}
