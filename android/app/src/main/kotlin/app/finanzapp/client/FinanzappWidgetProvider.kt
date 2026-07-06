package app.finanzapp.client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

// Widgets de pantalla de inicio de Finanzapp. Enfoque: urgencia + color +
// accionable. Chico = qué pagar ya, mediano = esta semana (anillo de
// progreso), grande = agenda con puntos de urgencia.

private object W {
    val green = 0xFF1FB87A.toInt()
    val amber = 0xFFEFA83A.toInt()
    val red = 0xFFE5604A.toInt()
    val redInk = 0xFFFF8B72.toInt()
    val amberInk = 0xFFF2B84B.toInt()
    val dim = 0xFF8A9590.toInt()
    val track = 0xFF1F2A26.toInt()
    val text = 0xFFE8EDEA.toInt()

    fun dotColor(u: Int) = when (u) { 2 -> red; 1 -> amber; else -> green }
    fun whenColor(u: Int) = when (u) { 2 -> redInk; 1 -> amberInk; else -> dim }

    fun click(context: Context) =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

    fun ring(context: Context, percent: Int): Bitmap {
        val size = (54 * context.resources.displayMetrics.density).toInt()
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val sw = size * 0.10f
        val pad = sw / 2f + 1f
        val r = RectF(pad, pad, size - pad, size - pad)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE; strokeWidth = sw; color = track
        }
        c.drawArc(r, 0f, 360f, false, trackPaint)
        val p = percent.coerceIn(0, 100)
        if (p > 0) {
            val prog = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE; strokeWidth = sw; color = green
                strokeCap = Paint.Cap.ROUND
            }
            c.drawArc(r, -90f, 360f * p / 100f, false, prog)
        }
        return bmp
    }

    fun small(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_small)
        if (d.getBoolean("has_next", false)) {
            val u = d.getInt("next_urgency", 0)
            v.setTextColor(R.id.w_small_dot, dotColor(u))
            v.setTextViewText(R.id.w_small_when, (d.getString("next_when", "") ?: "").uppercase())
            v.setTextColor(R.id.w_small_when, whenColor(u))
            v.setTextViewText(R.id.w_small_name, d.getString("next_name", ""))
            v.setTextViewText(R.id.w_small_amount, d.getString("next_amount", ""))
        } else {
            v.setTextColor(R.id.w_small_dot, green)
            v.setTextViewText(R.id.w_small_when, "ESTE MES")
            v.setTextColor(R.id.w_small_when, dim)
            v.setTextViewText(R.id.w_small_name, "Todo al día")
            v.setTextViewText(R.id.w_small_amount, d.getString("falta", "—"))
        }
        v.setOnClickPendingIntent(R.id.widget_root_small, click(context))
        return v
    }

    fun medium(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_medium)
        val pct = d.getInt("progress_percent", 0)
        v.setImageViewBitmap(R.id.w_ring, ring(context, pct))
        v.setTextViewText(R.id.w_ring_pct, "$pct%")
        val count = d.getInt("week_count", 0)
        val plural = if (count == 1) "PAGO" else "PAGOS"
        v.setTextViewText(R.id.w_week_label, if (count == 0) "ESTA SEMANA" else "ESTA SEMANA · $count $plural")
        v.setTextViewText(R.id.w_week_amount, d.getString("week_amount", "—"))
        v.setTextViewText(R.id.w_week_sub, d.getString("week_sub", ""))
        val subColor = when {
            count == 0 -> dim
            d.getBoolean("week_urgent", false) -> redInk
            else -> amberInk
        }
        v.setTextColor(R.id.w_week_sub, subColor)
        v.setOnClickPendingIntent(R.id.widget_root, click(context))
        return v
    }

    fun list(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_list)
        v.setTextViewText(R.id.w_list_period, (d.getString("period", "") ?: "").uppercase())
        v.setTextViewText(R.id.w_list_total, d.getString("falta", "—"))

        val count = d.getInt("upcoming_count", 0)
        val rows = intArrayOf(R.id.r0, R.id.r1, R.id.r2, R.id.r3)
        val dots = intArrayOf(R.id.r0_dot, R.id.r1_dot, R.id.r2_dot, R.id.r3_dot)
        val names = intArrayOf(R.id.r0_name, R.id.r1_name, R.id.r2_name, R.id.r3_name)
        val whens = intArrayOf(R.id.r0_when, R.id.r1_when, R.id.r2_when, R.id.r3_when)
        val amounts = intArrayOf(R.id.r0_amount, R.id.r1_amount, R.id.r2_amount, R.id.r3_amount)
        for (i in rows.indices) {
            if (i < count) {
                v.setViewVisibility(rows[i], View.VISIBLE)
                val u = d.getInt("item${i}_urgency", 0)
                v.setTextColor(dots[i], dotColor(u))
                v.setTextViewText(names[i], d.getString("item${i}_name", ""))
                v.setTextViewText(whens[i], d.getString("item${i}_short", ""))
                v.setTextColor(whens[i], whenColor(u))
                v.setTextViewText(amounts[i], d.getString("item${i}_amount", ""))
            } else {
                v.setViewVisibility(rows[i], View.GONE)
            }
        }
        v.setViewVisibility(R.id.w_list_empty, if (count == 0) View.VISIBLE else View.GONE)
        v.setOnClickPendingIntent(R.id.widget_root_list, click(context))
        return v
    }
}

class FinanzappSmallWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, W.small(context, widgetData))
    }
}

class FinanzappMediumWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, W.medium(context, widgetData))
    }
}

class FinanzappListWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, W.list(context, widgetData))
    }
}
