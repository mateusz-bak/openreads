package software.mdev.bookstracker.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_setup.view.*
import kotlinx.android.synthetic.main.layout_theme_selector.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import androidx.core.content.ContextCompat
import androidx.viewpager2.widget.ViewPager2
import kotlinx.coroutines.*


class SetupAdapter(
    private val activity: ListActivity,
    private val images: List<Int>,
    private val appVersion: String,
    private val context: Context,
    private val vpSetup: ViewPager2,
    private var triggerHint: Boolean = true,
    private var triggerHintArrows: Boolean = true,
    private var newTheme: String? = null

) : RecyclerView.Adapter<SetupAdapter.ViewPagerViewHolder>() {
    inner class ViewPagerViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewPagerViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_setup, parent, false)

        return ViewPagerViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewPagerViewHolder, position: Int) {
        when (position) {
            0 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_0)

                    ivSwipeHint1.visibility = View.INVISIBLE
                    ivSwipeHint2.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE
                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_0)

                    triggerHintArrows(holder, position)
                }
            }
            1 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_1)

                    ivSwipeHint1.visibility = View.INVISIBLE
                    ivSwipeHint2.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE

                    triggerHintArrows(holder, position)
                }
            }
            2 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_2)

                    ivSwipeHint1.visibility = View.INVISIBLE
                    ivSwipeHint2.visibility = View.INVISIBLE
                    tvSetupSwipeHint.visibility = View.INVISIBLE

                    triggerHintArrows(holder, position)
                }
            }
            3 -> {
                holder.itemView.apply {
                    ivSetupImage.visibility = View.GONE

                    clThemeSelector.visibility = View.VISIBLE
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_4)

                    ivSwipeHint1.visibility = View.INVISIBLE
                    ivSwipeHint2.visibility = View.INVISIBLE
                    tvSetupSwipeHint.visibility = View.INVISIBLE

                    btn1.setOnClickListener {
                        selectBtn(holder, it.btn1, position)
                        saveAppsTheme(Constants.THEME_ACCENT_BROWN_400)
                    }

                    btn2.setOnClickListener {
                        selectBtn(holder, it.btn2, position)
                        saveAppsTheme(Constants.THEME_ACCENT_CYAN_500)
                    }

                    btn3.setOnClickListener {
                        selectBtn(holder, it.btn3, position)
                        saveAppsTheme(Constants.THEME_ACCENT_GREEN_500)
                    }

                    btn4.setOnClickListener {
                        selectBtn(holder, it.btn4, position)
                        saveAppsTheme(Constants.THEME_ACCENT_LIGHT_GREEN)
                    }

                    btn5.setOnClickListener {
                        selectBtn(holder, it.btn5, position)
                        saveAppsTheme(Constants.THEME_ACCENT_LIME_500)
                    }

                    btn6.setOnClickListener {
                        selectBtn(holder, it.btn6, position)
                        saveAppsTheme(Constants.THEME_ACCENT_PINK_300)
                    }

                    btn7.setOnClickListener {
                        selectBtn(holder, it.btn7, position)
                        saveAppsTheme(Constants.THEME_ACCENT_PURPLE_500)
                    }

                    btn8.setOnClickListener {
                        selectBtn(holder, it.btn8, position)
                        saveAppsTheme(Constants.THEME_ACCENT_ORANGE_500)
                    }

                    btn9.setOnClickListener {
                        selectBtn(holder, it.btn9, position)
                        saveAppsTheme(Constants.THEME_ACCENT_TEAL_500)
                    }

                    btn10.setOnClickListener {
                        selectBtn(holder, it.btn10, position)
                        saveAppsTheme(Constants.THEME_ACCENT_YELLOW_500)
                    }
                }
            }
            4 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_3)
                    ivSwipeHint1.visibility = View.INVISIBLE
                    ivSwipeHint2.visibility = View.INVISIBLE
                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_1)

                    triggerHint(holder, position)
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return images.size
    }

    private fun selectBtn(holder: ViewPagerViewHolder, selectedBtn: View, position: Int) {
        var scaleBig = 1.3F
        var scaleSmall = 0.9F
        var listOfButtons = listOf(
            holder.itemView.btn1,
            holder.itemView.btn2,
            holder.itemView.btn3,
            holder.itemView.btn4,
            holder.itemView.btn5,
            holder.itemView.btn6,
            holder.itemView.btn7,
            holder.itemView.btn8,
            holder.itemView.btn9,
            holder.itemView.btn10,
        )

        vpSetup.isUserInputEnabled = true

        for (btn in listOfButtons) {
            if (btn == selectedBtn) {
                btn.animate().scaleX(scaleBig).setDuration(250L).start()
                btn.animate().scaleY(scaleBig).setDuration(250L).start()
            } else {
                btn.animate().scaleX(scaleSmall).setDuration(100L).start()
                btn.animate().scaleY(scaleSmall).setDuration(100L).start()
            }
        }

        triggerHintArrows(holder, position)
    }

    private fun triggerHint(holder: ViewPagerViewHolder, position: Int) {
        if (position == 3) {
            if (triggerHint) {
                triggerHint = false

                holder.itemView.tvSetupSwipeHint.alpha = 0F
                holder.itemView.tvSetupSwipeHint.visibility = View.VISIBLE
                holder.itemView.tvSetupSwipeHint.animate().setDuration(1000L).alpha(1F).start()
            }
        } else {
            holder.itemView.tvSetupSwipeHint.alpha = 0F
            holder.itemView.tvSetupSwipeHint.visibility = View.VISIBLE
            holder.itemView.tvSetupSwipeHint.animate().setStartDelay(500L).setDuration(1000L).alpha(1F).start()
        }
    }

    private fun triggerHintArrows (holder: ViewPagerViewHolder, position: Int) {
        var duration = 500L
        var startDelay = 750L
        var delay = 950L

        if (position != 3 || (position == 3 && triggerHintArrows)) {
            if (position == 3)
                triggerHintArrows = false

            if (position == 0) {
                startDelay = 750L
                delay = 950L
            }

            holder.itemView.ivSwipeHint1.alpha = 0F
            holder.itemView.ivSwipeHint2.alpha = 0F

            holder.itemView.ivSwipeHint1.visibility = View.VISIBLE
            holder.itemView.ivSwipeHint2.visibility = View.VISIBLE

            GlobalScope.launch {
                while (true) {
                    runBlocking {
                        withContext(Dispatchers.Main) {
                            holder.itemView.ivSwipeHint1.animate()
                                .setStartDelay(750L)
                                .setDuration(750L)
                                .translationXBy(-600F)
                                .withEndAction {
                                    holder.itemView.ivSwipeHint1.animate()
                                        .translationXBy(600F)
                                        .start()
                                }
                                .start()

                            holder.itemView.ivSwipeHint2.animate()
                                .setStartDelay(750L)
                                .setDuration(750L)
                                .translationXBy(-600F)
                                .withEndAction {
                                    holder.itemView.ivSwipeHint2.animate()
                                        .translationXBy(600F)
                                        .start()
                                }
                                .start()

                            holder.itemView.ivSwipeHint1.animate()
                                .setStartDelay(startDelay)
                                .setDuration(duration)
                                .alpha(1F)
                                .start()

                            holder.itemView.ivSwipeHint2.animate()
                                .setStartDelay(startDelay)
                                .setDuration(duration)
                                .alpha(1F)
                                .start()
                        }

                        delay(delay)

                        withContext(Dispatchers.Main) {
                            holder.itemView.ivSwipeHint1.animate()
                                .setDuration(duration)
                                .alpha(0F)
                                .start()

                            holder.itemView.ivSwipeHint2.animate()
                                .setDuration(duration)
                                .alpha(0F)
                                .start()
                        }

                        delay(2 * delay)
                    }
                }
            }
        }
    }

    private fun saveAppsTheme(accent: String) {
        newTheme = accent

        val sharedPref =
            (activity).getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        editor.apply {
            putString(Constants.SHARED_PREFERENCES_KEY_ACCENT, accent)
            apply()
        }
    }

    private fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor = ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor = ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor = ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor = ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}