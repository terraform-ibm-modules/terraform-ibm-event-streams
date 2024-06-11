# Event Streams for IBM Cloud - Financial Services Cloud solution

This architecture creates an Enterprise plan instance of IBM Event Streams for IBM Cloud that is IBM Cloud Financial Services certified.

The solution provisions the following resources:

- A resource group, if one is not passed in.
- An Event Streams Enterprise plan instance, set up with KMS encryption to encrypt data.
- Topics to apply to resources. Only one topic is allowed for Lite plan instances.
- Schema definitions.
- Context-based restriction rules for the instance.

![da-fscloud](../../reference-architecture/da-fscloud.svg)

## Before you begin

You need the following prerequisites set up to deploy the Event Streams instance with this solution.

- An instance of Hyper Protect Crypto Services.
- A root key CRN of the Hyper Protect Crypto Services instance.
- An authorization policy to allow the Event Streams service to access the Hyper Protect Crypto Services instance with the reader role.  For more information, see [About KMS encryption](../../README.md#about-kms-encryption) in the main readme file.
