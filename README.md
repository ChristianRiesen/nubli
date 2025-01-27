# Nubli

Nubli is a Node.JS library for Nuki Smart Locks (**Nu**ki **B**luetooth **Li**brary)
Nubli is very energy efficient when used properly and should't drain more power than a Nuki bridge. It uses the same protocol the App and Bridge uses and therefore communicates securely with the Smart Lock.

[![NPM](https://nodei.co/npm/nubli.png?compact=true)](https://npmjs.org/package/nubli)

# Features
* Get Lock State of Nuki Smart Lock (including door sensor)
* Unlock/Lock/Unlatch/LockNGo Door
* Listen for Lock State and Door Sensor changes
* Get Authorizations
* Get Configuration
* Get Advanced Configuration

# Supported devices
- Nuki Smart Lock v2
- Nuki Smart Lock v1 (not yet 100% compatible - Please open an issue if something doesn't work)

# Requirements
- Linux-based Server (e.g. Raspberry Pi)
- Bluetooth 4.x Dongle (Tested with $5 CSR Module)

**Note**: Do not use the built-in Bluetooth in a Raspberry Pi. Due to bad hardware design it will not reliably connect to your Smart Lock and cause unexpected disconnects. I've been there and invested a whole week into fixing it.

# Setup / Installation

## Using Docker

You can use the docker-compose.yml as a starting point, or run it directly with the following command:

```
docker run -d \
   --name nubli \
   --restart=unless-stopped \
   -p 9180:8080 \
   -v /changeme:/app/dist/lib/config \
   christianriesen/nubli
```

Notes:
- Default port is 8080, so you need to expose that to the outside. Alternatively you can also configure the internal port if you give it an env of `PORT` with the value you want it to have (inside the container). In the above example it assumes the default port internally and maps it to 9180 on the host.
- The config directory will save the data about the locks the server has. If you run into trouble you can check that data or delete them entirely and the server will "forget" a lock. Change the left portion to something that makes sense for you.
- This will try to run the docker container and keep it running even after a reboot.


## Using NPM
1. `npm install nubli --save`
2. See [Examples](examples/) or [Usage](#usage)
3. Star the repository ;)

# Notes
* You can only run one instance of this library simultaneously with one dongle. If want to integrate this library into multiple applications running at the same time on the same device, either pin the applications to different bluetooth dongles or communicate with a single instance of this library via a webserver/websocket/mqtt instead.

# Included server usage

If you wish to run it (see docker above for example) as a server, then Nubli will supply some endpoints for you to connect to a lock and manage it.

The parameter `:name` needs to be replaced with the name of the lock, same as you may have used it in the app. I'd suggest not using spaces or special characters.

`/:name/status` Returns the current status of the lock, locked or unlocked.

`/:name/lock` Locks the door.

`/:name/unlock` Unlocks the door.

`/:mac/pair/:name` Used for pairing. You have to replace `:mac` with the locks MAC address. Put the MAC address all lower case and no spaces or : characters, just one long string. The server internally will remove them but some clients/browsers might do things to the url you might not want to happen when you do this. Set the lock into pairing mode (long press button until it flashes) then call this action to pair the lock. You can use the status route to see if it worked.

# Library Usage
```typescript
    const nubli = require('nubli').default;

    nubli.onReadyToScan()
    .then(() => {
        nubli.startScanning();
    })
    .catch((err) => {
        console.log(err);
    });
```

## Actions

### Start Scanning for Nuki devices
```typescript
    nubli.startScanning(): void;
```

### Start Actively Scanning for Nuki devices (Required for pairing)
```typescript
    nubli.startActiveScanning(): void;
```

**Notes**:
* Scanning requires the bluetooth device to be powered on. This may take a few milliseconds. Make sure to wait for the promise ```nubli.readyToScan()``` to resolve first.
* Only use active scanning when you are trying to pair a new device. Active Scanning will drain your Smart Lock's battery very quickly. Passive Scanning only listens for advertisements from the Smart Lock and does not request additionaly information from the Smart Lock.

### Stop Scanning for Nuki devices
```typescript
    nubli.stopScanning(): void;
```

### Connect to a Smart Lock
```typescript
    smartlock.connect(): Promise<void>;
```

### Disconnect from a Smart Lock
```typescript
    smartlock.disconnect(): Promise<void>;
```

### Check if a config for the Smart Lock already exists
```typescript
    smartlock.configExists(path?: string): boolean;
```

### Read Smart Lock config
```typescript
    smartlock.readConfig(path?: string): Promise<void>;
```

### Save Smart Lock config
```typescript
    smartlock.saveConfig(path?: string): Promise<void>;
```

### Pair with a Smart Lock
```typescript
    smartlock.pair(asBridge = true): Promise<void>;
```

**Note**: By default it will pair as bridge. If you do have a bridge, make sure to pass false as a parameter. The reason is, that when no bridge exists, Nuki will not push any state changes automatically via advertisements, so we set ourselves as a bridge instead.

### Read lock state from Smart Lock
```typescript
    smartlock.readLockState(): Promise<SmartLockResponse>;
```

### Unlock door
```typescript
    smartlock.unlock(updateCallback?: (response: SmartLockResponse) => void): Promise<SmartLockResponse>;
```

### Lock door
```typescript
    smartlock.lock(updateCallback?: (response: SmartLockResponse) => void): Promise<SmartLockResponse>;
```

### Unlatch Door
```typescript
    smartlock.unlatch(updateCallback?: (response: SmartLockResponse) => void): Promise<SmartLockResponse>;
```

### Lock N Go Door
```typescript
    smartlock.lockNGo(updateCallback?: (response: SmartLockResponse) => void): Promise<SmartLockResponse>;
```

### Lock N Go Unlatch Door
```typescript
    smartlock.lockNGoUnlatch(updateCallback?: (response: SmartLockResponse) => void): Promise<SmartLockResponse>;
```

### Get Config from Smart Lock
```typescript
    smartlock.requestConfig(): Promise<SmartLockResponse>;
```

### Get Advanced Config from Smart Lock
```typescript
    smartlock.requestAdvancedConfig(): Promise<SmartLockResponse>;
```

## Properties

### Check whether a Smart Lock is already paired
```typescript
    smartlock.paired: boolean;
```
## Events

### Nubli Smart Lock Discovered Event
```typescript
    nubli.on('smartLockDiscovered', (smartlock: SmartLock) => void);
```

### Nubli started scanning
```typescript
    nubli.on('startedScanning', () => void);
```

### Nubli stopped scanning
```typescript
    nubli.on('stoppedScanning', () => void);
```

### Smart Lock Connected Event
```typescript
    smartlock.on('connected', () => void);
```

### Smart Lock Disconnected Event
```typescript
    smartlock.on('disconnected', () => void);
```

### Smart Lock Error Event
```typescript
    smartlock.on('error', (err: string) => void);
```

### Smart Lock Activity Log Changed Event
```typescript
    smartlock.on('activityLogChanged', () => void);
```

**Note**: The `activityLogChanged` event only works while scanning because the Smart Lock advertises activity log changes via bluetooth. To get notified when the door opens or closes (Door Sensor) make sure to enable 'Log door sensor status' in the Nuki app.

# Help
If you have any questions or help please open an issue on the GitHub project page.

# Contributing
Pull requests are always welcome. If you have an issue or feature request please open a GitHub issue.

# License
The project is subject to the MIT license unless otherwise noted. A copy can be found in the root directory of the project [LICENSE](LICENSE).
