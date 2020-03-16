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

## Create your pipeline
Prerequisites
- A GitHub account, where you can create a repository. If you don't have one, you can create one for free.
- An Azure DevOps organization. If you don't have one, you can create one for free. (An Azure DevOps organization is different from your GitHub organization. Give them the same name if you want alignment between them.) If your team already has one, then make sure you're an administrator of the Azure DevOps project that you want to use.
