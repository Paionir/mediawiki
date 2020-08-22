# Mediawiki
**Mediawiki docker image with full LDAP support**

Since the official mediawiki docker image was lacking of LDAP support, I built it anew starting from debian:stable image. 
It ended up being also smaller than the official one

## RUN
* create a directory where you will store your LocalSettings.php and images file
(e.g. mkdir /home/mine/extdir)
* run a container using: 
```bash
docker -idt -v home/mine/extdir/LocalSettings.php:/var/www/html/LocalSettings.php -p 8080:80 --name mediawiki pmarcop/mediawiki:1.34.2  
```
* browse to your IP at port 8080 and start the installation of mediawiki
* put the LocalSettings.php file into /home/mine/extdir/

Now you can edit the LocalSettings.php file according to your LDAP environment

Example:

```php
$wgGroupPermissions['*']['autocreateaccount'] = true;

wfLoadExtensions( [
	'PluggableAuth',
	'LDAPProvider',
	'LDAPAuthentication2',
	'LDAPAuthorization',
	'LDAPUserInfo'
] );

$wgPluggableAuth_EnableLocalLogin = true;

$LDAPAuthorizationAutoAuthRemoteUserStringParser = 'username-at-domain';
$LDAPAuthentication2UsernameNormalizer = 'strtolower';
$wgAuthRemoteuserAllowUserSwitch = true;
$wgPluggableAuth_EnableLocalLogin = false;
$LDAPAuthentication2AllowLocalLogin = false;

$LDAPProviderDomainConfigProvider = function() {
	$config = [
		'domainname' => [
			'connection' => [
				"server" => "ldap.domainname",
				"user" => "cn=user_that_can_search,cn=Users,dc=domainname",
				"pass" => "securepassword",
				"enctype" => "clear",
				"options" => [
					"LDAP_OPT_DEREF" => 1
				],
				"basedn" => "dc=domainname",
				"groupbasedn" => "dc=domainname",
				"userbasedn" => "dc=domainname",
				"searchattribute" => "samaccountname",
				"searchstring" => "domainname\\USER-NAME",
				"usernameattribute" => "samaccountname",
				"emailattribute" => "mail",
				"realnameattribute" => "displayname",
				"grouprequest" => "MediaWiki\\Extension\\LDAPProvider\\UserGroupsRequest\\GroupMember::factory",
			],
			'userinfo' => [],
			'authorization' => [
				'rules' => [
					'groups' => [
						'required' => [
							CN=group1,cn=groups,dc=domainname,
              CN=group2,cn=groups,dc=domainname
						]
					]
				]
			],
		]
	];

	return new \MediaWiki\Extension\LDAPProvider\DomainConfigProvider\InlinePHPArray( $config );
};
```

### Remeber to update your mediawiki container after changing the LDAP auth configuration
```bash
docker exec mediawiki php /var/www/html/maintenance/update.php
```





