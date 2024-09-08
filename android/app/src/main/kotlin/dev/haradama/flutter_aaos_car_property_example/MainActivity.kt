package dev.haradama.flutter_aaos_car_property_example

import android.car.Car
import android.car.hardware.property.CarPropertyManager
import android.content.ComponentName
import android.content.ServiceConnection
import android.os.IBinder
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "dev.haradama.flutter_aaos_car_property_example/car"
    private var carPropertyManager: CarPropertyManager? = null
    private lateinit var car: Car

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the method channel to communicate with Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Initialize CarPropertyManager when called
                "initializeCarManager" -> {
                    initializeCarManager()
                    result.success("Car Manager Initialized")
                }
                // Get a property from the car using its property ID and area ID
                "getCarProperty" -> {
                    if (carPropertyManager == null) {
                        result.error("CAR_SERVICE_NOT_READY", "CarPropertyManager is not initialized", null)
                        return@setMethodCallHandler
                    }
                    val propertyId = call.argument<Int>("propertyId")
                    val areaId = call.argument<Int>("areaId")
                    if (propertyId != null && areaId != null) {
                        val value = getCarProperty(propertyId, areaId)
                        result.success(value)
                    } else {
                        result.error("INVALID_ARGUMENTS", "PropertyId and AreaId are required", null)
                    }
                }
                // Set a property on the car using its property ID, area ID, and value
                "setCarProperty" -> {
                    if (carPropertyManager == null) {
                        result.error("CAR_SERVICE_NOT_READY", "CarPropertyManager is not initialized", null)
                        return@setMethodCallHandler
                    }
                    val propertyId = call.argument<Int>("propertyId")
                    val areaId = call.argument<Int>("areaId")
                    val value = call.argument<Any>("value")
                    if (propertyId != null && areaId != null && value != null) {
                        result.success(setCarProperty(propertyId, areaId, value))
                    } else {
                        result.error("INVALID_ARGUMENTS", "PropertyId, AreaId, and Value are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Initialize the CarPropertyManager to manage car properties
    private fun initializeCarManager() {
        car = Car.createCar(this, null, Car.CAR_WAIT_TIMEOUT_DO_NOT_WAIT) { car, ready ->
            if (ready) {
                carPropertyManager = car.getCarManager(Car.PROPERTY_SERVICE) as CarPropertyManager
            }
        }
    }

    // Retrieve a car property value based on the propertyId and areaId
    private fun getCarProperty(propertyId: Int, areaId: Int): Any? {
        return try {
            // Check if the property is available
            if (carPropertyManager?.isPropertyAvailable(propertyId, areaId) != true) {
                return "Property not available for propertyId: $propertyId, areaId: $areaId"
            }
    
            val config = carPropertyManager?.getCarPropertyConfig(propertyId)
            config?.let {
                // Handle different property types (Boolean, Int, Float)
                when (it.propertyType) {
                    Boolean::class.javaPrimitiveType, java.lang.Boolean::class.java -> {
                        carPropertyManager?.getBooleanProperty(propertyId, areaId)
                    }
                    Int::class.javaPrimitiveType, Integer::class.java -> {
                        carPropertyManager?.getIntProperty(propertyId, areaId)
                    }
                    Float::class.javaPrimitiveType, java.lang.Float::class.java -> {
                        carPropertyManager?.getFloatProperty(propertyId, areaId)
                    }
                    else -> {
                        "Unsupported property type: ${it.propertyType}"
                    }
                }
            }
        } catch (e: IllegalArgumentException) {
            e.printStackTrace()
            "Invalid property type. ${e.message}"
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    // Set a car property based on the propertyId, areaId, and value
    private fun setCarProperty(propertyId: Int, areaId: Int, value: Any): String {
        return try {
            // Check if the property is available
            if (carPropertyManager?.isPropertyAvailable(propertyId, areaId) != true) {
                return "Property not available for propertyId: $propertyId, areaId: $areaId"
            }

            val config = carPropertyManager?.getCarPropertyConfig(propertyId)
            config?.let {
                // Handle setting different property types (Boolean, Int, Float)
                when (it.propertyType) {
                    Boolean::class.javaPrimitiveType, java.lang.Boolean::class.java -> {
                        if (value is Boolean) {
                            carPropertyManager?.setBooleanProperty(propertyId, areaId, value)
                            "Property set successfully"
                        } else {
                            "Invalid value type. Expected Boolean."
                        }
                    }
                    Int::class.javaPrimitiveType, Integer::class.java -> {
                        if (value is Int) {
                            carPropertyManager?.setIntProperty(propertyId, areaId, value)
                            "Property set successfully"
                        } else {
                            "Invalid value type. Expected Int."
                        }
                    }
                    Float::class.javaPrimitiveType, java.lang.Float::class.java -> {
                        if (value is Float) {
                            carPropertyManager?.setFloatProperty(propertyId, areaId, value)
                            "Property set successfully"
                        } else {
                            "Invalid value type. Expected Float."
                        }
                    }
                    else -> {
                        "Unsupported property type: ${it.propertyType}"
                    }
                }
            } ?: "Property configuration not found"
        } catch (e: IllegalArgumentException) {
            e.printStackTrace()
            "Invalid property type. ${e.message}"
        } catch (e: Exception) {
            e.printStackTrace()
            "Failed to set property. ${e.message}"
        }
    }
}
