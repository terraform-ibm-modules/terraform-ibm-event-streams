// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleTerraformDir = "examples/complete"
const quickstartTerraformDir = "solutions/quickstart"
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
		{Name: "service_credential_names", Value: "{\"es_writer\": \"Writer\", \"es_reader\": \"Reader\"}", DataType: "map(string)"},
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
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestEventStreamsDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "esdeft",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-event-streams",
		"quickstart",
		map[string]interface{}{
			"prefix":                       options.Prefix,
			"existing_resource_group_name": resourceGroup,
		},
	)

	err := options.RunAddonTest()
	require.NoError(t, err)
}

// TestDependencyPermutations runs dependency permutations for Event Streams and all its dependencies
func TestDependencyPermutations(t *testing.T) {

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:          t,
		Prefix:           "es-perm",
		StaggerDelay:     testaddons.StaggerDelay(20 * time.Second),     // 20s delay between batches
		StaggerBatchSize: testaddons.StaggerBatchSize(4),                // 4 tests per batch
		WithinBatchDelay: testaddons.WithinBatchDelay(16 * time.Second), // 8s delay within batch
		AddonConfig: cloudinfo.AddonConfig{
			OfferingName:   "deploy-arch-ibm-event-streams",
			OfferingFlavor: "quickstart",
			Inputs: map[string]interface{}{
				"prefix":                       "es-perm",
				"existing_resource_group_name": resourceGroup,
				"service_plan":                 "standard",
			},
		},
	})

	err := options.RunAddonPermutationTest()
	assert.NoError(t, err, "Dependency permutation test should not fail")
}
