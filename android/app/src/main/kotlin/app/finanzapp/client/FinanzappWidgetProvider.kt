package app.finanzapp.client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

// Widgets de pantalla de inicio de Finanzapp. Tres tamaños fijos (no
// redimensionables, para dimensiones precisas): chico = próximo vencimiento,
// mediano = pulso del mes, grande = lista de próximos pagos. Todos leen los
// datos que empuja HomeWidgetService desde Flutter.

private object W {
    val green = 0xFF1FB87A.toInt()
    val late = 0xFFE5604A.toInt()
    val lateInk = 0xFFFF8B72.toInt()
    val dim = 0xFF8A9590.toInt()

    fun click(context: Context) =
        HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)

    fun small(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_small)
        if (d.getBoolean("has_next", false)) {
            val overdue = d.getBoolean("next_overdue", false)
            v.setTextViewText(R.id.w_small_when, (d.getString("next_when", "") ?: "").uppercase())
            v.setTextColor(R.id.w_small_when, if (overdue) lateInk else dim)
            v.setTextViewText(R.id.w_small_name, d.getString("next_name", ""))
            v.setTextViewText(R.id.w_small_amount, d.getString("next_amount", ""))
        } else {
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
        v.setTextViewText(R.id.w_period, (d.getString("period", "") ?: "").uppercase())
        v.setTextViewText(R.id.w_falta, d.getString("falta", "—"))
        v.setTextViewText(R.id.w_progress_label, d.getString("progress_label", ""))
        val pct = d.getInt("progress_percent", 0)
        v.setTextViewText(R.id.w_percent, "$pct%")
        v.setProgressBar(R.id.w_progress, 100, pct, false)
        v.setOnClickPendingIntent(R.id.widget_root, click(context))
        return v
    }

    fun list(context: Context, d: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_list)
        v.setTextViewText(R.id.w_list_period, (d.getString("period", "") ?: "").uppercase())
        v.setTextViewText(R.id.w_list_total, d.getString("falta", "—"))

        val count = d.getInt("upcoming_count", 0)
        val rows = intArrayOf(R.id.r0, R.id.r1, R.id.r2, R.id.r3)
        val texts = intArrayOf(R.id.r0_text, R.id.r1_text, R.id.r2_text, R.id.r3_text)
        val amounts = intArrayOf(R.id.r0_amount, R.id.r1_amount, R.id.r2_amount, R.id.r3_amount)
        for (i in rows.indices) {
            if (i < count) {
                v.setViewVisibility(rows[i], View.VISIBLE)
                val name = d.getString("item${i}_name", "") ?: ""
                val whenLabel = d.getString("item${i}_when", "") ?: ""
                v.setTextViewText(texts[i], "$name · $whenLabel")
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
