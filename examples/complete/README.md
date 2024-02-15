# Complete example with topics and schema creation.

An end-to-end example that creates an event streams instance.
This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - A sample virtual private cloud (VPC).
 - A context-based restriction (CBR) rule to only allow Event Streams to be accessible from within the VPC.
 - Create a new event streams instance in the resource group and region provided along with configured topics and schemas.
