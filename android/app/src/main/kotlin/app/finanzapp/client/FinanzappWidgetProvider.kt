package app.finanzapp.client

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/// Widget de pantalla de inicio de Finanzapp. Redimensionable: en tamaño
/// chico muestra el próximo vencimiento (concepto B); en mediano/grande, el
/// pulso del mes con progreso (concepto A). Lee los datos que empuja
/// HomeWidgetService desde Flutter (SharedPreferences "HomeWidgetPreferences").
class FinanzappWidgetProvider : HomeWidgetProvider() {

    private val green = 0xFF1FB87A.toInt()
    private val late = 0xFFE5604A.toInt()
    private val lateInk = 0xFFFF8B72.toInt()
    private val dim = 0xFF8A9590.toInt()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val options = appWidgetManager.getAppWidgetOptions(id)
            appWidgetManager.updateAppWidget(id, buildViews(context, widgetData, options))
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        val data = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        appWidgetManager.updateAppWidget(appWidgetId, buildViews(context, data, newOptions))
    }

    private fun buildViews(
        context: Context,
        data: SharedPreferences,
        options: Bundle,
    ): RemoteViews {
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
        return if (minWidth in 1..199) buildSmall(context, data) else buildMedium(context, data)
    }

    private fun buildMedium(context: Context, data: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_medium)
        v.setTextViewText(R.id.w_period, (data.getString("period", "") ?: "").uppercase())
        v.setTextViewText(R.id.w_falta, data.getString("falta", "—"))
        v.setTextViewText(R.id.w_progress_label, data.getString("progress_label", ""))
        val pct = data.getInt("progress_percent", 0)
        v.setTextViewText(R.id.w_percent, "$pct%")
        v.setProgressBar(R.id.w_progress, 100, pct, false)

        if (data.getBoolean("has_next", false)) {
            val overdue = data.getBoolean("next_overdue", false)
            val name = data.getString("next_name", "") ?: ""
            val whenLabel = data.getString("next_when", "") ?: ""
            v.setTextViewText(R.id.w_next_text, "$name · $whenLabel")
            v.setTextViewText(R.id.w_next_amount, data.getString("next_amount", ""))
            v.setTextColor(R.id.w_next_dot, if (overdue) late else green)
        } else {
            v.setTextViewText(R.id.w_next_text, "Todo al día este mes")
            v.setTextViewText(R.id.w_next_amount, "")
            v.setTextColor(R.id.w_next_dot, green)
        }
        v.setOnClickPendingIntent(
            R.id.widget_root,
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
        )
        return v
    }

    private fun buildSmall(context: Context, data: SharedPreferences): RemoteViews {
        val v = RemoteViews(context.packageName, R.layout.finanzapp_widget_small)
        if (data.getBoolean("has_next", false)) {
            val overdue = data.getBoolean("next_overdue", false)
            v.setTextViewText(R.id.w_small_when, (data.getString("next_when", "") ?: "").uppercase())
            v.setTextColor(R.id.w_small_when, if (overdue) lateInk else dim)
            v.setTextViewText(R.id.w_small_name, data.getString("next_name", ""))
            v.setTextViewText(R.id.w_small_amount, data.getString("next_amount", ""))
        } else {
            v.setTextViewText(R.id.w_small_when, "ESTE MES")
            v.setTextColor(R.id.w_small_when, dim)
            v.setTextViewText(R.id.w_small_name, "Todo al día")
            v.setTextViewText(R.id.w_small_amount, data.getString("falta", "—"))
        }
        v.setOnClickPendingIntent(
            R.id.widget_root_small,
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
        )
        return v
    }
}
