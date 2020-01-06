using System;
using System.IO;
using System.Net;
using System.Reflection;
using kCura.Relativity.Client;
using NUnit.Framework;
using Relativity.API;
using Relativity.Test.Helpers;
using Relativity.Test.Helpers.ArtifactHelpers;
using Relativity.Test.Helpers.ServiceFactory.Extentions;
using Relativity.Test.Helpers.SharedTestHelpers;
using Relativity.Test.Helpers.WorkspaceHelpers;

namespace ExternalDevPipelineRepo
{
	[TestFixture]
	[Description("Sample Tests")]
	public class TestTemplate
	{
		private IRSAPIClient _client;
		private int _workspaceId;
		private readonly string _workspaceName = "IntTest_" + Guid.NewGuid();
		private IServicesMgr _servicesManager;
		private int _fixedLengthArtId;
		private int _longTextArtId;
		private int _wholeNumberArtId;

		[OneTimeSetUp]
		public void Execute_TestFixtureSetup()
		{
			// Update Security Protocol
			ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

			//Setup for testing
			TestHelper helper = new TestHelper(TestContext.CurrentContext);
			_servicesManager = helper.GetServicesManager();

			// implement_IHelper
			//create client
			_client = helper.GetServicesManager().GetProxy<IRSAPIClient>(ConfigurationHelper.ADMIN_USERNAME, ConfigurationHelper.DEFAULT_PASSWORD);


			//Create workspace
			_workspaceId = CreateWorkspace.CreateWorkspaceAsync(_workspaceName, ConfigurationHelper.TEST_WORKSPACE_TEMPLATE_NAME, _servicesManager, ConfigurationHelper.ADMIN_USERNAME, ConfigurationHelper.DEFAULT_PASSWORD).Result;
			_client.APIOptions.WorkspaceID = _workspaceId;
		}

		[OneTimeTearDown]
		public void Execute_TestFixtureTeardown()
		{
			//Delete Workspace
			DeleteWorkspace.DeleteTestWorkspace(_workspaceId, _servicesManager, ConfigurationHelper.ADMIN_USERNAME, ConfigurationHelper.DEFAULT_PASSWORD);
		}

		[Test]
		[Description("Create Fields and Confirm they were created")]
		public void Integration_Test_Golden_Flow_Valid()
		{
			// Arrange / Act
			_fixedLengthArtId = Fields.CreateField_FixedLengthText(_client, _workspaceId);
			_longTextArtId = Fields.CreateField_LongText(_client, _workspaceId);
			_wholeNumberArtId = Fields.CreateField_WholeNumber(_client, _workspaceId);

			//Assert
			Assert.IsTrue(_fixedLengthArtId > 0);
			Assert.IsTrue(_longTextArtId > 0);
			Assert.IsTrue(_wholeNumberArtId == 0); // Change back to > 0
		}
	}
}