using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using kCura.EventHandler;
using NUnit.Framework;
using PreSaveEventHandler = RelativityEventHandlers.PreSaveEventHandler;

namespace UnitTests
{
	[TestFixture]
	public class PreSaveEventHandlerUnitTests
	{
		private PreSaveEventHandler preSaveEventHandler;
		[SetUp]
		public void SetUp()
		{
			preSaveEventHandler = new PreSaveEventHandler();
		}

		[TearDown]
		public void TearDown()
		{
			preSaveEventHandler = null;
		}

		[Test]
		public void SampleUnitTest1()
		{
			// Arrange / Act
			Response response = preSaveEventHandler.Execute();

			// Assert
			Assert.AreEqual("Success!", response.Message);
		}
	}
}
