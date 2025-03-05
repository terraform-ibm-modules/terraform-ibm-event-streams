// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go

package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const basicExampleTerraformDir = "examples/basic"

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
		WaitJobCompleteMinutes: 180,
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
