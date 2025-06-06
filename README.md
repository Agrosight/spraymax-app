# Projeto ArboMonitor

ArboMonitor Project.

### Atenção:
<p>Sempre que alterado/acrescentado método em qualquer arquivo <strong>_controller.dart</strong> o seguinte comando deve ser rodado no terminal:
</p>

> ```flutter pub run build_runner build```

### Tokens Mapbox

Em ~/.gradle/gradle.properties:
```
MAPBOX_ACCESS_TOKEN=YOUR_PUBLIC_MAPBOX_ACCESS_TOKEN
MAPBOX_DOWNLOADS_TOKEN=YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

## Configuração do dispositivo dedicado

### Definir o aplicativo como proprietário do dispositivo:

Verifique no "AndroidManifest.xml" se está instalado como teste:
```xml
<manifest ...>
    ...
    <application
        android:testOnly="true">
        ...
    </application>
    ...
</manifest>
```
Se não estiver, essa alteração não poderá ser desfeita!

Adicione a pasta 'Android/Sdk/platform-tools' ao `$PATH`.

Verifique se o dispositivo está conectado:

```sh
$ adb devices
```
Defina o ArboMonitor como proprietário do dispositivo:
```sh
$ adb shell dpm set-device-owner br.com.farmgo.arbomonitor/.ArboMonitorAdmRcvr
```
Não pode haver nenhuma conta resgistrada.

Se der certo, será exibido:
```sh                                  
Success: Device owner set to package br.com.farmgo.arbomonitor/.ArboMonitorAdmRcvr
Active admin set to component br.com.farmgo.arbomonitor/.ArboMonitorAdmRcvr
```

Para desfazer:
```sh
$ adb shell dpm remove-active-admin br.com.farmgo.arbomonitor/.ArboMonitorAdmRcvr
```

## Android Management API
[Quickstart](https://colab.research.google.com/github/google/android-management-api-samples/blob/master/notebooks/quickstart.ipynb)

[Create a policy](https://developers.google.com/android/management/create-policy)

[Example policies: dedicated devices](https://developers.google.com/android/management/policies/dedicated-devices)

Criar arquivo `.env`:
```
{
  "type": "service_account",
  "project_id": "dengue-419820",
  "private_key_id": "[...]",
  "private_key": "-----BEGIN PRIVATE KEY-----\n[...]\n-----END PRIVATE KEY-----\n",
  "client_email": "[...]",
  "client_id": "[...]",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/[...]",
  "universe_domain": "googleapis.com"
}
```

Demonstração:
```sh
$ python3 android_management.py
```

## Comandos Úteis
`adb shell dumpsys device_policy | grep "admin"`
```
admin=ComponentInfo{br.com.farmgo.arbomonitor/br.com.farmgo.arbomonitor.ArboMonitorAdmRcvr}
```

`adb shell "dumpsys device_policy | grep package"`
```
package=br.com.farmgo.arbomonitor
  critical packages: 1 app
  launcher packages: 2 apps
  input method packages: 2 apps
  SMS package: null
  Settings package: com.android.settings
config_packagesExemptFromSuspension: 1 app
```

`adb uninstall br.com.farmgo.arbomonitor`

https://developer.android.com/tools/logcat Logcat com filtros:

`adb logcat "libPowerHal:S AES:S thermal_repeater:S AlarmManagerService:S NearbyDiscovery:S MtpFfsHandle:S BufferQueueProducer:S ccci_mdinit:S hwcomposer:S ExplicitHealthCheckController:S PackageWatchdog:S TapAndPay:S SensorManager:S Accelerometer:S NetworkSecurityConfig:S SensorService:S AAL:S libPerfCtl:S DeviceIdleController:S Finsky:S NetworkScheduler:S Finsky:S FlutterGeolocator:S libMEOW:S Choreographer:S BestClock:S PowerHalWrapper:S mtkpower_client:S BufferQueueDebug:S BackupTransportManager:S BackupManagerService:S NearbySharing:S BackupManagerConstants:S GraphicsEnvironment:S CompatibilityChangeReporter:S TransportClient:S ResourceExtractor:S" | grep "rbo"`