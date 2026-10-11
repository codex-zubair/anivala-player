package com.codexzubair.aniloom

import android.content.ContentUris
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.codexzubair.aniloom/scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "queryVideos" -> result.success(queryVideos())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Queries the MediaStore for local video files. Runs entirely on-device;
     * no network access is involved.
     */
    private fun queryVideos(): List<Map<String, Any?>> {
        val videos = mutableListOf<Map<String, Any?>>()

        val collection = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }

        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.SIZE
        )

        val selection = "${MediaStore.Video.Media.IS_PENDING} != 1"
        val sortOrder = "${MediaStore.Video.Media.DISPLAY_NAME} ASC"

        contentResolver.query(collection, projection, selection, null, sortOrder)
            ?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                val nameColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
                val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
                val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)

                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idColumn)
                    val data = cursor.getString(dataColumn) ?: continue
                    val uri = ContentUris.withAppendedId(collection, id)
                    videos.add(
                        mapOf(
                            "id" to id.toString(),
                            "name" to cursor.getString(nameColumn),
                            "path" to data,
                            "uri" to uri.toString(),
                            "duration" to cursor.getLong(durationColumn),
                            "size" to cursor.getLong(sizeColumn)
                        )
                    )
                }
            }

        return videos
    }
}
