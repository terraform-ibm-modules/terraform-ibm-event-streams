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

func setupEnterpriseOptions(t *testing.T, prefix string) *testschematic.TestSchematicOptions {
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		Prefix:             prefix,
		BestRegionYAMLPath: regionSelectionPath,
		TarIncludePatterns: []string{
			"*.tf",
			enterpriseSolutionTerraformDir + "/*.tf",
			"modules/fscloud/*.tf",
		},
		/*
			Comment out the 'ResourceGroup' input to force this tests to create a unique resource group to ensure tests do
			not clash. This is due to the fact that an auth policy may already exist in this resource group since we are
			re-using a permanent HPCS instance and a permanent Event Streams instance. By using a new resource group, the auth policy will not already exist
			since this module scopes auth policies by resource group.
		*/
		//ResourceGroup:      resourceGroup,
		TemplateFolder:         enterpriseSolutionTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 360,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "service_credential_names", Value: "{\"es_writer\": \"Writer\", \"es_reader\": \"Reader\"}", DataType: "map(string)"},
		{Name: "provider_visibility", Value: "private", DataType: "string"},
		{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
		{Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		// Update the create timeout as it can take longer than the default (3 hours) when running multiple tests in parallel
		{Name: "create_timeout", Value: "5h", DataType: "string"},
	}
	return options
}

// Test for the Enterprise DA
func TestEnterpriseSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := setupEnterpriseOptions(t, "es-ent")
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// Upgrade test for the Enterprise DA
func TestRunUpgradeEnterpriseDA(t *testing.T) {
	t.Parallel()

	options := setupEnterpriseOptions(t, "ev-st-upg")
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}
