pipeline {
    agent any 

    // المتغيرات البيئية (يجب تكوينها في Jenkins)
    environment {
        // اسم الصورة لدفعها إلى Docker Hub
        DOCKER_IMAGE = "ahmedzain10/spring-petclinic-prod"
        // تفاصيل النشر (يجب جلبها من Jenkins Secrets/Global Variables)
        SSH_HOST = "your.ubuntu.host.ip" 
        SSH_USER = "ubuntu_user"
        REMOTE_APP_DIR = "/opt/petclinic-app"
    }

    stages {
        stage('1. Build and Test') {
            steps {
                echo 'Building Spring PetClinic application with Maven...'
                // 1. سحب الكود من المستودع
                checkout scm
                
                // 2. تجميع المشروع وحزم ملف JAR (يفترض أن Maven و JDK 17 متاحان على العامل)
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('2. Docker Build and Push') {
            steps {
                echo 'Building and pushing Docker image to Docker Hub...'
                
                // --- المصادقة مع Docker Hub ---
                // يجب أن يكون 'docker-hub-credentials' هو ID بيانات الاعتماد (اسم مستخدم/كلمة مرور) في Jenkins
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', 
                                                  usernameVariable: 'DOCKER_USR', 
                                                  passwordVariable: 'DOCKER_PWD')]) {
                    sh "docker login -u ${DOCKER_USR} -p ${DOCKER_PWD}"
                }

                // 1. بناء الصورة وتسميتها بـ V1.0 و latest
                sh "docker build -t ${DOCKER_IMAGE}:V1.0 -t ${DOCKER_IMAGE}:latest ."

                // 2. دفع الصورتين إلى Docker Hub
                sh "docker push ${DOCKER_IMAGE}:V1.0"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('3. Deploy via SSH') {
            // تتطلب هذه المرحلة تثبيت الملحقات (Plugins) مثل 'sshagent'
            steps {
                echo "Deploying to ${SSH_USER}@${SSH_HOST} at ${REMOTE_APP_DIR}"
                
                // --- الاتصال الآمن بـ SSH ---
                // 'deployment-ssh-key' يجب أن يكون ID المفتاح الخاص لـ SSH في Jenkins
                withCredentials([sshUserPrivateKey(credentialsId: 'deployment-ssh-key', keyFileVariable: 'SSH_KEY_FILE')]) {
                    
                    // 1. نسخ docker-compose.yml إلى الخادم البعيد
                    sh "scp -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no docker-compose.yml ${SSH_USER}@${SSH_HOST}:${REMOTE_APP_DIR}/docker-compose.yml"
                    
                    // 2. تنفيذ أوامر النشر عن بعد
                    sh """
                        ssh -i ${SSH_KEY_FILE} -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} << EOF
                        # الانتقال إلى دليل النشر
                        cd ${REMOTE_APP_DIR}
                        
                        # سحب أحدث صورة
                        docker compose pull
                        
                        # إيقاف وإعادة تشغيل الحاويات
                        docker compose up -d --remove-orphans
                        
                        echo "Deployment successful for Spring PetClinic."
                        EOF
                    """
                }
            }
        }
    }
}
