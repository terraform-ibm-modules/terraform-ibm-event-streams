# Complete example with topics and schema creation.

An end-to-end example that creates an event streams instance with key protect.
This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - Create a Key Protect instance and root key in the provided region.
 - Create a new event streams instance in the resource group and region provided along with configured topics and schemas.
