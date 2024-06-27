# Event Streams on IBM Cloud

This architecture creates an instance of IBM Event Streams for IBM Cloud.

The solution provisions the following resources:

- A resource group, if one is not passed in.
- An Event Streams instance using `lite` or `standard` plan.
- Topics to apply to resources. Only one topic is allowed for `lite` plan instances.

![da-quickstart](../../reference-architecture/da-quickstart.svg)
