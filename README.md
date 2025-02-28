# MTE Relay Server for .Net

MTE Relay Server is one half of an end-to-end encryption system that protects all network requests with next-generation application data security,
on prem or in the cloud. The *Mte-Relay Server* acts as a proxy-server that sits in front of your normal server, and communicates with an *Mte-Relay Client*,
encoding and decoding all network traffic.  
Additionally, the *Mte-Relay Server* can operate as a *Reverse Proxy* to encrypt **clear** traffic from the output of an existing API, protect it, and 
forward it on to a *paired Mte-Relay Server* to be revealed and used by your destination API.  In this mode it acts as a secure pipeline between
your existing APIs ensuring that all traffic between them is protected with the Ultimate security provided by the *Eclypses MTE*.

### Installation
GitHub contains a repository at https://github.com/Eclypses/mte-relay-server-cs with all of the artifacts that you will need to run an instance (or a pair of instances) of Mte-Relay in your environment.  
Download the following package and follow the instructions included below to build a *Docker* container to run
a version of the *Mte-Relay Server*.  
There are a few basic steps you must do:
- Download the package from GitHub into a folder on your intended target such as */eclypses/downloaded*.
- Obtain your licensed version of the *Mte Library (libmte.so)* from the [Eclypses Developer's Portal](https://developers.eclypses.com).
- Copy that file (*libmte.so*) into the same folder that you downloaded the package into.
- Obtain the license information for your *Mte Library* from the [Eclypses Developer's Portal](https://developers.eclypses.com).

### Installation in a Docker Container
If you wish to containerize this application, there are a few steps required for that.
- Ensure that you have installed *docker* in either a *linux* environment or a *windows* environment (the docker image is built as a *linux* command).
- If you are using *windows* issue the commands from a *powershell* running as an *administrator*.
- Edit the *mterelay.env* file found in the downloaded package.
  - Place your licensed company name as the `APP_SETTINGS__LICENSE_COMPANY` value.
  - Place your license key as the `APP_SETTINGS__LICENSE_KEY` value.
  - Place your intended upstream server as the `APP_SETTINGS__UPSTREAM` value.
  - Place your originating application address as the `APP_SETTINGS__CORS_ORIGIN` value.
  - Place an arbitrary value (at least 32 characters) as the `APP_SETTINGS__CLIENT_ID_SECRET` value.
  - Make any other adjustments or additions to the file as noted below.
- Additionally, if this instance is to be utilized as the *Front-End* of a pair of *Mte-Relay Servers* you must include another configuration item.
  - Place your enterprise value as the `APP_SETTINGS__OUTBOUND_TOKEN` (See below for an explanation).
- Your `docker build` command must be run in the folder that you download into.  Otherwise, edit the `COPY` command
in the downloaded *Dockerfile* to reflect where your source is.
- Issue the `docker build` command: 
``` sh
docker build -t mte-relay-server-mterelay .
```
- Issue the `docker run` command to start the service - a single container can operate as either the sole *proxied* *Mte-Relay Server* or as either end 
  of a pair of *Mte-Relay Servers*.
``` sh
docker run --env-file mterelay.env -p 8080:8080  mte-relay-server-mterelay:latest
```
- You may start as many *Mte-Relay Servers* as you wish, just ensure that the exposed port is different for each instance. For example:
``` sh
docker run --env-file mterelay.env -p 8080:8080  mte-relay-server-mterelay:latest
docker run --env-file mterelay.env -p 9090:8080  mte-relay-server-mterelay:latest
docker run --env-file mterelay.env -p 9095:8080  mte-relay-server-mterelay:latest
```

### Installation as a *linux* application.
If you are running this in a *linux VM* (or a *linux bare metal computer*) you have everything that you need.
Just follow these simple steps:
- Move the entire contents of what you downloaded into the folder that you normally install apps into such as
`/opt/eclypses` or some other folder that is in your *path*.
- Ensure that your distro has the following libraries, and if not install them:
    - libicu72
    - libssl3
    - ca-certificates
- If your distro has a different library other than *libdl.so* for loading dynamic libraries, set up a `symlink` with 
a command similar to the one in the *Dockerfile*.
``` sh
ln -fs libdl.so.2 /usr/lib/x86_64-linux-gnu/libdl.so
```
- Set up a `symlink` to the actual *libmte.so* library that you obtained from the 
[Eclypses Developer's Portal](https://developers.eclypses.com) using the following command (assuming you installed into */opt/eclypses*):
``` sh
ln -fs /opt/eclypses/libmte.so /usr/lib/x86_64-linux-gnu/libmte.so
```
- Edit the *appsettings.json* file found in the downloaded package.
  - Place your licensed company name as the `LICENSE_COMPANY` value.
  - Place your license key as the `LICENSE_KEY` value.
  - Place your intended upstream server as the `UPSTREAM` value.
  - Place your originating application address as the `CORS_ORIGIN` value.
  - Place an arbitrary value (at least 32 characters) as the `CLIENT_ID_SECRET` value.
  - Make any other adjustments or additions to the file as noted below.
- Start the application with the following command: `./mte-relay-server`

### Config File
If you are running from a container, the `docker run` command should have a parameter to indicate the *mterelay.env* file.  This file contains the runtime
values that the *Mte-Relay Server* uses.  
If you are running as a *linux* application, those changes should be in the *appsettings.json* file.  
The configuration file contains the following properties. 
Examples are shown below.  
`Note: These are UPPERCASE to allow you to override their values in your Environment.`

- `UPSTREAM`
  - **Required**
  - The upstream application that inbound requests will be proxied to (this is only applicable if this instance communicates with your destination API, but it always required).
- `LICENSE_COMPANY`
  - **Required**
  - Your company name. See your project settings in the [Eclypses Developer's Portal](https://developers.eclypses.com).
- `LICENSE_KEY`
  - **Required**
  - Your license key. See your project settings in the [Eclypses Developer's Portal](https://developers.eclypses.com).
- `CLIENT_ID_SECRET`
  - **Required**
  - A secret that will be used to sign the x-mte-client-id header. A 32+ character string is recommended.
- `OUTBOUND_TOKEN`
  - **May be Required**
  - This is required if this instance is acting as the *Front-End* of a pair of *Mte-Relay Servers*. It should be a unique value that serves as an additional
  safeguard ensuring that only the traffic that you wish to protect is included in a protected communication. We recommend that this value be a minimum
  of 32 bytes in length and you should ensure it is kept in a safe storage location. It is *never* exposed in any log files.
- `CORS_ORIGINS`
  - A comma separated list of URLs that will be allowed to make cross-origin requests to the server. Required by browsers to communicate with this server.
- `APP_LOG_LEVEL`
  - The *Mte-relay* writes certain logs to the console as well as to a file. You can tune what severity of logs
  to produce.  The values are *Warning*, *Info*, *Debug* or *Verbose*.  Any logs of a higher severity than *Warning*
  are always produced.
  - Default: *Warning*.
- `SYS_LOG_LEVEL`
  - *.Net* writes certain logs to the console as well as to a file. You can tune what severity of logs
  to produce.  The values are *Warning*, *Info*, *Debug* or *Verbose*.  Any logs of a higher severity than *Warning*
  are always produced.
  - Default: *Warning*.  
 - `LOG_FILE`  
    - If this value is present and not empty, log entries will be written to this file. Serilog rolls files on a daily basis
  so if this points to a *Docker mount point* or a *directory*, the date in *yyyymmdd* format is part of the file name
  immeadiately preceding the extension. So it is recommended to use a value such as:
  `/logs/mte-relay..log` causing the files created to be named as
  *mte-relay.20250131.log* in the */logs* directory.
    - Default: ""
    - Note: `Console logs are always written, so you can direct them as your needs require.`
- `PORT`
  - The port that the server will listen on. (Note: if you are running in a *container* be sure to expose this port.)
  - Default: `8080`.
- `PASS_THROUGH_ROUTES`
  - A comma separated list of routes that will be passed through to the upstream application without being MTE encoded/decoded.
- `MTE_ROUTES`
  - A list of routes that will be MTE encoded/decoded. If this optional property is included, only the routes listed
will be MTE encoded/decoded, and any routes not listed here or in `PASS_THROUGH_ROUTES` will 404. If this optional property
is not included, all routes not listed in `PASS_THROUGH_ROUTES` will be MTE encoded/decoded.
- `CORS_METHODS`
  - A comma separated list of HTTP methods that will be allowed to make cross-origin requests to the server.
  - Default: `GET, POST, PUT, DELETE, PATCH`.
  - Note: `OPTIONS` and `HEAD` are always allowed.
- `HEADERS`
  - An array of colon separated key:value pairs that will be added as headers to
the upstream request and then to the response back to the originating endpoint.
- `MAX_POOL_SIZE`
  - The number of encoder objects and decoder objects held in a pool. A larger pool will consume more memory, but it will also handle more traffic more quickly. This number is applied to both pools the `MKE Encoder` and `MKE Decoder` pools.
  - Default: `25`
- `MTERELAY_USER_AGENT`
    - The fallback user agent value to be sent as a header to the upstream service.
If the incoming request has a User-Agent header, that is passed along, however if it does
not, then this value is used. The default value (if none  found or supplied) is *.Net MTE-Relay*.
- `TIMEOUT_SECONDS`
  - The number of seconds before the `MTE-Relay` throws a timeout error. The default is 120 seconds (2 minutes).
- `MTE_CHUNK_SIZE`
  - The maximum size of an individual chunk of a request / response stream that is managed by MTE. One megabyte (1048576)
is reasonable.  For each chunk that is managed, the MTE process is used, so small chunks may impact performance
while large chunks may consume more memory. All data is processed, so this is not a limit, but rather it is a tuning parameter.
The default is one megabyte (1048576).
- `CACHE_PROVIDER`
  - .Net uses the *IDistributedCache* interface to handle the caching of *MTE States*. At this time, *Redis* has
been thoroughly tested as well as *Memory*. Whereas *Memory* is extremely fast, it is limited to a single service,
so if you are running multiple *MTE-Relay* instances on multiple endpoints, you must use *Redis* to ensure
site affinity. If you select *Redis*, you must ensure that a *Redis* instance is available
and that you have configured the required settings (see below). The default is *Memory*.
- `CACHE_SLIDING_EXPIRATION_MINUTES`
  - *IDistributedCache* will purge unused cache entries after a period of time. This setting determines
when a cached entry is available for purging.  This is a sliding value, so each time a cached value
is accessed, the sliding interval resets. The default is 15 minutes.  
- `REDIS_CONNECTION_STRING`
    -  If you are using *redis* as your cache provider - this is the connection string to your *redis* server.
- `REDIS_INSTANCE_NAME_`
    -  If you are using *redis* as your cache provider - this is the instance name that you pass
    into your *redis* start command with the `--name` parameter.
   
Since the entries in your *mterelay.env* file are inserted into your *Docker* image as environment
variables, they must be formatted in a specific way.  The prefix `APP_SETTINGS` must always be
followed by two underscores `__` and then the actual environment variable name. The entire *tag* must
be in `UPPERCASE` and there can be no spaces surrounding the equals sign *(`=`)*.

#### Minimal Configuration Example for your *mterelay.env* file  
```
APP_SETTINGS__UPSTREAM=https://your-api.yourdomain.com
APP_SETTINGS__CLIENT_ID_SECRET=0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
APP_SETTINGS__LICENSE_COMPANY=Your Licensed company
APP_SETTINGS__LICENSE_KEY=YourLicenseKey
APP_SETTINGS__CORS_ORIGINS=https://your-application.yourdomain.com
```
#### Minimal Configuration Example for your *mterelay.env* file when configured as the *Front-End* of a pair of proxied *Mte-Relay Servers*  
```
APP_SETTINGS__UPSTREAM=https://your-api.yourdomain.com
APP_SETTINGS__CLIENT_ID_SECRET=0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
APP_SETTINGS__LICENSE_COMPANY=Your Licensed company
APP_SETTINGS__LICENSE_KEY=YourLicenseKey
APP_SETTINGS__CORS_ORIGINS=https://your-application.yourdomain.com
APP_SETTINGS__OUTBOUND_TOKEN=your_enterprise_token
```
#### Full Configuration Example for your *mterelay.env* file   
```
APP_SETTINGS__UPSTREAM=https://your-api.yourdomain.com
APP_SETTINGS__CLIENT_ID_SECRET=0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
APP_SETTINGS__LICENSE_COMPANY=Your Licensed company
APP_SETTINGS__LICENSE_KEY=YourLicenseKey
APP_SETTINGS__CORS_ORIGINS=https://your-application.yourdomain.com
APP_SETTINGS__CORS_METHODS=GET, POST, PUT, PATCH, DELETE  
APP_SETTINGS__CORS_ALLOWED_HEADERS=x-auth-token
APP_SETTINGS__PORT=8080
APP_SETTINGS__MAX_POOL_SIZE=250
APP_SETTINGS__PASS_THROUGH_ROUTES=/favicon.ico, /health, /version
APP_SETTINGS__MTE_ROUTES=/api/login,/api/credit-card
APP_SETTINGS__HEADERS=x-proxy-header-1:someValue01,x-proxy-header-2:someValue02
APP_SETTINGS__TIMEOUT_SECONDS=120
APP_SETTINGS__MTE_CHUNK_SIZE=1048576
APP_SETTINGS__MTE_USER_AGENT=.Net Mte-Relay
APP_SETTINGS__APP_LOG_LEVEL=info
APP_SETTINGS__SYS_LOG_LEVEL=warning
APP_SETTINGS__LOG_FILE=/logs/mte-relay..log
APP_SETTINGS__CACHE_PROVIDER=Redis
APP_SETTINGS__CACHE_SLIDING_EXPIRATION_MINUTES=15
APP_SETTINGS__REDIS_CONNECTION_STRING=http://my-redis-server:6379
APP_SETTINGS__REDIS_INSTANCE_NAME=MteRelayCache 
APP_SETTINGS__OUTBOUND_TOKEN=your_enterprise_token
```
#### Minimal Configuration Example for your *appsettings.json* file
``` json
{
  "APP_SETTINGS": {
    "LICENSE_COMPANY": "Your Licensed Company", // Licensed company for this specific MTE library.
    "LICENSE_KEY": "YourLicenseKey", // License key for AWS Server
    "UPSTREAM": "https://your-api.yourdomain.com", // The URL of the server that handles the incoming request on behalf of the client in local IIS
    "CLIENT_ID_SECRET": "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF", // Used to aid in "signing" the client id.  
    "CORS_ORIGINS": "https://your-application.yourdomain.com" // Comma separated list of allowed origins into the Mte-Relay.     
  }
}
```
#### Minimal Configuration Example for your *appsettings.json* file when configured as the *Front-End* of a pair of proxied *Mte-Relay Servers*  
``` json
{
  "APP_SETTINGS": {
    "LICENSE_COMPANY": "Your Licensed Company", // Licensed company for this specific MTE library.
    "LICENSE_KEY": "YourLicenseKey", // License key for AWS Server
    "UPSTREAM": "https://your-api.yourdomain.com", // The URL of the server that handles the incoming request on behalf of the client in local IIS
    "CLIENT_ID_SECRET": "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF", // Used to aid in "signing" the client id.  
    "CORS_ORIGINS": "https://your-application.yourdomain.com", // Comma separated list of allowed origins into the Mte-Relay.     
    "OUTBOUND_TOKEN": "your-enterprise-token" // Identifier for all of your incoming traffic.
  }
}
```
#### Full Configuration Example for your *appsettings.json* file
``` json
{
  "APP_SETTINGS": {
    "LICENSE_COMPANY": "Your Licensed Company", // Licensed company for this specific MTE library.
    "LICENSE_KEY": "YourLicenseKey", // License key for AWS Server
    "UPSTREAM": "https://your-api.yourdomain.com", // The URL of the server that handles the incoming request on behalf of the client in local IIS
    "CLIENT_ID_SECRET": "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF", // Used to aid in "signing" the client id.  
    "CORS_ORIGINS": "https://your-application.yourdomain.com", // Comma separated list of allowed origins into the Mte-Relay. 
    "CORS_METHODS": "GET,POST,PUT,PATCH,DELETE", // Comma separated list of the Http Methods that CORS will allow (HEAD and OPTIONS are always allowed).
    "CORS_ALLOWED_HEADERS": "x-auth-token", // These header keys will be allowed by the CORS request.
    "PORT": 8080, // The port that the Mte-Relay server is listening on. 
    "MAX_POOL_SIZE": 250, // Number of empty Mte Encoders and Decoders to initially set up.
    "PASS_THROUGH_ROUTES": "/favicon.ico, /health, /version", // Requests to these routes will be passed through with no protection from MTE.      
    "MTE_ROUTES": "/api/login,/api/credit-card",
    "HEADERS": "x-proxy-header-1:someValue01,x-proxy-header-2:someValue02",
    "TIMEOUT_SECONDS": 120, // Number of seconds before a timeout is thrown. (if 0, timeouts are disabled)
    "MTE_CHUNK_SIZE": 1048576, // Size of a single chunk that Mte will encode or decode. (Recommended is 16K)
    "MTERELAY_USER_AGENT": ".Net MTE-Relay", // If the incoming request has no User-Agent, use this value.
    "APP_LOG_LEVEL": "Info", // Set the log level for Eclypses messages to Warning, Info, Debug, or Verbose
    "SYS_LOG_LEVEL": "Warning", // Set the log level for system messages to Warning, Info, Debug, or Verbose    
    "LOG_FILE": "/logs-mte-relay..log", // If blank or missing, no logs are written to a file, they are only written to the console.
    "CACHE_PROVIDER": "redis", // Determines the State Caching provider - memory or redis
    "CACHE_SLIDING_EXPIRATION_MINUTES": 15, // Number of minutes that a "cached" MTE State will stay alive (this is a sliding expiration). (Default is 15)
    "REDIS_CONNECTION_STRING": "http://my-redis-server:6379", // If we are using Redis for caching, this is the connection string.
    "REDIS_INSTANCE_NAME": "MteRelayCache", // If we are using Redis for caching, this is the instance name.
    "OUTBOUND_TOKEN": "your-enterprise-token" // Identifier for all of your incoming traffic.
  }
}
```
### MTE State Cache Persistent Storage
By default, MTE State is saved in-memory. This means that if the server is restarted, all MTE State will be lost. 
To persist MTE State across server restarts, or to share MTE state between multiple containers, 
you must use an external cache by configuring *Redis* as your cache service. The *Mte-Relay* can utilize *Memory* or *Redis* to maintain the connection state.  
The *appsetting* `CACHE_PROVIDER` determines which caching scheme you wish to use.
The *appsetting* `CACHE_SLIDING_EXPIRATION_MINUTES` controls how long a cached item remains available.  
The internal state of the active connections to the *MTE-Relay* are kept in that cache, so if they are flushed (after the sliding expiration has passed), the client must re-establish
its pairing.
This is handled internally by the *Mte-Relay Servers* and is provided here for reference only.
If you are using the *Mte-Relay Server* as a proxy from your outside application (browser or mobile), you probably want to set the `CACHE_SLIDING_EXPIRATION_MINUTES` to
a reasonable value that you feel will encompass the amount of *wait-time* an end user may experience between interactions. 15 minutes seems like a reasonable value,
but you may wish to adjust this based on your expected experience.  
If you are using the *Mte-Relay Server* in a *Front-End / Back-End* pair where the communication sessions between the two *Mte-Relay Servers* need to be pretty persistent, you
may wish to adjust this setting to a longer duration which will decrease the amount of traffic between the two due to expired *cache* entries.  
Keep in mind, that if either end of a conversation has *timed out* its cache, the two ends of the conversation will re-establish pairing.  This is completely isolated from
the user experience, but it does add a bit of overhead to the process.

#### Memory Caching
No additional configuration options are required, however, this is *NOT* persistent so be advised that any cached values will be gone in the event of a restart.

#### Redis Caching
This is a persistent and high-performance caching system.  It does require some configuration, that must be in your *mterelay.env* file. 
Sample entires follow:
```
APP_SETTINGS__REDIS_CONNECTION_STRING=http://my-redis-server:6379
APP_SETTINGS__REDIS_INSTANCE_NAME=MteRelayCache    
```
or for *appsettings.json*
``` json
"REDIS_CONNECTION_STRING": "http://my-redis-server:6379", // If we are using Redis for caching, this is the connection string.
"REDIS_INSTANCE_NAME": "MteRelayCache" // If we are using Redis for caching, this is the instance name.
```

This also requires that you set your *appsetting* properly.  The `CACHE_PROVIDER` must be *Redis*.  
If you are running *Redis* from a container, ensure that the port in your `REDIS_CONNECTION_STRING` is exposed from
your container.  Also, ensure that the `--name` parameter in your *docker run* command matches the `REDIS_INSTANCE_NAME`.  
An example *docker run* command might look like this:
``` sh
docker run --name MteRelayCache -p 6379:6379 -d redis redis-server --save 60 1 --loglevel warning
```
### Application Logs 
MTE Relay Server is built in *ASP.Net 9.0*, and uses [Serilog](https://serilog.net) for logging. 
By default, no logs are written to a file, but that can be overridden with a `LOG_FILE` entry in your configuration.
Logs are always written to the console which is the `stdout` device.
### Different Use Cases 
As mentioned, the *Mte-Relay Server* may be used in a couple of different use cases.
#### Mte-Relay Server as Proxy
When utilizing the *Mte-Relay Server* as a simple *Front-End* proxy, you only need a single instance that is exposed to the *internet*.  This requires an
application that uses the *Mte-Relay Client* to initially protect the information, and this single instance of the *Mte-Relay Server* will 
reveal the incoming traffic from the application and forward it on to the location that you configured in your `UPSTREAM` address in the configuration.
No changes are required in your destination API (`UPSTREAM`). The results from your destination API will be protected and returned to the *Mte-Relay Client* that
is part of your application.
#### Mte-Relay Server as Reverse Proxy
When utilizing the *Mte-Relay Server* as a reverse proxy you will end up with at least a pair of *Mte-Relay Servers*. In this case, your `OUTBOUND_TOKEN` becomes
important. This token does NOT expose any information that is used as part of the protection scheme, but rather it is used as an identifier to ensure that
proxied traffic belongs to your enterprise.  
The usage of the `OUTBOUND_TOKEN` is detailed below:
- First of all, the *Mte-Relay Server* must be configured in the *Front-End* instance of the *Mte-Relay Server* pairs. If it is not configured, then the 
  specific instance of the *Mte-Relay Server* serves as a simple proxy as described above.
- Your API service that sends http traffic to the *Front-End* must include two headers.  This is the only change that is required to your originating API.
  - `x-mte-outbound-token` This header must be the same as the configured `OUTBOUND_TOKEN` in your *Front-End Mte-Relay Server*.
  - `x-mte-upstream` This header must contain the address of the *Mte-Relay Server* that is acting as the *Back-End* of the pair.  
#### Information Flow
If your *Mte-Relay Server* receives an http request with these two headers, it does the following:
- The `x-mte-outbound-token` is inspected to ensure that it matches the configured `OUTBOUND_TOKEN` of the *Front-End Mte-Relay Server*.
- A lookup is done to ensure that the `x-mte-upstream` is a valid partner and then ensures that they are *paired* and ready to communicate.
- The incoming traffic from your API is protected with the *Eclypses MTE*.
- The protected request is forwarded to the paired *Mte-Relay Server Back-End*.
- The *Back-End Mte-Relay Server* reveals the incoming traffic and forwards it to the `UPSTREAM` service that you configured in your *Back-End*.
- Your `UPSTREAM` service processes the request and returns a response.
- The *Back-End Mte-Relay Server* conceals the response from your `UPSTREAM` service and returns it to the *Front-End Mte-Relay Server*.
- The response from the *Back-End Mte-Relay Server* is then revealed and returned to your origination API.  
#### Simple Configuration  
Breaking down the configuration that you must have in place is rather straight forward.
- Ensure that your *Front-End Mte-Relay Server* has your enterprise `OUTBOUND_TOKEN` configured.
- Ensure that each *Back-End Mte-Relay Server* has been configured to communicate with your destination API in its `UPSTREAM` value.
- Ensure that your originating API requests have the following two headers:
  - `x-mte-outbound-token` must match the *Front-End Mte-Server* `OUTBOUND_TOKEN`.
  - `x-mte-upstream` must be the address of your paired *Back-End Mte-Server*.  
#### Multiple Destinations
You may have multiple services that your originating API must converse with.  That is accomplished by simple configuration.  
The address in the `x-mte-upstream` header of each individual request determines which *Back-End Mte-Relay Server* the protected traffic is sent to.  
The address of the `UPSTREAM` service in any individual *Back-End Mte-Relay Server* determines where a request is ultimately processed.
#### Example
A straight forward example might be if your origination API *(PurchaseAPI)* is running in *CloudService A* at http://purchase.mydomain.com and
it must send customer purchase requests to another API *(CustomerAPI)* that is running in *CloudService B* at http://customer.mydomain.com as well as
an accounting service *(AccountingAPI)* that is running in *CloudService C* at http://accounting.mydomain.com the setup is as follows:
##### CustomerAPI
- Install an *Mte-Relay Server* in this instance at *CloudService B*.
- Expose this service as *http://mte-customer.mydomain.com*. 
- Set all necessary configuration as detailed above.
- Set the `UPSTREAM` value to *http://customer.mydomain.com*.
- No changes are required to your service at *http://customer.mydomain.com*.
##### AccountingAPI
- Install an *Mte-Relay Server* in this instance at *CloudService C*.
- Expose this service as *http://mte-accounting.mydomain.com*.
- Set all necessary configuration as detailed above.
- Set the `UPSTREAM` value to *http://accounting.mydomain.com*.
- No changes are required to your service at *http://accounting.mydomain.com*.
##### PurchaseAPI
- Install an *Mte-Relay Server* in this instance at *CloudService A*.
- Expose this service as *http://mte-purchase.mydomain.com*.
- Set all necessary configuration as detailed above.
- Set the `UPSTREAM` value to *http://purchase.mydomain.com*.
- No changes are required to your service at *http://purchase.mydomain.com*.
##### EnterpriseProxy
- Install an additional *Mte-Relay Server* in this instance at *CloudService A*.
- Expose this service as *http://mte-enterprise-proxy.mydomain.com*.
- Set all necessary configuration as detailed above.
- Set the `OUTBOUND_TOKEN` to *my-enterprise-outbound-token*.
#### Incoming Requests 
- For any requests that previously were sent from other applications to *http://purchase.mydomain.com*.
  - Set the two headers:
    - `x-mte-outbound-token` to *my-enterprise-outbound-token*.
    - `x-mte-upstream`  to *http://mte-purchase.mydomain.com*
  - Send the request to *http://mte-enterprise-proxy.mydomain.com*.
- For any requests that previously were sent from other applications to *http://customer.mydomain.com*.
  - Set the two headers:
    - `x-mte-outbound-token` to *my-enterprise-outbound-token*.
    - `x-mte-upstream`  to *http://mte-customer.mydomain.com*
  - Send the request to *http://mte-enterprise-proxy.mydomain.com*.
- For any requests that previously were sent from other applications to *http://accounting.mydomain.com*.
  - Set the two headers:
    - `x-mte-outbound-token` to *my-enterprise-outbound-token*.
    - `x-mte-upstream`  to *http://mte-accounting.mydomain.com*
  - Send the request to *http://mte-enterprise-proxy.mydomain.com*.
## Conclusion
The *Eclypses MTE* technology offers a quantum resistant means of ensuring that all traffic between endpoints in an
enterprise system are protected from any and all current threats. All of this is accomplished by installing the appropriate
cloud services and minimal configuration. For more information, please visit our web site at [Eclypses.com](https://www.eclypses.com).