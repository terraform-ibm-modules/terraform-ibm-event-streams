// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go

package test

import (
	"fmt"
	"testing"
	/*	"encoding/json" */

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const basicExampleTerraformDir = "examples/basic"
const securityEnforcedTerraformDir = "solutions/security-enforced"

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "event-streams-bsc", basicExampleTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "event-streams-bsc", completeExampleTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestFSCloudInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		Prefix:             "es-fscloud",
		BestRegionYAMLPath: regionSelectionPath,
		TarIncludePatterns: []string{
			"*.tf",
			fsCloudTerraformDir + "/*.tf",
			"modules/fscloud/*.tf",
		},
		/*
			Comment out the 'ResourceGroup' input to force this tests to create a unique resource group to ensure tests do
			not clash. This is due to the fact that an auth policy may already exist in this resource group since we are
			re-using a permanent HPCS instance and a permanent Event Streams instance. By using a new resource group, the auth policy will not already exist
			since this module scopes auth policies by resource group.
		*/
		//ResourceGroup:      resourceGroup,
		TemplateFolder:         fsCloudTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 420,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"].(string), DataType: "string"},
		{Name: "event_streams_source_crn", Value: permanentResources["event_streams_us_south_crn"].(string), DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func setupSecurityEnforcedOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		Prefix:             prefix,
		BestRegionYAMLPath: regionSelectionPath,
		TarIncludePatterns: []string{
			"*.tf",
			securityEnforcedTerraformDir + "/*.tf",
		},
		TemplateFolder:         securityEnforcedTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
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
	quotas := []map[string]interface{}{
		{
			"entity":             "iam-ServiceId-00000000-0000-0000-0000-000000000000",
			"producer_byte_rate": 100000,
			"consumer_byte_rate": 200000,
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

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: "us-south", DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "provider_visibility", Value: "private", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "event_stream_instance_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "event_stream_instance_resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "create_timeout", Value: "6h", DataType: "string"},
		{Name: "existing_secrets_manager_instance_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "service_credential_secrets", Value: serviceCredentialSecrets, DataType: "list(object)"},
		{Name: "service_credential_names", Value: "{\"es_writer\": \"Writer\", \"es_reader\": \"Reader\"}", DataType: "map(string)"},
		{Name: "metrics", Value: []string{"topic", "partition", "consumers"}, DataType: "list(string)"},
		{Name: "quotas", Value: quotas, DataType: "list(object)"},
		{Name: "schema_global_rule", Value: "FORWARD", DataType: "string"},
		{Name: "mirroring_topic_patterns", Value: []string{"topic-1", "topic-2"}, DataType: "list(string)"},
		{Name: "mirroring", Value: mirroring, DataType: "object"},
	}
	return options
}

// Test for the SecurityEnforced DA
func TestSecurityEnforcedSolutionInSchematics(t *testing.T) {
	t.Parallel()
	options := setupSecurityEnforcedOptions(t, "es-sen")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
