# SRM Kubernetes Backup & Restore Procedure

SRM depends on [Velero](https://velero.io) for cluster state and volume data backups. When not using an external SRM database, you must deploy SRM with at least one MariaDB subordinate database so that a database backup occurs before Velero runs a backup.

If you are using an external SRM database, your database will not be included in the Velero-based backup. You must create a database backup schedule on your own. To minimize data loss, schedule your database backups to coincide with your SRM backups to help align your Kubernetes volume and database data after a restore.

> Note: The overall backup process is not an atomic operation, so it's possible to capture inconsistent state in a backup. For example, the SRM AppData volume backup could include a file that was unknown at the time the database backup occurred. The likelihood of capturing inconsistent state is a function of multiple factors including system activity and the duration of backup operations.

## About Velero

Velero can back up k8s state stored in etcd and k8s volume data. Volume data gets backed up using either [storage provider plugins](https://velero.io/docs/main/supported-providers/), or Velero's integration with [Restic](https://restic.net/) or [Kopia](https://kopia.io/). Refer to [How Velero Works](https://velero.io/docs/main/how-velero-works/), [How Velero integrates with Restic](https://velero.io/docs/main/file-system-backup/#how-velero-integrates-with-restic), and [How Velero integrates with Kopia](https://velero.io/docs/main/file-system-backup/#how-velero-integrates-with-kopia) for more details.

> Note: Use Velero's Restic or Kopia integration when a storage provider plugin is unavailable for your environment.

## Installing Velero

Install the [Velero CLI](https://velero.io/docs/main/basic-install/#install-the-cli) and then follow the Velero installation documentation for your scenario. You can find links to provider-specific documentation in the Setup Instructions column on the [Providers](https://velero.io/docs/main/supported-providers/) page, which includes links to the [Azure](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup) and [AWS](https://github.com/vmware-tanzu/velero-plugin-for-aws#setup) instructions. If you're not using a storage provider plugin, [enable file system backup](https://velero.io/docs/main/customize-installation/#enable-file-system-backup) at install time.

> Note: If your Velero backup unexpectedly fails, you may need to increase the amount of memory available to the Velero pod. Use the --velero-pod-mem-limit parameter with the velero install command as described [here](https://velero.io/docs/main/customize-installation/#customize-resource-requests-and-limits).

## Create a Backup Schedule

After installing Velero, you can create a [Schedule resource](https://velero.io/docs/main/api-types/schedule/).

### Schedule for On-Cluster Database

If you are using an on-cluster SRM database, create a Schedule resource using the following YAML, replacing namespace names `velero` and `srm` as necessary.

```
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: srm-schedule
  namespace: velero
spec:
  schedule: 0 3 * * *
  template:
    hooks:
      resources:
      - includedNamespaces:
        - srm
        labelSelector:
          matchLabels:
            app: mariadb
            component: slave
        name: database-backup
        pre:
        - exec:
            command:
            - /bin/bash
            - -c
            - /bitnami/mariadb/scripts/backup.sh && sleep 1m
            container: mariadb
            timeout: 30m
    includeClusterResources: true
    includedNamespaces:
    - srm
    storageLocation: default
    ttl: 720h0m0s
```

>Note: The above Schedule requires a replica SRM database whose backup.sh script will be invoked as a pre-backup hook.

### Schedule for External Database

If you are using an external SRM database, create a Schedule resource using the following YAML, replacing namespace names `velero` and `srm` as necessary. Ensure that the external database backup occurs at the same time indicated by `spec.schedule`.

```
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: srm-schedule
  namespace: velero
spec:
  schedule: 0 3 * * *
  template:
    includeClusterResources: true
    includedNamespaces:
    - srm
    storageLocation: default
    ttl: 720h0m0s
```

## Verify Backup

Once backups start running, use the velero commands that [describe backups and fetch logs](https://velero.io/docs/v1.5/troubleshooting/#general-troubleshooting-information) to confirm that the backups are completing successfully and that they include SRM volumes.

When using Velero with Storage Provider Plugins, the volume snapshots initiated by a plugin may finish after the Backup resource reports a completed status. Wait for the volume snapshot process to finish before starting a restore.

If applicable, you should also confirm that the database backup script runs correctly and produces database backups with each Velero backup in the /bitnami/mariadb/backup/data directory. Use the following command after replacing placeholder parameters to list recent backups for a MariaDB subordinate database instance:

```
$ kubectl -n srm-namespace-placeholder exec srm-mariadb-slave-pod-placeholder -- ls /bitnami/mariadb/backup/data
```

> Note: Older backup files get removed from the database volume when backups complete.

You can use this command to view the backup log on a MariaDB slave database instance.

```
$ kubectl -n srm-namespace-placeholder exec srm-mariadb-slave-pod-placeholder -- cat /bitnami/mariadb/backup/data/backup.log
```

The backup.log file should have a "completed OK!" message above the log entries indicating that old backups are getting removed.

> Note: To confirm that a backup includes the volume holding your SRM database backup, test a backup by running a restore.

You should periodically check your Velero backups based on your backup schedule to ensure that backups are succeeding.

## Restoring Code Dx

Velero will skip restoring resources that already exist, so delete those you want to restore from a backup. You can delete the SRM namespace(s) to remove all namespaced resources, and you can delete cluster scoped SRM resources to remove SRM entirely. Since SRM depends on multiple PersistentVolume (PV) resources, you will typically want to delete SRM PVs when restoring SRM to a previous known good state.

There are two steps required to restore SRM from a Velero backup. The first step is to use the velero CLI to restore a specific backup. For the second step, you will run the restore-db.ps1 script to restore a local SRM database. If you're using an external database, you will skip the second step by restoring your SRM database on your own.

>Note: When using Velero with Storage Provider Plugins, wait for the volume snapshot process to finish before restoring a backup.

### Step 1: Restore Cluster State and Volume Data

During Step 1, you will use Velero to restore cluster and volume state from an existing backup. You can see a list of available backups by running the following command:

```
$ velero get backup
```

Assuming you want to restore a backup named 'my-backup', run the following command to install the PriorityClass resources from that backup:

```
$ velero restore create --from-backup my-backup --include-resources=PriorityClass
```

Wait for the restore started by the previous command to finish. You can use the describe command it prints to check progress.

A restore may finish with warnings and errors indicating that one or more resources could not be restored. Velero will not delete resources during a restore, so you may see warnings about Velero failing to create resources that already exist. Review any warnings and errors displayed by Velero's describe and log commands to determine whether they can be ignored.

> Note: You can use Velero's log command to view the details of a restore after it completes.

After waiting for the restore operation to finish, run the following command to restore the remaining resources from your backup:

```
$ velero restore create --from-backup my-backup
```

> Note: Running two velero commands works around an issue discovered in Velero v1.3.2 that blocks the restoration of SRM pods. If you run only the second command, SRM priority classes get restored, but pods depending on those classes do not.

When using Velero with storage provider plugins, your SRM and MariaDB pods may not return to a running state. Step 2 will resolve that issue.

> Note: SRM is not ready for use at the end of Step 1.

### Step 2: Restore SRM Database

During Step 2, you will run the admin/restore-db.ps1 script to restore the SRM database from a backup residing on the volume data you restored. If you are using an external SRM database, restore your external database to a time that coincides with your SRM backup and skip this section.

At this point, you can find the database backup corresponding to the backup you want to restore. Refer to the Verify Backup section for the command to list backup files on a MariaDB slave database instance. Note the name of the database backup that coincides with the Velero backup you restored (e.g., '20200523-020200-Full'). You will enter this name when prompted by the restore-db.ps1 script.

You must add both the helm and kubectl programs to your path before running the restore database script. Start a new PowerShell Core 7 session and change directory to where you downloaded the setup scripts from the [srm-k8s](https://github.com/synopsys-sig/srm-k8s).

```
/$ pwsh
PS /> cd ~/git/srm-k8s/admin
```

Start the restore-db.ps1 script by running the following command after replacing parameter placeholders:

```
PS /git/srm-k8s/admin> ./restore-db.ps1 `
        -namespaceCodeDx 'srm-namespace-placeholder' `
        -releaseNameCodeDx 'srm-helm-release-name-placeholder'
```

> Note: You can pull the SRM Restore Database Docker image from an alternate Docker registry using the -imageDatabaseRestore parameter and from a private Docker registry by adding the -dockerImagePullSecretName parameter.

When prompted by the script, enter the name of the database backup you want to restore and the passwords for the MariaDB database root and replicator users. The script will search for the database backup, copy it to a folder in your profile, and use the backup to restore both master and slave database(s). It will then restart database replication, and it will manage the running instances of MariaDB and SRM, so when the script is finished, all SRM pods will be online. Depending on your ingress type and what was restored, you may need to update your DNS configuration before using the new SRM instance.

> Note: The restore-db.ps1 script requires that your work directory (default is your profile directory) not already include a folder named backup-files. The script will stop if it finds that directory, so delete it before starting the script.

## Uninstalling

If you need to uninstall the backup configuration and Velero, do the following:

- Remove the Velero Schedule resource for your SRM instance and related Backup and Restore resources (you can remove *all* Velero backup and restore objects by running `velero backup delete --all` and `velero restore delete --all`)
- [Uninstall Velero](https://velero.io/docs/main/uninstalling/)
