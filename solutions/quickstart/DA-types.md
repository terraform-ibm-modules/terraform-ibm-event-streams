# Configuring complex inputs in Event Streams

Several optional input variables in the IBM Cloud [Event Streams deployable architecture](https://cloud.ibm.com/catalog/7df1e4ca-d54c-4fd0-82ce-3d13247308cd/architecture/deploy-arch-ibm-event-streams-8272d54f-b54f-46a6-8dd6-772c6db82e87) use complex object types. You specify these inputs when you configure you deployable architecture.

- [Service credentials](#svc-credential-name) (`service_credential_names`)

## Service credentials <a name="svc-credential-name"></a>

You can specify a set of IAM credentials to connect to the instance with the `service_credential_names` input variable. Include a credential name and IAM service role for each key-value pair. Each role provides a specific level of access to the instance. For more information, see [Adding and viewing credentials](https://cloud.ibm.com/docs/account?topic=account-service_credentials&interface=ui).

- Variable name: `service_credential_names`.
- Type: A map. The key is the name of the service credential. The value is the role that is assigned to that credential.
- Default value: An empty map (`{}`).

### Options for service_credential_names

- Key (required): The name of the service credential.
- Value (required): The IAM service role that is assigned to the credential. The following values are valid for service credential roles: 'Manager', 'Writer', 'Reader'. For more information, see [IBM Cloud IAM roles](https://cloud.ibm.com/docs/account?topic=account-userroles).

### Example service credentials

```hcl
{
    "es_writer" : "Writer",
    "es_reader" : "Reader",
    "es_manager" : "Manager"
}
```
