pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    triggers {
         pollSCM('* * * * *')
     }

    parameters {
        string(name: 'glues_dev_server', defaultValue: '10.0.28.8', description: 'Development Server')
        string(name: 'glues_stage_server', defaultValue: '10.0.28.8', description: 'Staging Server')
        string(name: 'glues_dev_ssh_user', defaultValue: 'ubuntu', description: 'Staging Server')
        string(name: 'glues_stage_ssh_user', defaultValue: 'ubuntu', description: 'Staging Server')
        string(name: 's3_bucket_glues_prod', defaultValue: 'nr-innovaturelabs-artifacts', description: 'Production S3 bucket')
    }
    stages {

//  Checkout Git Repository
        stage("Git Checkout - Development"){
            when { branch 'development' }
            steps {
                checkout scm
                }
        }
        stage("Git Checkout - Staging"){
            when { branch 'staging' }
            steps {
                checkout scm
                }
        }
        stage("Git Checkout - Production"){
            when { branch 'master' }
            steps {
                checkout scm
                }
        } 

        stage("Build War  - Development "){
            when { branch 'development' }
            steps{
                dir("maven-sample"){
                    sh 'mvn package'
                    }
                }
        }

        stage("Build War  - Staging "){
            when { branch 'staging' }
            steps{
                dir("maven-sample"){
                    sh 'mvn package'
                    }
                }
        }

        stage("Build War  - Production "){
            when { branch 'master' }
            steps{
                dir("maven-sample"){
                    sh 'mvn package'
                    }
                }
            post {
                success {
                    echo 'Pushing archive to S3'
                    s3Upload(file:'maven-sample/target/java-tomcat-maven-example.war', bucket:"${params.s3_bucket_glues_prod}", path:'glues/java-tomcat-maven-example.war')
                }
            }
        } 


//  Deploy war file to Webserver

        stage("Deploy War - Development "){
            environment{
                glues_dev_ssh_user = "${params.glues_dev_ssh_user}"
                glues_dev_server = "${params.glues_dev_server}"
            }
            when { branch 'master' }            
             steps{
                sh '''#!/usr/bin/env bash
                    rsync -av --rsync-path="sudo rsync" maven-sample/target/*.war $glues_dev_ssh_user@$glues_dev_server:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no $glues_dev_ssh_user@$glues_dev_server << ENDSSH
                    sudo systemctl restart tomcat9
ENDSSH
                '''                
            } 
        } 

        stage("Deploy War - Staging "){
            environment{
                glues_stage_ssh_user = "${params.glues_stage_ssh_user}"
                glues_stage_server = "${params.glues_stage_server}"
            }

            when { branch 'staging' }            
             steps{
                sh '''#!/usr/bin/env bash
                    rsync -av --rsync-path="sudo rsync" maven-sample/target/*.war $glues_stage_ssh_user@$glues_stage_server:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no $glues_stage_ssh_user@$glues_stage_server << ENDSSH
                    sudo systemctl restart tomcat9
ENDSSH
                '''                
            } 
        } 
    }  

    post {

        always {
           // Wipe out the workspace before we finish!
            deleteDir()
            cleanWs()
        

        }
        success {
            // Wipe out the workspace before we finish!
            deleteDir()
            cleanWs()
            // Send Success Message to Team
        }
        failure {
            echo "Build failed"
            deleteDir()
            cleanWs()
            // Send Failure Message to Team                
        }
    }

}        

