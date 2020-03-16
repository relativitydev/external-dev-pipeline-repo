[![Build Status](https://dev.azure.com/aarongilbert/ExternalDevPipeline/_apis/build/status/relativitydev.external-dev-pipeline-repo?branchName=master)](https://dev.azure.com/aarongilbert/ExternalDevPipeline/_build/latest?definitionId=5&branchName=master)

# external-dev-pipeline-repo

This is Documentation to help you get started with creating your own CI/CD pipeline for testing and building Relativity Applications!

## What is Azure Pipelines?
- Azure Pipelines is a cloud service that you can use to automatically build and test your code project and make it available to other users. It works with just about any language or project type.
- Azure Pipelines combines continuous integration (CI) and continuous delivery (CD) to constantly and consistently test and build your code and ship it to any target.

### Does Azure Pipelines work with my language and tools?
#### Languages
You can use many languages with Azure Pipelines, such as Python, Java, JavaScript, PHP, Ruby, C#, C++, and Go.
#### Version control systems
Before you use continuous integration and continuous delivery practices for your applications, you must have your source code in a version control system. Azure Pipelines integrates with GitHub, GitHub Enterprise, Azure Repos Git & TFVC, Bitbucket Cloud, and Subversion.
#### Application types
You can use Azure Pipelines with most application types, such as Java, JavaScript, Node.js, Python, .NET, C++, Go, PHP, and XCode.
#### Deployment targets
Use Azure Pipelines to deploy your code to multiple targets. Targets include container registries, virtual machines, Azure services, or any on-premises or cloud target.
#### Package formats
To produce packages that can be consumed by others, you can publish NuGet, npm, or Maven packages to the built-in package management repository in Azure Pipelines. You also can use any other package management repository of your choice.

### What do I need to use Azure Pipelines?
To use Azure Pipelines, you need:
- An organization in Azure DevOps.
- To have your source code stored in a version control system

## How to use Azure Pipelines
You define your pipeline mostly in code in a YAML file alongside the rest of the code for your app.
- The pipeline is versioned with your code and follows the same branching structure. You get validation of your changes through code reviews in pull requests and branch build policies.
- Every branch you use can modify the build policy by modifying the azure-pipelines.yml file.
- A change to the build process might cause a break or result in an unexpected outcome. Because the change is in version control with the rest of your codebase, you can more easily identify the issue.

The basic steps are these:
1. Configure Azure Pipelines to use your Git repo.
2. Edit your azure-pipelines.yml file to define your build.
3. Push your code to your version control repository. This action kicks off the default trigger to build and deploy and then monitor the results.
4. Your code is now updated, built, tested, and packaged. It can be deployed to any target.

For more info: https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops

## Create your pipeline
### Prerequisites
- A GitHub account, where you can create a repository. If you don't have one, you can create one for free.
- An Azure DevOps organization. If you don't have one, you can create one for free. (An Azure DevOps organization is different from your GitHub organization. Give them the same name if you want alignment between them.) If your team already has one, then make sure you're an administrator of the Azure DevOps project that you want to use.
### Setup your first *azure-pipelines.yml* file
1. Sign in to your Azure DevOps organization and navigate to your project.
2. In your project, navigate to the Pipelines page. Then choose the action to create a new pipeline.
3. Walk through the steps of the wizard by first selecting GitHub as the location of your source code.
4. You might be redirected to GitHub to sign in. If so, enter your GitHub credentials.
5. When the list of repositories appears, select your desired sample app repository.
6. Azure Pipelines will analyze your repository and choose the ASP.NET pipeline template. Select Save, then select Create a new branch for this commit with the branch name azure-pipelines. Uncheck Start a pull request. **NOTE**: This will be the branch that you will continue to work off of.
### Understand the *azure-pipelines.yml* file
A pipeline is defined using a YAML file in your repo. Usually, this file is named azure-pipelines.yml and is located at the root of your repo.
- Navigate to the Pipelines page in Azure Pipelines and select the pipeline you created.
- Select Edit in the context menu of the pipeline to open the YAML editor for the pipeline. Examine the contents of the YAML file.
![](images/understandYaml.png)
This pipeline runs whenever your team pushes a change to the master branch of your repo. This pipeline restores the NuGet packages for the solution, builds the solution, and then runs the tests for the solution.

For more info: https://docs.microsoft.com/en-us/azure/devops/pipelines/customize-pipeline?view=azure-devops

## Customize Azure Pipelines to be a Relativity Rap File CI/CD
You can add additional scripts or tasks as steps to your pipeline. A task is a pre-packaged script. You can use tasks for building, testing, publishing, or deploying your app.

A list of tasks you can add to your pipeline can be found here: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/?view=azure-devops .

**NOTE**: For the full example .yml file you can view the azure-pipelines.yml file in this repository.

We're going to walk through some common tasks that we believe a solid CI/CD pipeline for Relativity RAP files should have. The tasks which we have created are:

- Create New Variable Groups
- Create New Azure Key Vault Variable Group
- Restore NuGet Packages
- Build Repository
- Run Unit Tests
- Run Integration Tests
- Run Rap Builder to create Rap File
- Publish Rap File to Azure Pipelines
- Create a Release Pipeline to Push the created Rap file to the Solution Snapshot Website.

**NOTE**: that you may use any combination of these tasks which make sense for your development needs.
You can copy the code which we show or add tasks manually using the built in Tasks explorer, seen here when editing your pipeline:

![](images/tasksView.png)

Make sure that when you are editing the azure-pipelines.yml file that you are on the azure-pipelines branch:

![](images/azurePipelinesBranchView.png)

### New Variable Group
One of the first things we want to do is set up a Variable group. To do this click on your pipeline and select the Library tab.

![](images/newVariableGroup/newVariableGroup1.png)

On this page, click *+ Variable Group*.

![](images/newVariableGroup/newVariableGroup2.png)

As you can see below we have created 4 varaibles:
- *applicationGuid* - This is the Guid of our Relativity Application
- *buildVersion* - The current master version of the Relativity Application. 
- *salesforceUsername* - Your community account username
- *salesforcePassword* - Your community account password

**NOTE**: *applicationGuid*, *salesforceUsername*, and *salesforcePassword* will only be used if you would like to Upload a created RAP file to the Solution Snapshot Website.

![](images/newVariableGroup/newVariableGroup3.png)

Next you want to link this Variable Group to your pipeline. In the Pipelines tab click on your pipeline and then click the *Edit* button.

![](images/newVariableGroup/newVariableGroup4.png)

Click the three dot dropdown and select *Triggers*.

![](images/newVariableGroup/newVariableGroup5.png)

Click the *Variables* tab, then *Variable Groups* and select *Link variable group*. Next, select the Variable Group that we created.

![](images/newVariableGroup/newVariableGroup6.png)
![](images/newVariableGroup/newVariableGroup7.png)

Lastly, remember to Save.

![](images/newVariableGroup/newVariableGroup8.png)

### New Azure Key Vault Variable Group
Adding Azure Key Vault Secrets to a Variable Group is very similar to adding a variable group. 
- Instead of adding in every secret manually, you can choose the *Link secrets from an Azure key vault* as variables option.
- Next, you specify the Azure subscription where the key vault you want to use has been created and select the Key vault name.
- You may have to authorize your azure pipeline to access your subscription and key vault 
- Now when you add variables you can choose which key vault secrets you would like to include as variables in the variable group
- After adding the variables, save and make sure you link the variable group to your pipeline like how we did above.

![](images/newKeyVaultVariableGroup.png)
