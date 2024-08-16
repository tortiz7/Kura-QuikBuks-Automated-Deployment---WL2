# Retail Banking App Deployment with AWS CLI and Jenkins

## PURPOSE
The goal of this project was to deploy _**Kura QuikBuks Automated**_, a Retail Banking application using AWS services, specifically utilizing AWS CLI to automate the deployment process through Jenkins. The aim was to create a streamlined CI/CD pipeline that automatically builds, tests, and deploys the application, enhancing the efficiency and reliability of the deployment process.

## STEPS

**Create AWS Access Keys**
- **Why**: AWS Access Keys are necessary for programmatic access to AWS services. These keys allow Jenkins to interact with AWS services such as Elastic Beanstalk.
- **How:**
    1. Navigate to the AWS service: IAM (search for this in the AWS console)
    2. Click on "Users" on the left side navigation panel
    3. Click on your User Name
    4. Underneath the "Summary" section, click on the "Security credentials" tab
    5. Scroll down to "Access keys" and click on "Create access key"
    6. Select the appropriate "use case", and then click "Next" and then "Create access key"
  The Access and Secret Access keys are needed for future steps, so it's paramount they are stored somewhere safely.

### Set Up Security Groups
- **Why**: Security Groups ensure that the necessary ports are open for communication between EC2 instances and other services.
- **How**: I created a Security Group that allowed inbound traffic on Ports 22 (SSH), 8080 (Jenkins), and 8000 (Gunicorn), with all outbound traffic permitted.

### Launch EC2 Instances
- **Why**: EC2 instances are required to run Jenkins and host the application, providing the necessary computational resources.
- **How**: Deployed two EC2 instances: one for Jenkins and one for the Elastic Beanstalk environment.

### Install Jenkins
- **Why**: Jenkins automates the build and deployment pipeline. It pulls code from GitHub, tests it, and handles deployment. 
- **How**: I ran a script that installed Python 3.7, the deadsnakes repository, and Jenkins. I then logged into Jenkins and added the necessary plugins to integrate with GitHub and other tools. I then hooked my GitHub into Jenkins so that it could pull the source code from my repository. 

### Create `system_resources_test.sh` Script
- **Why**: The system resources script monitors the system resources on the Jenkins server, ensuring it operates within acceptable limits and preventing resource exhaustion.
- **How**: The `system_resources_test.sh` script checks CPU utilization, system memory and disk usage, ensuring their levels do not pass 80%, 90%, and 90%, respectively, and I included exit codes to indicate if those thresholds were exceeded. Error codes are crucial in automating responses to resource issues, helping to prevent failed builds or deployment processes.

### Configure Jenkins Pipeline
- **Why**: The Jenkins pipeline builds the application, tests it's logic to ensure no errors, in the automated version of the retail app, deploys the application automatically upon code changes.
- **How**: Created a Jenkinsfile that defines the stages for building, testing, and deploying the application.

### Install AWS CLI on EC2 Instance
- **Why**: AWS CLI allows for command-line interaction with AWS services, enabling automated deployment.
- **How**: I first changed to the jenkins user, then navigated to the Kura QuikBuks Auto workspace, acitvated the virtual environment that Jenkins created during the first build phase, and then Installed AWS CLI by downloading the installer, extracting it, and running the setup script.

### Configure AWS CLI
- **Why**: Proper configuration is needed to authenticate and interact with AWS services. This is where the Access and Secret Access Keys I wrote about earlier comes in!
- **How**: I used the `aws configure` command (while still masquerading as the Jenkins user) to set up credentials and default settings for AWS CLI.

### Deploy Using AWS CLI
- **Why**: Automating the deployment process ensures consistency and reduces manual errors. This allowed me to avoid a critical error that causes sleepless nights when deploying the previous iteration of Kura QuikBuks
- **How**: One AWS CLI command is eb init, which allowed me to deploy Kura QuikBuks Automated via the commandline, configure the environment parameters, and then automate the development via my Jenkinsfile. 

## SYSTEM DESIGN DIAGRAM

