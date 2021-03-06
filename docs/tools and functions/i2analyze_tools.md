# i2 Analyze tools
The i2 Analyze deployment toolkit includes a number of tools that enable you to deploy and administer i2 Analyze.

> Note the `TOOLKIT_DIR` environment variable is set by the i2Tools image and does not need to be passed to the container at runtime.

## <a name="generateinformationstorescripts"></a> Generate Information Store scripts

The `generateInfoStoreToolScripts.sh` script is used to generate Information Store scripts from templates in `i2-tools/scripts/database-template` directory located inside the i2Tools image.
The generated scripts end up in in the `GENERATED_DIR`.
The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `GENERATED_DIR`     | The root location where any generated scripts are created. |
| `DB_TRUSTSTORE_LOCATION` | The location of the `truststore.jks`. |

## <a name="schemaupdatetool"></a> Schema update tool

The `generateUpdateSchemaScripts.sh` script is used to update the i2 Analyze schema in the Information Store. To update the schema, the tool generates a number of SQL scripts that must be run against the Information Store database.

When you run the tool, it compares the schema file in the configuration directory against the schema that is stored in the `IS_META.I2_SCHEMAS` table in Information Store database. If they are different, the schema in the database is updated with the one from the configuration.

Then, the `IS_DATA` table structure is compared with the schema `IS_META.I2_SCHEMAS`. If the `IS_DATA` objects are different, the scripts to update the objects are generated.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`        | The location of the root of the configuration directory. |
| `GENERATED_DIR`     | The root location where any generated scripts are created. `/update` is appended to the specified path. |

If these environment variables are not present, the script uses the following relative paths from the `toolkit/i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`
- `./database/sqlserver/InfoStore/generated/update`

You can run the generated scripts against the database manually, or you can use the [Run database scripts tool](#run-database-scripts-tool).


## <a name="securityschemaupdatetool"></a> Security schema update tool

The `updateSecuritySchema.sh` script is used to update the security schema in a deployment of i2 Analyze. When you run the script, the security schema file in the configuration directory is compared against the security schema that is stored in the `IS_META.I2_SCHEMAS` table in Information Store database. If they are different, the security schema in the database is updated with the one from the configuration.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`        | The location of the root of the configuration directory. |

If these environment variables are not present, the script uses the following relative paths from the `toolkit/i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`

## <a name="rundatabasescriptstool"></a> Run database scripts tool

You can run any generated scripts against the database manually, or you can use the `runDatabaseScripts.sh` script. This tool can be found in the `GENERATED_DIR` that was generated by the `generateInfoStoreToolScripts.sh` script.
The script requires the following environment variables to be set:

| Environment Variable | Description |
|----------------------|-------------|
| `DB_USERNAME`        | The name of the user that has the write access to the database. |
| `DB_PASSWORD`        | The password for the user. |
| `DB_SERVER`          | The fully qualified domain name of the database server. |
| `DB_PORT`            | Specifies the port number to connect to the Information Store. |

## <a name="managesolrindexestool"></a> Manage Solr indexes tool

By using the `indexControls.sh` script, you can pause and resume indexing on any index, upload system match rules, and switch a standby index to be the live index.

> Note: Switching from a standby index to live is possible for the following index types: chart, match, and main.

The script requires the following environment variables to be present:

   |Environment Variable              | Description |
   |----------------------------------|-------------|
   | `ZOO_USERNAME`                   | The name of the administrator user for performing administration tasks. |
   | `ZOO_PASSWORD`                   | The password for the administrator user. |
   | `ZK_HOST`                        | The connection string for each ZooKeeper server to connect to. |
   | `ZOO_SSL_TRUST_STORE_LOCATION`   | The location of the `truststore.jks` file to be used for SSL connections to ZooKeeper. |
   | `ZOO_SSL_TRUST_STORE_PASSWORD`   | The password for the truststore. |
   | `ZOO_SSL_KEY_STORE_LOCATION`     | The location of the `keystore.jks` file to be used for SSL connections to ZooKeeper. |
   | `ZOO_SSL_KEY_STORE_PASSWORD`     | The password for the keystore. |
   | `CONFIG_DIR`                     | The location of your configuration. This is used to locate the `system-match-rules.xml`. |
   | `TASK`                           | The index control task to perform. |

You can specify the following values for `TASK`:
- `UPDATE_MATCH_RULES`
- `SWITCH_STANDBY_MATCH_INDEX_TO_LIVE`
- `CLEAR_STANDBY_MATCH_INDEX`
- `REBUILD_STANDBY_MAIN_INDEX`
- `SWITCH_STANDBY_MAIN_INDEX_TO_LIVE`
- `CLEAR_STANDBY_MAIN_INDEX`
- `REBUILD_STANDBY_CHART_STORE_INDEX`
- `SWITCH_STANDBY_CHART_STORE_INDEX_TO_LIVE`
- `CLEAR_STANDBY_CHART_STORE_INDEX`
- `PAUSE_INDEX_POPULATION`
- `RESUME_INDEX_POPULATION`

