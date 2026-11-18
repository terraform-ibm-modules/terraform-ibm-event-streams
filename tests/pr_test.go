// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const quickstartTerraformDir = "solutions/quickstart"
const fsCloudTerraformDir = "examples/fscloud"
const securityEnforcedDir = "solutions/security-enforced"
const securityEnforcedGen2Dir = "solutions/security-enforced-gen2"
const fullyConfigurableGen2Dir = "solutions/fully-configurable-gen2"
const terraformVersion = "terraform_v1.12.2" // This should match the version in the ibm_catalog.json

// Use existing group for tests
const resourceGroup = "geretain-test-event-streams"

// Set up tests to only use supported BYOK regions
const regionSelectionPath = "../common-dev-assets/common-go-assets/icd-region-prefs.yaml"

const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// setup gen2schematic tests
const gen2WorkspaceLocation = "us"

var sharedInfoSvc *cloudinfo.CloudInfoService

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	sharedInfoSvc, err = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	if err != nil {
		log.Fatal(err)
	}
	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       dir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		BestRegionYAMLPath: regionSelectionPath,
	})
	return options
}

func setupQuickstartOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		Prefix:             prefix,
		BestRegionYAMLPath: regionSelectionPath,
		TarIncludePatterns: []string{
			"*.tf",
			quickstartTerraformDir + "/*.tf",
		},
		TemplateFolder:         quickstartTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
		TerraformVersion:       terraformVersion,
	})
	serviceCredentialSecrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-config-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:ConfigReader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Reader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-key-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:resource-controller::::role:KeyManager",
				},
			},
		},
	}
	resourceKeys := []map[string]interface{}{
		{
			"name": "es_writer",
			"role": "Writer",
		},
		{
			"name": "es_reader",
			"role": "Reader",
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "provider_visibility", Value: "private", DataType: "string"},
		{Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		// Update the create timeout as it can take longer than the default (3 hours) when running multiple tests in parallel
		{Name: "create_timeout", Value: "6h", DataType: "string"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: serviceCredentialSecrets, DataType: "list(object)"},
		{Name: "resource_keys", Value: resourceKeys, DataType: "list(object)"},
	}
	return options
}

// Test for the Quickstart DA
func TestRunQuickstartSchematics(t *testing.T) {
	t.Parallel()

	options := setupQuickstartOptions(t, "es-qs")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// Upgrade test for the Quickstart DA
func TestRunQuickstartUpgradeSchematics(t *testing.T) {
	t.Parallel()

	options := setupQuickstartOptions(t, "es-qs-upg")
	options.CheckApplyResultForUpgrade = true

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func setupGen2SchematicOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	agentResourceGroup := permanentResources["schematics_agent_resource_group"].(string)
	resourceGroupID, err := sharedInfoSvc.GetResourceGroupIDByName(agentResourceGroup)
	require.NoError(t, err, "Failed to get the ID of resource group %s", agentResourceGroup)

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:           t,
		Prefix:            prefix,
		WorkspaceLocation: gen2WorkspaceLocation,
		ResourceGroup:     resourceGroupID,
		TarIncludePatterns: []string{
			"*.tf",
			completeExampleTerraformDir + "/*.tf",
		},
		TemplateFolder:         completeExampleTerraformDir,
		Tags:                   []string{"test-schematic", permanentResources["schematics_agent_workspace_tag"].(string)},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
		TerraformVersion:       terraformVersion,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "plan", Value: "enterprise-gen2", DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
		{Name: "vpe_vpc_id", Value: permanentResources["schematics_agent_vpc_id"], DataType: "string"},
		{Name: "vpe_subnet_id", Value: permanentResources["schematics_agent_vpe_subnet_id"], DataType: "string"},
		{Name: "vpe_security_group_id", Value: permanentResources["schematics_agent_vpe_security_group_id"], DataType: "string"},
		{Name: "resource_group", Value: agentResourceGroup, DataType: "string"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
	}
	return options
}

// TestRunGen2CompleteSchematics tests provisioning of the complete example with enterprise-gen2 plan
// via Schematics, including topic creation.
func TestRunGen2CompleteSchematics(t *testing.T) {
	t.Parallel()

	options := setupGen2SchematicOptions(t, "es-gen2-sch")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func setupSecurityEnforcedUpgradeOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		Prefix:             prefix,
		BestRegionYAMLPath: regionSelectionPath,
		TarIncludePatterns: []string{
			"*.tf",
			securityEnforcedDir + "/*.tf",
		},
		TemplateFolder:         securityEnforcedDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
		TerraformVersion:       terraformVersion,
	})
	serviceCredentialSecrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-config-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::role:ConfigReader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Reader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-key-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:resource-controller::::role:KeyManager",
				},
			},
		},
	}

	mirroring := map[string]interface{}{
		"source_crn":   permanentResources["event_streams_us_south_crn"].(string),
		"source_alias": "source-alias",
		"target_alias": "target-alias",
		"options": map[string]interface{}{
			"topic_name_transform": map[string]interface{}{
				"type": "rename",
				"rename": map[string]interface{}{
					"add_prefix":    "add_prefix",
					"add_suffix":    "add_suffix",
					"remove_prefix": "remove_prefix",
					"remove_suffix": "remove_suffix",
				},
			},
			"group_id_transform": map[string]interface{}{
				"type": "rename",
				"rename": map[string]interface{}{
					"add_prefix":    "add_prefix",
					"add_suffix":    "add_suffix",
					"remove_prefix": "remove_prefix",
					"remove_suffix": "remove_suffix",
				},
			},
		},
	}

	resourceKeys := []map[string]interface{}{
		{
			"name":     "es_writer",
			"role":     "Writer",
			"endpoint": "private",
		},
		{
			"name":     "es_reader",
			"role":     "Reader",
			"endpoint": "private",
		},
	}

	schemas := []map[string]interface{}{
		{
			"schema_id": "order-created",
			"schema": map[string]interface{}{
				"type": "record",
				"name": "OrderCreated",
				"fields": []map[string]interface{}{
					{
						"name": "orderId",
						"type": "string",
					},
				},
			},
		},
		{
			"schema_id": "customer-created",
			"schema": map[string]interface{}{
				"type": "record",
				"name": "CustomerCreated",
				"fields": []map[string]interface{}{
					{
						"name": "customerId",
						"type": "string",
					},
				},
			},
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "existing_resource_group_name", Value: "Default", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["kp_dedicated_us_south_crn"], DataType: "string"},
		{Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "create_timeout", Value: "6h", DataType: "string"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: serviceCredentialSecrets, DataType: "list(object)"},
		{Name: "resource_keys", Value: resourceKeys, DataType: "list(object)"},
		{Name: "metrics", Value: []string{"topic", "partition", "consumers"}, DataType: "list(string)"},
		{Name: "schema_global_rule", Value: "FORWARD", DataType: "string"},
		{Name: "mirroring_topic_patterns", Value: []string{"topic-1", "topic-2"}, DataType: "list(string)"},
		{Name: "mirroring", Value: mirroring, DataType: "object"},
		{Name: "schemas", Value: schemas, DataType: "list(object)"},
	}
	return options
}

