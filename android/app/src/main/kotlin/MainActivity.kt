package br.com.farmgo.arbomonitor
import android.content.ComponentName
import android.content.pm.PackageManager
import android.Manifest
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle

class MainActivity: FlutterActivity() {
    companion object {
        private var debug : Boolean = false;
        private var dedicated : Boolean = false;
        private val TAG:String = "arbomonitor";
    }

    private val channel = "br.com.farmgo.arbomonitor/channel";
    private val adminName = ComponentName("br.com.farmgo.arbomonitor", "ArboMonitorAdmRcvr");
    private var frames = Array<ByteArray>(5){ByteArray (0)}
    private var fileId : Int = 0;
    external fun getStringFromNative(): String
    external fun decodeJpeg(buffer:ByteArray, length: Int): String
    external fun mergeFrames(frames:Array<ByteArray>, path: String): Int
    external fun segmentImage(pathOrig:String, debug:Boolean): IntArray

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "setDebug" -> result.success(ArboMonitorAdmRcvr().setDebug(this))
                "getPhoto" -> result.success(getPhoto(call.argument<Int>("frame")!!) as ByteArray)
                "getFileId" -> result.success(getFileId(call.argument<String>("path")!!) as Int);
                "segmentImage" -> result.success(segmentImageCall(call.argument<String>("pathOrig")!!) as IntArray);
                "setDedicated" -> result.success(setDedicated())
                else -> result.notImplemented()
            }
        }
    }

    fun segmentImageCall(pathOrig: String): IntArray {
        return segmentImage(pathOrig, debug);
    }

    fun getFileId(path: String):Int{
        fileId = mergeFrames(frames, path);
        Log.d(TAG, "id: $fileId");
        return fileId;
    }

    fun getPhoto(frame: Int): ByteArray {
        return ByteArray(0)// byteArray
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        println("D: MainActivity created")
    }

    override fun onResume(){
        super.onResume()
        println("D: MainActivity.onResume()")
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    fun setDedicated(): Boolean {
        return true
    }
}
