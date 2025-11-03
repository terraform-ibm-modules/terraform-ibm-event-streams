# Configuring complex inputs in Event Streams

Several optional input variables in the IBM Cloud [Event Streams deployable architecture](https://cloud.ibm.com/catalog/7df1e4ca-d54c-4fd0-82ce-3d13247308cd/architecture/deploy-arch-ibm-event-streams-8272d54f-b54f-46a6-8dd6-772c6db82e87) use complex object types. You specify these inputs when you configure you deployable architecture.

- [Resource keys](#resource-keys) (`resource_keys`)
- [Service credential secrets](#service-credential-secrets) (`service_credential_secrets`)

## Resource keys <a name="resource-keys"></a>
When you add an IBM Cloud Object Storage service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure resource keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the resource key, , the Role of the key and an optional endpoint.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the resource key configurations to the array here.

 [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) about resource keys.

- Variable name: `resource_keys`.
- Type: A list of objects that represent a resource key
- Default value: An empty list (`[]`)

### Options for resource_key

- `name` (required): A unique human-readable name that identifies this resource key.
- `role` (optional, default = `Reader`): The name of the user role.
- `endpoint` (optional, default = `public`): The endpoint of resource key.

The following example includes all the configuration options for two resource keys. One is with a `Reader` role with `Public` endpoint, the other with an IAM key with `Writer` role.
```hcl
[
  {
    "name": "cos-reader-resource-key",
    "role": "Reader",
    "endpoint": "public"
  },
  {
    "name": "cos-writer-resource-key",
    "role": "Writer"
  }
]
```

## Service credential secrets <a name="service-credential-secrets"></a>

When you add an IBM Event Streams deployable architecture from the IBM Cloud catalog to IBM Cloud Project, you can configure service credentials. In edit mode for the projects configuration, from the configure panel click the optional tab.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the service credential secrets configurations to the array here.

In the configuration, specify the secret group name, whether it already exists or will be created and include all the necessary service credential secrets that need to be created within that secret group.

 [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-getting-started#getting-started) about service credential secrets.

- Variable name: `service_credential_secrets`.
- Type: A list of objects that represent service credential secret groups and secrets
- Default value: An empty list (`[]`)

### Options for service_credential_secrets

- `secret_group_name` (required): A unique human-readable name that identifies this service credential secret group.
- `secret_group_description` (optional, default = `null`): A human-readable description for this secret group.
- `existing_secret_group`: (optional, default = `false`): Set to true, if secret group name provided in the variable `secret_group_name` already exists.
- `service_credentials`: (required): A list of object that represents a service credential secret.

#### Options for service_credentials

- `secret_name`: (required): A unique human-readable name of the secret to create.
- `service_credentials_source_service_role_crn`: (required): The CRN of the role to give the service credential in the IBM Cloud Database service. Service credentials role CRNs can be found at https://cloud.ibm.com/iam/roles, select the IBM Cloud Database and select the role.
- `secret_labels`: (optional, default = `[]`): Labels of the secret to create. Up to 30 labels can be created. Labels can be 2 - 30 characters, including spaces. Special characters that are not permitted include the angled brackets (<>), comma (,), colon (:), ampersand (&), and vertical pipe character (|).
- `secret_auto_rotation`: (optional, default = `true`): Whether to configure automatic rotation of service credential.
- `secret_auto_rotation_unit`: (optional, default = `day`): Specifies the unit of time for rotation of a secret. Acceptable values are `day` or `month`.
- `secret_auto_rotation_interval`: (optional, default = `89`): Specifies the rotation interval for the rotation unit.
- `service_credentials_ttl`: (optional, default = `7776000`): The time-to-live (TTL) to assign to generated service credentials (in seconds).
- `service_credential_secret_description`: (optional, default = `null`): Description of the secret to create.

The following example includes all the configuration options for four service credentials and two secret groups.
```hcl
[
{
    "secret_group_name": "sg-1"
    "existing_secret_group": true
    "service_credentials": [ #pragma: allowlist secret
    {
        "secret_name": "cred-1"
        "service_credentials_source_service_role_crn":  "crn:v1:bluemix:public:iam::::role:Writer"
        "secret_labels": ["test-writer-1", "test-writer-2"]
        "secret_auto_rotation": true
        "secret_auto_rotation_unit": "day"
        "secret_auto_rotation_interval": 89
        "service_credentials_ttl": 7776000
        "service_credential_secret_description": "sample description"
    },
    {
        "secret_name": "cred-2"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:Reader"
    }
    ]
},
{
    "secret_group_name": "sg-2"
    "service_credentials": [ #pragma: allowlist secret
    {
        "secret_name": "cred-3"
        "service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:Editor"
    }
    ]
}
]
```
