package br.com.farmgo.arbomonitor

import android.app.ActivityOptions
import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.content.Intent
import android.content.IntentFilter
import android.os.UserManager
import br.com.farmgo.arbomonitor.MainActivity

class ArboMonitorAdmRcvr : DeviceAdminReceiver() {
  private val PKG = "br.com.farmgo.arbomonitor"
  private val options = ActivityOptions.makeBasic()

  override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
    println("D: ArboMonitorAdmRcvr.onProfileProvisioningComplete()")
    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    val componentName = getWho(context)
    dpm.setProfileName(componentName, context.getString(R.string.device_admin))
    val launch = Intent(context, MainActivity::class.java)
    launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    context.startActivity(launch)
  }

  override fun onReceive(context: Context, intent: Intent) {
    println("D: ArboMonitorAdmRcvr.onReceive(): context = $context | intent = $intent")
    val filter = IntentFilter(Intent.ACTION_MAIN)
    filter.addCategory(Intent.CATEGORY_HOME)
    filter.addCategory(Intent.CATEGORY_DEFAULT)
    val activity = ComponentName(context, MainActivity::class.java)
    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    val adminName = getWho(context)
    if (!dpm.isDeviceOwnerApp(PKG)){
      println("D: ArboMonitorAdmRcvr.onReceive: isDeviceOwnerApp = false")
      return
    }
    else {
      println("D: ArboMonitorAdmRcvr.onReceive: isDeviceOwnerApp = true")
    }
    dpm.addPersistentPreferredActivity(adminName, filter, activity)
    dpm.setLockTaskPackages(adminName, arrayOf(
        PKG, 
        "com.android.systemui", 
        "com.android.settings", 
        "com.android.cellbroadcastreceiver", 
        "com.android.cellbroadcastservice", 
        "com.android.cellbroadcastreceiver.module"
    ))
    dpm.setLockTaskFeatures(
      adminName,
      DevicePolicyManager.LOCK_TASK_FEATURE_GLOBAL_ACTIONS or
      DevicePolicyManager.LOCK_TASK_FEATURE_SYSTEM_INFO
    )
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_ADD_PRIVATE_PROFILE)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_ADD_USER)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_APPS_CONTROL)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_ASSIST_CONTENT)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_BLUETOOTH_SHARING)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CAMERA_TOGGLE)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_CREDENTIALS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_DEFAULT_APPS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_PRIVATE_DNS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_SCREEN_TIMEOUT)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_TETHERING)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONFIG_VPN)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONTENT_CAPTURE)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CONTENT_SUGGESTIONS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_CREATE_WINDOWS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_FACTORY_RESET)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_FUN)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_GRANT_ADMIN)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_INSTALL_APPS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_MICROPHONE_TOGGLE)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_MODIFY_ACCOUNTS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_MOUNT_PHYSICAL_MEDIA)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_NEAR_FIELD_COMMUNICATION_RADIO)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_OUTGOING_BEAM)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_OUTGOING_CALLS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_PRINTING)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_REMOVE_USER)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SET_USER_ICON)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SAFE_BOOT)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SET_WALLPAPER)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SHARE_INTO_MANAGED_PROFILE)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SHARING_ADMIN_CONFIGURED_WIFI)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_SYSTEM_ERROR_DIALOGS)
    dpm.addUserRestriction(adminName, UserManager.DISALLOW_UNINSTALL_APPS)
    dpm.setScreenCaptureDisabled(adminName, true)
    dpm.setShortSupportMessage(adminName, "Ação não permitida.\nEntre em contato com a FarmGO para mais informações.")
    dpm.setLongSupportMessage(adminName, "FarmGO Agro Solutions")
    println("D: Lock task is permitted: ${dpm.isLockTaskPermitted(PKG)}")
    options.setLockTaskEnabled(true)
    super.onReceive(context, intent)
  }
  
  fun setDebug(context: Context) {
    println("D: ArboMonitorAdmRcvr.setDebug(): context = $context")
    val dpm : DevicePolicyManager = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    val adminName = getWho(context)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_ADD_PRIVATE_PROFILE)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_ADD_USER)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_APPS_CONTROL)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_ASSIST_CONTENT)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_BLUETOOTH_SHARING)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CAMERA_TOGGLE)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_CREDENTIALS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_DEFAULT_APPS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_PRIVATE_DNS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_SCREEN_TIMEOUT)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_TETHERING)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONFIG_VPN)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONTENT_CAPTURE)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CONTENT_SUGGESTIONS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_CREATE_WINDOWS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_FACTORY_RESET)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_FUN)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_GRANT_ADMIN)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_INSTALL_APPS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_INSTALL_UNKNOWN_SOURCES)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_MICROPHONE_TOGGLE)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_MODIFY_ACCOUNTS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_MOUNT_PHYSICAL_MEDIA)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_NEAR_FIELD_COMMUNICATION_RADIO)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_OUTGOING_BEAM)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_OUTGOING_CALLS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_PRINTING)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_REMOVE_USER)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SET_USER_ICON)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SAFE_BOOT)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SET_WALLPAPER)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SHARE_INTO_MANAGED_PROFILE)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SHARING_ADMIN_CONFIGURED_WIFI)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SYSTEM_ERROR_DIALOGS)
    dpm.clearUserRestriction(adminName, UserManager.DISALLOW_UNINSTALL_APPS)
    options.setLockTaskEnabled(false)
  }
}
