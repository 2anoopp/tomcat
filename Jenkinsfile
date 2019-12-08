pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    triggers {
         pollSCM('* * * * *')
     }

    parameters {

        string(name: 'sns_noc_arn_dev', defaultValue: '', description: 'Glues SNS Topic for Jenkins Build Notifications - Development')
        string(name: 'sns_noc_arn_stage', defaultValue: '', description: 'Glues SNS Topic for Jenkins Build Notifications - Staging')
        string(name: 'sns_noc_arn_prod', defaultValue: '', description: 'Glues SNS Topic for Jenkins Build Notifications - Production')
        
        string(name: 'glues_dev_server', defaultValue: '10.0.28.8', description: 'Development Server')
        string(name: 'glues_dev_ssh_user', defaultValue: 'ubuntu', description: 'Staging Server')

        string(name: 'glues_stage_server', defaultValue: '10.0.28.8', description: 'Staging Server')
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

//  Send Build Notification

        // stage('Send Notification - Development'){
        //     when {branch 'development' }
        //     steps {
        //         snsPublish(topicArn:"${params.sns_noc_arn_dev}", subject:'Starting build', message:"Build: ${env.BUILD_NUMBER} started ")
        //     }
        // }

        // stage('Send Notification - Staging'){
        //     when {branch 'staging' }
        //     steps {
        //         snsPublish(topicArn:"${params.sns_noc_arn_stage}", subject:'Starting build', message:"Build: ${env.BUILD_NUMBER} started ")
        //     }
        // }

        // stage('Send Notification - Production'){
        //     when {branch 'production' }
        //     steps {
        //         snsPublish(topicArn:"${params.sns_noc_arn_prod}", subject:'Starting build', message:"Build: ${env.BUILD_NUMBER} started ")
        //     }
        // }        

//  Build War File

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
                    sh 'cp maven-sample/target/java-tomcat-maven-example.war codedeploy/'
                    sh 'tar -zcvf glues-codedeploy.tar.gz -C codedeploy .'
                    s3Upload(file:'glues-codedeploy.tar.gz', bucket:"${params.s3_bucket_glues_prod}", path:'glues/glues-codedeploy.tar.gz')
                }
            }
        } 


//  Deploy war file to Webserver

        stage("Deploy War - Development "){
            environment{
                glues_dev_ssh_user = "${params.glues_dev_ssh_user}"
                glues_dev_server = "${params.glues_dev_server}"
            }
            when { branch 'development' }            
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

