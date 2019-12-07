pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    triggers {
         pollSCM('* * * * *')
     }
  
    stages {

//  Checkout Git Repository
        stage("Git Checkout - Production"){
            when { branch 'master' }
            steps {
                checkout scm
                }
        } 

        stage("Build Image  - Production "){
            when { branch 'master' }
            steps{
                dir("maven-sample"){
                    sh 'mvn package'
                    }
                }
            post {
                success {
                    echo 'Pushing archive to S3'
                    s3Upload(file:'maven-sample/target/java-tomcat-maven-example.war', bucket:'nr-innovaturelabs-artifacts', path:'glues/java-tomcat-maven-example.war')
                }
            }
        } 


//  Deploy war file to Webserver

        stage("Deploy Image - Production "){
            when { branch 'master' }            
             steps{
                sh '''#!/usr/bin/env bash
                    rsync -av --rsync-path="sudo rsync" maven-sample/target/*.war ubuntu@10.0.28.8:/var/lib/tomcat9/webapps/
                    ssh -o StrictHostKeyChecking=no ubuntu@10.0.28.8 << ENDSSH
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