For more information about the index control tasks, see [Index control toolkit tasks](https://www.ibm.com/support/knowledgecenter/SSXVTH_4.3.2/com.ibm.i2.deploy.example.doc/toolkit_commands.html).


## <a name="informationstoredatabaseconsistencytool"></a> Information Store database consistency tool

The `databaseConsistencyCheck.sh` script checks that the database objects in the `IS_DATA` database schema are consistent with the information in `IS_META`.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

| Environment Variable | Description |
|----------------------|-------------|
| `TOOLKIT_DIR`        | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`         | The location of the root of the configuration directory. |

If these environment variables are not present, the script uses the following relative paths from the `toolkit/i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`

If the database is a consistent state with the schema, the following message will be returned in the console

```bash
The Database is in a consistent state.
```

If the database is an inconsistent state with the schema, errors will be reported in the console where the tool was run.
For example:
```bash
The following changes to the Information Store database tables and/or views have been detected:
MODIFIED ITEM TYPES
        Item type: Arrest
                ADDED PROPERTY TYPES
                        Property type: Voided
        Item type: Arrest
The following changes to the Information Store database tables and/or views have been detected:
ADDED ITEM TYPES
        Item type: Vehicle
> ERROR [DatabaseConsistencyCheckCLI] - Information Store database is inconsistent with the schema stored in the database
```

## <a name="schemavalidationtool"></a> Schema validation tool

The `validateSchemaAndSecuritySchema.sh` script checks that the database objects in the `IS_META` database schema are consistent with the i2 Analyze schema and the security schema in the `IS_META.I2_SCHEMAS`.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`        | The location of the root of the configuration directory. |

If these environment variables are not present, the script uses the following relative paths from the `toolkit/i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`

If the schemas are valid no errors will be reported. However, if the schemas are the same as teh version of the database this information will be returned to the console.

If the schemas contain validation errors will be reported to the console where the tool was run.

For example:

```
VALIDATION ERROR: Schema contains duplicate type EntityType with ID 'ET5'.
```

## <a name="generatestaticdatabasescriptstool"></a> Generate static database scripts tool

The `generateStaticInfoStoreCreationScripts.sh` script injects values from your configuration into the static database scripts.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`        | The location of the root of the configuration directory. |
| `GENERATED_DIR`     | The root location where any generated scripts are created. `/static` is appended to the specified path. |

If these environment variables are not present, the script uses the following relative paths from the `toolkit/i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`
- `../scripts/database/{dialect}/InfoStore/generated/static`

The script creates the `.sql` files in the location of the `GENERATED_DIR`  that was supplied to the container.

### <a name="runstaticdatabasescriptstool"></a> Run static database scripts tool

The `runStaticScripts.sh` script runs the static scripts that create the Information Store database. This tool can be found in the `GENERATED_DIR` that was generated by the `generateInfoStoreToolScripts.sh` script.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `DB_USERNAME`       | The name of the user that has the write access to the database. |
| `DB_PASSWORD`       | The password for the user. |
| `DB_SERVER`         | The fully qualified domain name of the database server. |
| `DB_PORT`           | Specifies the port number to connect to the Information Store. |
| `GENERATED_DIR`     | The location of the folder that contains the static scripts to be run. `/static` is appended to the specified path. |
| `CA_CERT_FILE`      | The location of the certificate file on the docker container. |

The `GENERATED_DIR` environment variable must be present and is not defaulted.

## <a name="generatedynamicinformationstorecreationscriptstool"></a> Generate dynamic Information Store creation scripts tool

The `generateDynamicInfoStoreCreationScripts.sh` script creates the `.sql` scripts that are required to create the database objects that align to your schema in the configuration.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the root of the deployment toolkit. |
| `CONFIG_DIR`        | The location of the root of the configuration directory. |
| `GENERATED_DIR`     | The location where any generated scripts are created. `/dynamic` is appended to the specified path. |

If these environment variables are not present, the script uses the following relative paths from the `i2-tools/scripts` directory:
- `../../toolkit`
- `../configuration`
- `../scripts/database/{database dialect}/InfoStore/generated/dynamic`

The script creates the `.sql` files in the location of the `GENERATED_DIR`  that was supplied to the container.

### <a name="rundynamicinformationstorecreationscriptstool"></a> Run dynamic Information Store creation scripts tool

The `runDynamicScripts.sh` script runs the dynamic scripts that create the Information Store database. This tool can be found in the `GENERATED_DIR` that was generated by the `generateInfoStoreToolScripts.sh` script.

The `runSQLServerCommandAsSA` client function is used to run the `runDynamicScripts.sh` script that create the Information store and schemas.
* [runSQLServerCommandAsSA](../tools%20and%20functions/client_functions.md#runsqlservercommandassa)

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `DB_USERNAME`       | The name of the user that has the write access to the database. |
| `DB_PASSWORD`       | The password for the user (Note: you can set DB_PASSWORD_FILE with the location of the file containing the password). |
| `DB_SERVER`         | The fully qualified domain name of the database server. |
| `DB_PORT`           | Specifies the port number to connect to the Information Store. |
| `GENERATED_DIR`     | The location of the folder that contains the scripts to be run. `/dynamic` is appended to the specified path. |
| `CA_CERT_FILE`      | The location of the certificate file on the docker container. |

The `GENERATED_DIR` environment variable must be present and is not defaulted.

### <a name="rundatabasecreationscriptstool"></a> Run database creation scripts tool

The `runDatabaseCreationScripts.sh` script runs the `create-database-storage.sql` & `0001-create-schemas.sql` database creation scripts. These scripts create the Information Store database and schemas. This tool can be found in the `GENERATED_DIR` that was generated by the `generateInfoStoreToolScripts.sh` script.

The script requires connection property values to be loaded from environment variables or from the `Connection.properties` file in the configuration. For more information about the connection properties, see  [Loading connection properties](#connection-properties).

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `DB_USERNAME`       | The name of the user that has the write access to the database. |
| `DB_PASSWORD`       | The password for the user (Note: you can set DB_PASSWORD_FILE with the location of the file containing the password). |
| `DB_SERVER`         | The fully qualified domain name of the database server. |
| `DB_PORT`           | Specifies the port number to connect to the Information Store. |
| `GENERATED_DIR`     | The location of the folder that contains the scripts to be run. `/dynamic` is appended to the specified path. |
| `CA_CERT_FILE`      | The location of the certificate file on the docker container. |

The `GENERATED_DIR` environment variable must be present and is not defaulted.

## <a name="removedatafromtheinformationstoretool"></a> Remove data from the Information Store tool

The `runClearInfoStoreData.sh` script removes all the data from the Information Store database.

The script requires the following environment variables to be present:

|Environment Variable | Description |
|---------------------|-------------|
| `DB_USERNAME`       | The name of the user that has the write access to the database. |
| `DB_PASSWORD`       | The password for the user. |
| `DB_SERVER`         | The fully qualified domain name of the database server. |
| `DB_PORT`           | Specifies the port number to connect to the Information Store. |
| `GENERATED_DIR`     | The path to the root of the directory that contains the generated static scripts. `/static` is appended to the value of `GENERATED_DIR`. |

The `GENERATED_DIR` environment variable must be present and is not defaulted.

For more information about clearing data from the Information Store, see [Clearing Data](https://www.ibm.com/support/knowledgecenter/SSXVTH_latest/com.ibm.i2.eia.go.live.doc/t_clearing_data.html)

## <a name="createstaticlibertyapplicationtool"></a> Create static Liberty application tool

The `createLibertyStaticApp.sh` creates the static application to be hosted in Liberty. The tool combines the contents of various folders to create the application, in a similar way to the `deployLiberty` toolkit task.

To run the tool, you must provide a location to create the application files as an argument. Alternatively if you are running the tool from outside of the toolkit/i2-tools/scripts folder the following environment variable must be set:

|Environment Variable | Description |
|---------------------|-------------|
| `TOOLKIT_DIR`       | The location of the toolkit. |

When you call the `createLibertyStaticApp.sh` script, you must pass the location where the Liberty `application` directory is created.

## <a name="connectionproperties"></a> Connection properties

Some of the tools require database connection properties such as database username, database truststore location & password for example in order to communicate with the database so that the tool can run. These properties can be loaded from a file called `Connection.properties`
that is located in your configuration in the following directory `configuration/fragments/common/WEB-INF/classes/`.

For example:

```properties
DBName=ISTORE
DBDialect=sqlserver
DBServer=sqlserver.eia
DBPort=1433
DBOsType=UNIX
DBSecureConnection=true
DBCreateDatabase=false
db.installation.dir=/opt/mssql-tools
db.database.location.dir=/opt/mssql
```

In the docker environment, these properties can be alternatively loaded via environment variables passed into the container.

The following environment variables are supported for supplying connection properties:

| Environment Variable     | Description |
|--------------------------|-------------|
| `DB_USERNAME`            | The name of the user that has the write access to the database. |
| `DB_PASSWORD`            | The password for the user (Note: you can set DB_PASSWORD_FILE with the location of the file containing the password). |
| `DB_DIALECT`             | The dialect for the database. Can be `sqlserver` or `db2`. |
| `DB_SERVER`              | The fully qualified domain name of the database server. |
| `DB_PORT`                | Specifies the port number to connect to the Information Store. |
| `DB_NAME`                | The name of the Information Store database. |
| `DB_OS_TYPE`             | The Operating System that the database is on. Can be `UNIX`, `WIN`, or `AIX`. |
| `DB_INSTALL_DIR`         | Specifies the database CMD location. |
| `DB_LOCATION_DIR`        | Specifies the location of the database. |
| `DB_TRUSTSTORE_LOCATION` | The location of the `truststore.jks`. * |
| `DB_TRUSTSTORE_PASSWORD` | The password for the truststore. * |

* The security settings are only required if your database is configured to use a secure connection.

