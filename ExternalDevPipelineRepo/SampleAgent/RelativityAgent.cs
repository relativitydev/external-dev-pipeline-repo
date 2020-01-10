using kCura.Agent;
using Relativity.API;
using System;

namespace SampleAgent
{
	[kCura.Agent.CustomAttributes.Name("Agent Name")]
	[System.Runtime.InteropServices.Guid("311c5570-eeaa-4a38-b2d8-59f51cc2d093")]
	public class RelativityAgent : AgentBase
	{
		/// <summary>
		/// Agent logic goes here
		/// </summary>
		public override void Execute()
		{
			IAPILog logger = Helper.GetLoggerFactory().GetLogger();

			try
			{
				//Display a message in Agents Tab and Windows Event Viewer
				RaiseMessage("The current time is: " + DateTime.Now.ToLongTimeString(), 1);

				logger.LogVerbose("Sample agent execution complete.");
			}
			catch (Exception ex)
			{
				//Your Agent caught an exception
				logger.LogError(ex, "There was an exception.");
				RaiseError(ex.Message, ex.Message);
			}
		}

		/// <summary>
		/// Returns the name of agent
		/// </summary>
		public override string Name
		{
			get
			{
				return "Sample Agent";
			}
		}
	}
}