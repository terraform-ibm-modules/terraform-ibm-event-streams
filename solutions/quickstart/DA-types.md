# Configuring complex inputs in Event Streams

Several optional input variables in the IBM Cloud [Event Streams deployable architecture](https://cloud.ibm.com/catalog/7df1e4ca-d54c-4fd0-82ce-3d13247308cd/architecture/deploy-arch-ibm-event-streams-8272d54f-b54f-46a6-8dd6-772c6db82e87) use complex object types. You specify these inputs when you configure you deployable architecture.

- [Service credentials](#svc-credential-name) (`service_credential_names`)
- [Service credential secrets](#service-credential-secrets) (`service_credential_secrets`)

## Service credentials <a name="svc-credential-name"></a>

You can specify a set of IAM credentials to connect to the instance with the `service_credential_names` input variable. Include a credential name and IAM service role for each key-value pair. Each role provides a specific level of access to the instance. For more information, see [Adding and viewing credentials](https://cloud.ibm.com/docs/account?topic=account-service_credentials&interface=ui).

If you want to add service credentials to secret manager and to allow secret manager to manage it, you should use `service_credential_secrets` , see [Service credential secrets](#service-credential-secrets)

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