// Upgrade test for the SecurityEnforced DA
func TestSecurityEnforcedUpgradeSchematics(t *testing.T) {
	t.Parallel()

	options := setupSecurityEnforcedUpgradeOptions(t, "es-sen-upg")
	options.CheckApplyResultForUpgrade = true

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func setupSecurityEnforcedGen2Options(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	agentResourceGroup := permanentResources["schematics_agent_resource_group"].(string)
	resourceGroupID, err := sharedInfoSvc.GetResourceGroupIDByName(agentResourceGroup)
	require.NoError(t, err, "Failed to get the ID of resource group %s", agentResourceGroup)

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:           t,
		Prefix:            prefix,
		WorkspaceLocation: gen2WorkspaceLocation,
		ResourceGroup:     resourceGroupID,
		TarIncludePatterns: []string{
			"*.tf",
			securityEnforcedGen2Dir + "/*.tf",
		},
		TemplateFolder:         securityEnforcedGen2Dir,
		Tags:                   []string{"test-schematic", permanentResources["schematics_agent_workspace_tag"].(string)},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
		TerraformVersion:       terraformVersion,
	})

	serviceCredentialSecrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Reader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
				},
			},
		},
	}

	resourceKeys := []map[string]interface{}{
		{
			"name":     "es_writer",
			"role":     "Writer",
			"endpoint": "private",
		},
		{
			"name":     "es_reader",
			"role":     "Reader",
			"endpoint": "private",
		},
	}

	topics := []map[string]interface{}{
		{
			"name":       "topic-1",
			"partitions": 1,
			"config": map[string]string{
				"cleanup.policy":  "delete",
				"retention.ms":    "86400000",
				"retention.bytes": "10485760",
				"segment.bytes":   "10485760",
			},
		},
		{
			"name":       "topic-2",
			"partitions": 1,
			"config": map[string]string{
				"cleanup.policy":  "compact,delete",
				"retention.ms":    "86400000",
				"retention.bytes": "1073741824",
				"segment.bytes":   "536870912",
			},
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "existing_resource_group_name", Value: agentResourceGroup, DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["kp_dedicated_us_south_crn"], DataType: "string"},
		{Name: "vpe_vpc_id", Value: permanentResources["schematics_agent_vpc_id"], DataType: "string"},
		{Name: "vpe_subnet_ids", Value: []string{permanentResources["schematics_agent_vpe_subnet_id"].(string)}, DataType: "list(string)"},
		{Name: "vpe_security_group_ids", Value: []string{permanentResources["schematics_agent_vpe_security_group_id"].(string)}, DataType: "list(string)"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "resource_keys", Value: resourceKeys, DataType: "list(object)"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: serviceCredentialSecrets, DataType: "list(object)"},
		{Name: "topics", Value: topics, DataType: "list(object)"},
		{Name: "iam_token_only", Value: true, DataType: "bool"},
		{Name: "storage_size", Value: 2000, DataType: "number"},
		{Name: "throughput", Value: 100, DataType: "number"},
		{Name: "create_timeout", Value: "1h", DataType: "string"},
	}
	return options
}

