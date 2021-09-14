package software.mdev.bookstracker.other

import android.content.Context
import com.github.javiersantos.appupdater.AppUpdater
import com.github.javiersantos.appupdater.enums.Display
import com.github.javiersantos.appupdater.enums.UpdateFrom
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import software.mdev.bookstracker.R


class Updater {

    fun checkForAppUpdate(context: Context, showAppUpdated: Boolean) = CoroutineScope(Dispatchers.Main).launch {
        var appUpdater = AppUpdater(context)
        appUpdater
            .setTitleOnUpdateAvailable(context.getString(R.string.setTitleOnUpdateAvailable))
            .setContentOnUpdateAvailable(context.getString(R.string.setContentOnUpdateAvailable_gplay))
            .setButtonUpdate(context.getString(R.string.setButtonUpdate))
            .setButtonDismiss(context.getString(R.string.setButtonDismiss))
            .setButtonDoNotShowAgain(context.getString(R.string.setButtonDoNotShowAgain))
            .setContentOnUpdateNotAvailable(context.getString(R.string.setContentOnUpdateNotAvailable_gplay))
            .setTitleOnUpdateNotAvailable(context.getString(R.string.setTitleOnUpdateNotAvailable))
            .setUpdateFrom(UpdateFrom.GOOGLE_PLAY)
            .setDisplay(Display.DIALOG)
            .showAppUpdated(showAppUpdated)
            .start()
    }
}