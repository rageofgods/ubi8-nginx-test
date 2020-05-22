#!groovy

pipeline {
    agent {
        label 'dev'
    }
    environment {
        DOCKERFILE_NAME = 'Dockerfile'
        DOCKER_REGISTRY = 'registry.dso.techpark.local'
        BUILD_NAME = 'ext-test'
        RH_REGISTRY = 'rh-registry.dso.techpark.local'
        OCP_URL = 'https://console.okd.techpark.local'
        IMAGESTREAM = 'okd/imagestream.yaml'
        TEAMPLATE = 'okd/template.yaml'
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
                sh """
                docker build -t $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT -f $DOCKERFILE_NAME .
                """
            }
        }
        stage("Docker push image") {
            steps {
                echo "=====docker login and push====="
                sh """
                docker push $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT
                """
            }
        }
        stage("ocp login") {
            steps {
                echo "=====ocp login====="
                withCredentials([string(credentialsId: '17a0e23e-81a3-481c-b8b5-19a25060e1ef', variable: 'TOKEN')]) {
                    sh """
                    oc login $OCP_URL --token $TOKEN
                    """
                }
            }
        }
        stage("ocp init image stream and teamplate") {
            steps {
                echo "=====ocp login====="
                    sh """
                    oc apply -f $IMAGESTREAM
                    oc apply -f $TEAMPLATE
                    """
            }
        }
        stage("ocp build") {
            steps {
                echo "=====ocp tag new image as latest====="
                    sh """
                    oc tag $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT $BUILD_NAME:latest
                    """
            }
        }
    }
}