// TestSecurityEnforcedGen2Schematics tests provisioning of the security-enforced-gen2 DA
func TestSecurityEnforcedGen2Schematics(t *testing.T) {
	t.Parallel()

	options := setupSecurityEnforcedGen2Options(t, "es-sen-gen2")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func setupFullyConfigurableGen2Options(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	agentResourceGroup := permanentResources["schematics_agent_resource_group"].(string)
	resourceGroupID, err := sharedInfoSvc.GetResourceGroupIDByName(agentResourceGroup)
	require.NoError(t, err, "Failed to get the ID of resource group %s", agentResourceGroup)

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:           t,
		Prefix:            prefix,
		WorkspaceLocation: gen2WorkspaceLocation,
		ResourceGroup:     resourceGroupID,
		TarIncludePatterns: []string{
			"*.tf",
			fullyConfigurableGen2Dir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableGen2Dir,
		Tags:                   []string{"test-schematic", permanentResources["schematics_agent_workspace_tag"].(string)},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
		TerraformVersion:       terraformVersion,
	})

	serviceCredentialSecrets := []map[string]interface{}{
		{
			"secret_group_name": fmt.Sprintf("%s-secret-group", options.Prefix),
			"service_credentials": []map[string]string{
				{
					"secret_name": fmt.Sprintf("%s-cred-reader", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Reader",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-writer", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Writer",
				},
				{
					"secret_name": fmt.Sprintf("%s-cred-manager", options.Prefix),
					"service_credentials_source_service_role_crn": "crn:v1:bluemix:public:iam::::serviceRole:Manager",
				},
			},
		},
	}

	resourceKeys := []map[string]interface{}{
		{
			"name":     "es_writer",
			"role":     "Writer",
			"endpoint": "private",
		},
		{
			"name":     "es_reader",
			"role":     "Reader",
			"endpoint": "private",
		},
	}

	topics := []map[string]interface{}{
		{
			"name":       "topic-1",
			"partitions": 1,
			"config": map[string]string{
				"cleanup.policy":  "delete",
				"retention.ms":    "86400000",
				"retention.bytes": "10485760",
				"segment.bytes":   "10485760",
			},
		},
		{
			"name":       "topic-2",
			"partitions": 1,
			"config": map[string]string{
				"cleanup.policy":  "compact,delete",
				"retention.ms":    "86400000",
				"retention.bytes": "1073741824",
				"segment.bytes":   "536870912",
			},
		},
	}

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "existing_resource_group_name", Value: agentResourceGroup, DataType: "string"},
		{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["kp_dedicated_us_south_crn"], DataType: "string"},
		{Name: "vpe_vpc_id", Value: permanentResources["schematics_agent_vpc_id"], DataType: "string"},
		{Name: "vpe_subnet_ids", Value: []string{permanentResources["schematics_agent_vpe_subnet_id"].(string)}, DataType: "list(string)"},
		{Name: "vpe_security_group_ids", Value: []string{permanentResources["schematics_agent_vpe_security_group_id"].(string)}, DataType: "list(string)"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "resource_keys", Value: resourceKeys, DataType: "list(object)"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: serviceCredentialSecrets, DataType: "list(object)"},
		{Name: "topics", Value: topics, DataType: "list(object)"},
		{Name: "iam_token_only", Value: true, DataType: "bool"},
		{Name: "storage_size", Value: 2000, DataType: "number"},
		{Name: "throughput", Value: 100, DataType: "number"},
		{Name: "create_timeout", Value: "1h", DataType: "string"},
	}
	return options
}

// TestFullyConfigurableGen2Schematics tests provisioning of the fully-configurable-gen2 DA
func TestFullyConfigurableGen2Schematics(t *testing.T) {
	t.Parallel()

	options := setupFullyConfigurableGen2Options(t, "es-fc-gen2")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
