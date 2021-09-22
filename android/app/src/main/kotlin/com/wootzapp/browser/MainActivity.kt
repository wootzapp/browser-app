package com.wootzapp.browser

//import jdk.nashorn.api.scripting.JSObject

import androidx.annotation.Nullable
import androidx.annotation.VisibleForTesting
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import java.io.IOException
import java.io.InputStream
import java.util.*



class MainActivity : FlutterActivity() {

////    GeneratedPluginRegistrant.registerWith(this);
////
////    String CHANNEL = "UNIQUE_CHANNEL_NAME";
//private val CHANNEL = "getWallet"
//
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
//            // Note: this method is invoked on the main thread.
//            call, result ->
//            if (call.method == "getWalletFromMnemonic") {
//
//                val mnemonic = call.arguments as String
//
//
//                var walletFromMnemonic = getWalletFromMnemonic(mnemonic)
//                if (walletFromMnemonic == null) {
//                    result.error("Could not create", "Wallet generation failed", null)
//                    return@setMethodCallHandler
//                }
//
//
//                val privateKey: String = walletFromMnemonic.property("privateKey").toString()
//                val address: String = walletFromMnemonic.property("address").toString()
//
//                val map: HashMap<String?, String?> = HashMap()
//                map["privateKey"] = privateKey
//                map["address"] = address
//
//                val obj = JSONObject(map as Map<*, *>)
//
//                result.success(obj.toString())
//
////
//
//            }
//
//        }
//    }
//    fun jsTypeOf(o: Any): String {
//        return js("typeof o")
//    }
//    @Nullable
//    @VisibleForTesting
//    private fun getWalletFromMnemonic(mnemonic: String): Objects? {
//        val jsContext: Objects = getJsContext(getEther())
//        val wallet: JSONObject = getWalletObject(jsContext) ?: return null
//        if (!wallet.hasProperty("fromMnemonic")) {
//            return null
//        }
//        val walletFunction: JSFunction = wallet.property("fromMnemonic").toObject().toFunction()
//        return walletFunction.call(null, mnemonic).toObject()
//    }
//
//    @Nullable
//    @VisibleForTesting
//    private fun getWalletObject(context: JSContext): JSObject? {
//        val jsEthers: JSObject = context.property("ethers").toObject()
//        return if (jsEthers.hasProperty("Wallet")) {
//            jsEthers.property("Wallet").toObject()
//        } else null
//    }
//
//    @VisibleForTesting
//    fun getEther(): String? {
//        var s: String? = ""
//        val ins: InputStream = resources.openRawResource(R.raw.ethers)
//        try {
//            s = IOUtils.toString(ins)
//        } catch (e: IOException) {
//            s = null
//            e.printStackTrace()
//
//        return s
//    }
//
//    @VisibleForTesting
//    fun getJsContext(code: String?): JSContext {
//        val context = JSContext()
//        context.evaluateScript(code)
//        return context
//    }
}
