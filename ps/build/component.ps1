function New-ComponentConfig($config,
	$shouldApplyWebConfig, $applyWebConfig,
	$shouldApplyMasterDatabaseConfig, $applyMasterDatabaseConfig,
	$shouldApplySubordinateDatabaseConfig, $applySubordinateDatabaseConfig,
	$shouldApplyScanFarmConfig, $applyScanFarmConfig,
	$shouldApplyToConfig, $applyToConfig,
	$shouldApplyStorageConfig, $applyStorageConfig,
	$shouldApplyWorkflowConfig, $applyWorkflowConfig) {

	if (& $shouldApplyWebConfig $config) {
		& $applyWebConfig $config
	}

	if (-not $config.skipScanFarm -and (& $shouldApplyScanFarmConfig $config)) {
		& $applyScanFarmConfig $config
	}

	if (-not $config.skipDatabase) {

		if (& $shouldApplyMasterDatabaseConfig) {
			& $applyMasterDatabaseConfig $config
		}

		if ($config.dbSlaveReplicaCount -gt 0 -and (& $shouldApplySubordinateDatabaseConfig $config)) {
			& $applySubordinateDatabaseConfig $config
		}
	}

	if (-not $config.skipToolOrchestration) {

		if (& $shouldApplyToConfig $config) {
			& $applyToConfig $config
		}

		if (-not $config.skipMinIO -and (& $shouldApplyStorageConfig $config)) {
			& $applyStorageConfig $config
		}

		if (& $shouldApplyWorkflowConfig $config) {
			& $applyWorkflowConfig $config
		}
	}
}