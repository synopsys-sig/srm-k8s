# Specify Extra SAML Configuration

Selecting SAML authentication in the Helm Prep Wizard will generate a config.json file with the following fields configured (field values are for illustrative purposes):

```
  ...
  "useSaml": true,
  "useLdap": false,
  "samlHostBasePath": "http://localhost:9090/srm",
  "samlIdentityProviderMetadataPath": "/path/to/idp-metadata.xml",
  "samlAppName": "srm-app",
  "samlKeystorePwd": "password",
  "samlPrivateKeyPwd": "password",
  ...
```

Running helm-prep.ps1 with a config.json file like the above will generate an SRM props file with the following SAML properties:

- auth.saml2.identityProviderMetadataPath
- auth.saml2.entityId
- auth.saml2.keystorePassword
- auth.saml2.privateKeyPassword
- auth.hostBasePath

If you want to configure additional SAML properties described in the SRM Install Guide, add them to your srm-extra-props.yaml file. 

>Note: If you do not yet have an srm-extra-props.yaml file, browse to [Configure SRM Properties](../config/srm-props.md) to learn how to create one and incorporate it into your deployment.

Here's an example srm-extra-props.yaml with two SAML-specific props:

```
web:
  props:
    extra:
    - type: values
      key: srm-public-props
      values:
      - "ui.auth.samlLabel = Keycloak"
      - "auth.autoExternalRedirect = false"
```