![Kura QuikBuks Auto System Diagram](https://github.com/user-attachments/assets/49fcc505-a956-43e4-b913-a01c4415fadc)

## ISSUES/TROUBLESHOOTING

### Invalid Parameter Value Error in Elastic Beanstalk
- **Problem**: I encountered an error with the environment name containing invalid characters. My initial name included underscores, which is not accepted for Elastic Beanstalk names. 
- **Solution**: I updated the environment name, swapping out the underscores with dashes. For Elastic Beanstalk, the environment name can only contain words, digits, and dashes, and cannot start or end with a dash. This will be important to keep in mind if you attempt to deploy your own flask application via these steps!

### Jenkinsfile Syntax Errors
**Problem:** The syntax I used when adding a 'Deploy' stage into my Jenkinsfile was incorrect, causing errors at the 'Deploy' stage when initiating a build in Jenkins.
**Solution:** I reviewed and corrected the syntax errors in the Jenkinsfile. This was my first time working with Groovy syntax, so my curly brackets were off when writing my scripting pipeline. After fixing the curly bracket placements and indents, I ensured I had my stages in the correct order (Checkout --> Build --> Test --> Deploy), and all was well.

### Error Running Commands as Different Users
- **Problem**: I ran into issues with running commands under different user accounts (e.g., jenkins vs. ubuntu). I was not able to install AWS CLI as the ubuntu user in the venv created by Jenkins during the build phase of my deployment. Activated the venv and installing AWS CLI there is a necessary step of the automated deployment pipeline.
- **Solution**: I used `sudo su -` to switch to the appropriate user (Jenkins in this case) for running commands and configuring AWS CLI.  

### AWS CLI Authentication Issues
- **Problem**: I received an "AuthFailure" error when trying to use AWS CLI commands as the Jenkins user. I needed to be the Jenkins user so I could install and configue Elastic Beanstalk in the workspace environment created by Jenkins, otherwise I would be unable to automate deployment.
- **Solution**: First, I ensured that AWS CLI was properly configured with valid credentials. When I realized the credentials I inputted were correct, I realized the credentials themselves were not valid for the third party application Jenkins. I then created a new Access keypair for Jenkins, ensuring the use case was Thrid Party Applications. This allowed me to run AWS CLI commands as the Jenkins user.

### Jenkins Testing Phase Failures Due to Memory Threshold
- **Problem**: Jenkins build process failed intermittently due to surpassing memory thresholds on the Jenkins server.
- **Solution**:
  - Killed the process `fwupd`, which is responsible for updating server firmware, as it was consuming the second most memory (13%) on the Jenkins server, after Jenkins itself.
  - Increased the memory threshold to 90% to prevent future build failures due to resource limits.

## OPTIMIZATION

### Efficiency of Using a Deploy Stage in CI/CD Pipeline

- **How it Increases Efficiency**: Automating the deployment process through Jenkins and AWS CLI streamlines the deployment pipeline, significantly reducing manual intervention. This automation leads to faster deployment cycles, ensuring that updates to the Kura QuikBuks Automated application are delivered more rapidly and reliably. For the retail banking sector, this means quicker updates to features, bug fixes, and security patches, which are critical for maintaining competitiveness and compliance. Automated deployments also reduce the risk of human error, leading to more stable and predictable releases.

- **Business Benefits**:
  - **Enhanced Agility**: With automated deployments, the ability to adapt to market changes and regulatory requirements is improved, enabling quicker responses to emerging trends and customer needs.
  - **Increased Reliability**: Automation ensures consistency in deployment processes, minimizing the risk of configuration drift and deployment failures, which is crucial for maintaining high availability and performance in financial applications.
  - **Compliance and Security**: Automated pipelines can be configured to include security checks and compliance validations, ensuring that deployments adhere to industry standards and regulations, which is essential for the banking sector.

### Potential Issues with Automation

- **Misconfigurations in Deployment Scripts**: Automated deployment scripts can sometimes be misconfigured, leading to failed deployments or application downtime. Ensuring that scripts are thoroughly tested and reviewed before use can mitigate this risk.
- **Credential Management**: Managing AWS credentials and access keys is critical to avoid security breaches. Proper handling and rotation of these credentials are necessary to maintain security and prevent unauthorized access.
- **Dependency Management**: Automating deployments requires managing dependencies effectively. Inconsistent or outdated dependencies can lead to application failures. Using version control and dependency management tools helps keep dependencies up-to-date and consistent.

### Mitigation Strategies

- **Regularly Update and Test Deployment Scripts**: Continuously review and test deployment scripts to ensure they are accurate and functioning as expected. Implement automated tests for deployment scripts to catch issues early.
- **Use Version Control for Deployment Configurations**: Maintain version control for deployment configurations and scripts to track changes and ensure that the correct versions are used during deployments.
- **Implement Monitoring and Alerting**: Set up monitoring and alerting systems (such as my system resources script with exit codes) to quickly detect and respond to issues during and after deployments. This helps to identify problems before they impact end-users and enables rapid remediation.
- **Secure Credential Management**: Implement robust practices for managing AWS credentials, such as using IAM roles with appropriate permissions, rotating access keys regularly, and employing encryption for sensitive information.
- **Automate Compliance Checks**: Incorporate automated compliance and security checks into the CI/CD pipeline to ensure that each deployment meets regulatory requirements and security standards, reducing the risk of non-compliance and vulnerabilities.
- **Scalable Deployment Strategies**: Design the deployment pipeline to handle scaling efficiently, considering the high volume of transactions and user interactions typical in banking applications. Use AWS features like Elastic Load Balancing and Auto Scaling to manage traffic and ensure high availability.

## CONCLUSION
Deploying the Retail Banking application using AWS CLI and Jenkins demonstrated the power of automation in modern development workflows. The integration of Jenkins for CI/CD and AWS services for deployment streamlined the process, improved efficiency, and reduced the risk of human error. Despite encountering challenges with configuration, system resources, and authorization management, the project provided valuable insights into cloud-based deployments and automation. Future optimizations will focus on refining deployment strategies and addressing any emerging issues to maintain a robust CI/CD pipeline.

## Documentation

**Jenkins server resource test Log**

![image](https://github.com/user-attachments/assets/a4a9b45d-b20c-4111-b601-2228b7d061a5)

**Jenkins successful scan log**

![image](https://github.com/user-attachments/assets/3430581c-101d-4c6f-9b0c-5a0d42835e12)

**Jenkins Deployment Log**

![image](https://github.com/user-attachments/assets/32518b73-c527-443f-b65c-9f217c7d15cc)

**Jenkins Stage View**

![image](https://github.com/user-attachments/assets/92646f9f-ae1a-492a-95fd-158c5be08fa1)

**Jenkins Pipeline Graph**

![image](https://github.com/user-attachments/assets/b9b50e41-34f3-4280-99ba-0b13605bdb8b)

**Jenkins change log**

![image](https://github.com/user-attachments/assets/bd49c8e0-b9aa-466b-b7b7-2454587575ee)

**Elastic Beanstalk Event logs**

![image](https://github.com/user-attachments/assets/179ab14c-5e13-438d-8875-01a0312975eb)

**Kura QuikBuks Auto welcome page**

![image](https://github.com/user-attachments/assets/84a516bc-0493-4482-8d61-6531ff8b90f4)
