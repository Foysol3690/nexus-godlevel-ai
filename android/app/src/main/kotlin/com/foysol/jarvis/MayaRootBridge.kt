package com.foysol.jarvis

import java.util.concurrent.TimeUnit

object MayaRootBridge {
    fun status(): Map<String, Any?> {
        val result = run(listOf("su", "-c", "id"))
        return mapOf("success" to true, "available" to (result.first && result.second.contains("uid=0")), "output" to result.second.take(160))
    }
    fun tap(x: Int, y: Int) = action("input tap ${x.coerceAtLeast(0)} ${y.coerceAtLeast(0)}")
    fun swipe(sx: Int, sy: Int, ex: Int, ey: Int, duration: Int) = action("input swipe ${sx.coerceAtLeast(0)} ${sy.coerceAtLeast(0)} ${ex.coerceAtLeast(0)} ${ey.coerceAtLeast(0)} ${duration.coerceIn(80, 3000)}")
    fun keyEvent(code: Int): Map<String, Any?> { require(code in 0..288) { "Invalid Android key code" }; return action("input keyevent $code") }
    private fun action(command: String): Map<String, Any?> { val result = run(listOf("su", "-c", command)); return mapOf("success" to result.first, "output" to result.second.take(160)) }
    private fun run(command: List<String>): Pair<Boolean, String> = try {
        val process = ProcessBuilder(command).redirectErrorStream(true).start()
        if (!process.waitFor(5, TimeUnit.SECONDS)) { process.destroyForcibly(); false to "Command timed out" }
        else { (process.exitValue() == 0) to process.inputStream.bufferedReader().use { it.readText() } }
    } catch (error: Throwable) { false to (error.message ?: error.javaClass.simpleName) }
}
