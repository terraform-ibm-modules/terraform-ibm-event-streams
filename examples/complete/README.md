# Complete example with topics and schema creation.

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that creates an IBM Event Streams for IBM Cloud instance.

This example uses the IBM Cloud Terraform provider to create the following infrastructure.

- A new resource group, if one is not passed in.
- A sample virtual private cloud (VPC).
- A instance of Event Streams in the provided resource group and region. You can identify topics and schemas to apply to the instance.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
