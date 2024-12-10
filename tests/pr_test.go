// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const quickstartSolutionTerraformDir = "solutions/quickstart"
const enterpriseSolutionTerraformDir = "solutions/enterprise"
const fsCloudTerraformDir = "examples/fscloud"

// Use existing group for tests
const resourceGroup = "geretain-test-event-streams"

// Set up tests to only use supported BYOK regions
const regionSelectionPath = "../common-dev-assets/common-go-assets/icd-region-prefs.yaml"

const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
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

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "event-streams-upg", completeExampleTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunQuickstartSolution(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  quickstartSolutionTerraformDir,
		Prefix:        "es-qs",
		ResourceGroup: resourceGroup,
	})

	options.TerraformVars = map[string]interface{}{
		"ibmcloud_api_key":            options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"],
		"resource_group_name":         options.ResourceGroup,
		"use_existing_resource_group": true,
		"prefix":                      options.Prefix,
		"provider_visibility":         "public",
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunEnterpriseSolution(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: enterpriseSolutionTerraformDir,
		Prefix:       "es-ent",
		// ResourceGroup: resourceGroup,
	})

	options.TerraformVars = map[string]interface{}{
		"ibmcloud_api_key":            options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"],
		"resource_group_name":         options.ResourceGroup,
		"use_existing_resource_group": true,
		"prefix":                      options.Prefix,
		"service_credential_names":    "{\"es_writer\": \"Writer\", \"es_reader\": \"Reader\"}",
		"existing_kms_key_crn":        permanentResources["hpcs_south_root_key_crn"],
		"existing_kms_instance_guid":  permanentResources["hpcs_south"],
		"resource_tags":               options.Tags,
		"access_tags":                 options.Tags,
		"provider_visibility":         "public",
	}

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
		{Name: "existing_kms_instance_guid", Value: permanentResources["hpcs_south"].(string), DataType: "string"},
		{Name: "existing_kms_key_crn", Value: permanentResources["hpcs_south_root_key_crn"].(string), DataType: "string"},
		{Name: "event_streams_source_crn", Value: permanentResources["event_streams_us_south_crn"].(string), DataType: "string"},
		{Name: "provider_visibility", Value: "public", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
