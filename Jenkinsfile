#!groovy

def building_dev = ["dev", "uat"] //define running environments

//get current build prefix from the job name
def current_build_prefix = "${env.JOB_NAME}".substring("${env.JOB_NAME}".indexOf("(") + 1, "${env.JOB_NAME}".length() - 1)

//define environment list size
def current_build_index = building_dev.findIndexOf{it == current_build_prefix}
def build_index_size = building_dev.size()

pipeline {
    agent {
        label "${params.AGENT_TAG}"
    }
    environment {
        DOCKERFILE_NAME = "${params.DOCKERFILE_NAME}"
        TEMPLATE_NAME = "${params.TEMPLATE_NAME}"
        DOCKER_REGISTRY = "${params.DOCKER_REGISTRY}"
        DOCKER_REGISTRY_AUTH_ID = "${params.DOCKER_REGISTRY_AUTH_ID}"
        BUILD_NAME = "${params.BUILD_NAME}"
        RH_REGISTRY = "${params.RH_REGISTRY}"
        RH_REGISTRY_AUTH_ID = "${params.RH_REGISTRY_AUTH_ID}"
        OCP_URL = "${params.OCP_URL}"
        OCP_AUTH_ID = "${params.OCP_AUTH_ID}"
        IMAGESTREAM = "${params.IMAGESTREAM}"
        GIT_COMMIT_SHORT = sh(
            script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
            returnStdout: true
        )
    }
    
    stages {
        stage("Docker registry login") {
            steps {
                echo "=====docker login registry====="
                withCredentials([usernamePassword(credentialsId: "$DOCKER_REGISTRY_AUTH_ID", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
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
                withCredentials([string(credentialsId: "$OCP_AUTH_ID", variable: 'TOKEN')]) {
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
                    oc apply -f $TEMPLATE_NAME
                    """
            }
        }
        stage("ocp deploy") {
            steps {
                echo "=====ocp tag new image as latest====="
                    sh """
                    oc tag $DOCKER_REGISTRY/$BUILD_NAME:$GIT_COMMIT_SHORT $BUILD_NAME:latest
                    """
            }
        }
        stage("ocp create new app from the template") {
            when {
                not {
                    expression {
                        def status = sh(script: "oc get all --selector app=$BUILD_NAME | grep Running", returnStatus: true) 
                        if (status != 0) {
                            return false;
                        }
                        else {
                            return true;
                        }
                    }
                }
            }
            steps {
                echo "=====ocp create application====="
                    sh """
                    oc new-app --template=$BUILD_NAME
                    """
            }
        }
        stage("ocp get status") {
            steps {
                echo "=====Waiting 15 second to build process catch-up====="
                sleep(time:15,unit:"SECONDS")
                echo "=====ocp get podes====="
                    sh """
                    oc get pods | grep Running | grep '1/1'
                    """
            }
        }
        stage("Run next stage") {
            steps {
                script {
                    //run next environment job if we don't finish
                    println "Running ${building_dev[current_build_index + 1]}"
                    if (current_build_index < build_index_size - 1) {
                        build job: "dso.ext_test(${building_dev[current_build_index + 1]})"
                    }
                }
            }
        }
    }
}
