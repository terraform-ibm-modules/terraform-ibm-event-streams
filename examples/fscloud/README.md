 # Financial Services Cloud profile example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-fscloud-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/fscloud"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/modules/fscloud) to deploy an instance of Event Streams.

The example uses the IBM Cloud Terraform provider to create the following infrastructure:

- A resource group, if one is not passed in.
- An IAM authorization between all Event Stream instances in the given resource group and the Hyper Protect Crypto Services instance that is passed in.
- An Event Streams instance that is encrypted with the Hyper Protect Crypto Services root key that is passed in.
- A sample virtual private cloud (VPC).
- A context-based restriction (CBR) rule to only allow Event Streams to be accessible from within the VPC and Schematics.

:exclamation: **Important:** In this example, only the Event Streams instance complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

- You need a Hyper Protect Crypto Services instance and root key available in the region that you want to deploy your Event Streams instance to.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
