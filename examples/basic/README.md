# Basic example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=event-streams-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-event-streams/tree/main/examples/basic">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that creates an IBM Event Streams for IBM Cloud instance.

This example uses the IBM Cloud Terraform provider to create the following infrastructure.

- A new resource group, if one is not passed in.
- A Lite plan instance of Event Streams in the provided resource group and region.
