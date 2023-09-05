# Unlock

Run the unlock-config.ps1 script to replace specific config.json encrypted field values with unencrypted values, leaving your config.json file unlocked.

```
$ pwsh /path/to/git/admin/config/unlock-config.ps1 -configPath /path/to/config.json
Enter config file password:
```

# Lock

Run the lock-config.ps1 script to encrypt specific config.json field values, locking your config.json file.

```
$ pwsh /path/to/git/admin/config/lock-config.ps1 -configPath /path/to/config.json
Enter config file password:
```