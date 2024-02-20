# Event Streams for IBM Cloud - Financial Services Cloud solution

This architecture creates an Event Streams for IBM Cloud Enterprise plan instance which is IBM Cloud® Financial Services certified. The solution supports provisioning the following resources:

- (Optional) A resource group
- An Event Streams for IBM Cloud Enterprise plan instance, set up with KMS encryption to encrypt data.
- (Optional) Topics
- (Optional) Schemas
- Context Based Restriction rules for the instance

![da-fscloud](../../reference-architecture/da-fscloud.svg)

## Before you begin

To deploy your Event Streams instance you need:
- Hyper Protect Crypto Services instance,
- root key CRN of a Hyper Protect Crypto Services instance and
- configure an authorization policy to allow the Event Streams service to access the Hyper Protect Crypto Services instance.
