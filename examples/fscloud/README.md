# Financial Services Cloud profile example

## *Note:* This example is only deploying Event Streams in a compliant manner the other infrastructure may not necessarily compliant.

### Requirements
This example expects you have Hyper Protect Crypto Service instances in the region you wish to deploy your Event Streams instance.

 ### Deploys
An end-to-end example that creates an event streams instance with key protect.
This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - Create a new event streams instance in the resource group and region provided, encrypted with the root key, and configured with topics and schemas.
