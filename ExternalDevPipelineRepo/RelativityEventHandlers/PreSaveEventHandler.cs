﻿using System;
using System.Net;
using System.Runtime.InteropServices;
using kCura.EventHandler;
using kCura.EventHandler.CustomAttributes;
using kCura.Relativity.Client;
using Relativity.API;
using Relativity.Services.Objects;

namespace RelativityEventHandlers
{
	[kCura.EventHandler.CustomAttributes.Description("Pre Save EventHandler")]
	[System.Runtime.InteropServices.Guid("41e8ee23-c324-49af-843e-32d1c75a71ce")]
	public class PreSaveEventHandler : kCura.EventHandler.PreSaveEventHandler
	{
		public override Response Execute()
		{
			// Update Security Protocol
			ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;

			//Construct a response object with default values.
			kCura.EventHandler.Response retVal = new kCura.EventHandler.Response();
			retVal.Success = true;
			retVal.Message = string.Empty;
			try
			{
				retVal.Message = "Success!";
			}
			catch (Exception ex)
			{
				//Change the response Success property to false to let the user know an error occurred
				retVal.Success = false;
				retVal.Message = ex.ToString();
			}

			return retVal;
		}

		/// <summary>
		///     The RequiredFields property tells Relativity that your event handler needs to have access to specific fields that
		///     you return in this collection property
		///     regardless if they are on the current layout or not. These fields will be returned in the ActiveArtifact.Fields
		///     collection just like other fields that are on
		///     the current layout when the event handler is executed.
		/// </summary>
		public override FieldCollection RequiredFields
		{
			get
			{
				kCura.EventHandler.FieldCollection retVal = new kCura.EventHandler.FieldCollection();
				return retVal;
			}
		}
	}
}