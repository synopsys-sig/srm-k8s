# Specify LDAP Configuration

1. Complete the Helm Prep Wizard to generate the config.json file suitable for your SRM deployment and invoke the resulting run-helm-prep.ps1 script.

2. Create a file named srm-ldap-private-props and add your LDAP props values. For example, you can set the LDAP URL, systemUsername, systemPassword, and authenticationMechanism by adding these values to your srm-ldap-private-props file:

```
auth.ldap.url = ldap://10.0.1.27
auth.ldap.systemUsername = CN=Code Dx Service Account,CN=Managed Service Accounts,DC=dc,DC=codedx,DC=local
auth.ldap.systemPassword = ************
auth.ldap.authenticationMechanism = simple
```

3. If necessary, pre-create the Kubernetes SRM namespace you specified during the Helm Prep Wizard.

```
kubectl create ns srm
```

4. Generate a Kubernetes secret named srm-ldap-private-props in your SRM namespace. For example, if your namespace is srm, run the following command from the directory containing srm-ldap-private-props:

```
kubectl -n srm create secret generic srm-ldap-private-props --from-file=srm-ldap-private-props
```

5. Reference your srm-ldap-private-props K8s secret by adding a new entry to your srm-extra-props.yaml file.

```
codedxProps:
  extra:
  - key: srm-ldap-private-props
    type: secret
    name: srm-ldap-private-props
```

>Note: If you do not yet have an srm-extra-props.yaml file, browse to [Configure SRM Properties](../config/srm-props.md) to learn how to create one and incorporate it into your deployment.
