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
import kotlinx.android.synthetic.main.fragment_setup.*
import software.mdev.bookstracker.ui.bookslist.fragments.SetupFragment


class SetupAdapter(
    private val activity: ListActivity,
    private val images: List<Int>,
    private val appVersion: String,
    private val context: Context,
    private val vpSetup: ViewPager2,
    private val setupFragment: SetupFragment,
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
                    val param = ivSetupImage.layoutParams as ViewGroup.MarginLayoutParams
                    param.width = 450
                    param.height = 450
                    ivSetupImage.layoutParams = param

                    ivSetupImage.setImageResource(images[position])

                    var string = resources.getString(R.string.tvWelcomeText_0) + " " +resources.getString(R.string.app_name)

                    tvSetupText.text = string
                    tvSetupText.textSize = 20F
                    tvSetupVersion.visibility = View.VISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE
                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_0)
                }
            }
            1 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    viewSlideDown(ivSetupImage)
                    viewSlideUp(tvSetupText)

                    var string = resources.getString(R.string.app_name) + " " + resources.getString(R.string.tvWelcomeText_1)
                    tvSetupText.text = string
                    tvSetupVersion.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE
                }
            }
            2 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    viewSlideLeft(ivSetupImage)
                    viewSlideRight(tvSetupText)

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_2)
                    tvSetupVersion.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE
                }
            }
            3 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    viewSlideLeft(tvSetupText)
                    viewSlideRight(ivSetupImage)

                    var string = resources.getString(R.string.app_name) + " " + resources.getString(R.string.tvWelcomeText_3)
                    tvSetupText.text = string
                    tvSetupVersion.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE
                }
            }
            4 -> {
                holder.itemView.apply {
                    ivSetupImage.visibility = View.GONE

                    clThemeSelector.visibility = View.VISIBLE
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_4)
                    tvSetupVersion.visibility = View.INVISIBLE

                    tvSetupSwipeHint.visibility = View.INVISIBLE

                    btn1.setOnClickListener {
                        selectBtn(holder, it.btn1, position)
                        saveAppsTheme(Constants.THEME_ACCENT_BROWN_400, holder.itemView.getContext())
                    }

                    btn2.setOnClickListener {
                        selectBtn(holder, it.btn2, position)
                        saveAppsTheme(Constants.THEME_ACCENT_CYAN_500, holder.itemView.getContext())
                    }

                    btn3.setOnClickListener {
                        selectBtn(holder, it.btn3, position)
                        saveAppsTheme(Constants.THEME_ACCENT_GREEN_500, holder.itemView.getContext())
                    }

                    btn4.setOnClickListener {
                        selectBtn(holder, it.btn4, position)
                        saveAppsTheme(Constants.THEME_ACCENT_LIGHT_GREEN, holder.itemView.getContext())
                    }

                    btn5.setOnClickListener {
                        selectBtn(holder, it.btn5, position)
                        saveAppsTheme(Constants.THEME_ACCENT_LIME_500, holder.itemView.getContext())
                    }

                    btn6.setOnClickListener {
                        selectBtn(holder, it.btn6, position)
                        saveAppsTheme(Constants.THEME_ACCENT_PINK_300, holder.itemView.getContext())
                    }

                    btn7.setOnClickListener {
                        selectBtn(holder, it.btn7, position)
                        saveAppsTheme(Constants.THEME_ACCENT_PURPLE_500, holder.itemView.getContext())
                    }

                    btn8.setOnClickListener {
                        selectBtn(holder, it.btn8, position)
                        saveAppsTheme(Constants.THEME_ACCENT_ORANGE_500, holder.itemView.getContext())
                    }

                    btn9.setOnClickListener {
                        selectBtn(holder, it.btn9, position)
                        saveAppsTheme(Constants.THEME_ACCENT_TEAL_500, holder.itemView.getContext())
                    }

                    btn10.setOnClickListener {
                        selectBtn(holder, it.btn10, position)
                        saveAppsTheme(Constants.THEME_ACCENT_YELLOW_500, holder.itemView.getContext())
                    }
                }
            }
            5 -> {
                holder.itemView.apply {
                    ivSetupImage.setImageResource(images[position])

                    viewSlideDown(ivSetupImage)
                    viewSlideUp(tvSetupText)

                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_5)
                    tvSetupText.textSize = 20F
                    tvSetupVersion.visibility = View.INVISIBLE

                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_1)

                    triggerHint(holder, position)
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return images.size
    }

    private fun viewSlideDown(view: View) {
        view.alpha = 0F
        view.animate().alpha(1F).setDuration(750L).start()

        view.translationY = -1000F
        view.animate().translationYBy(1000F).setStartDelay(100L).setDuration(500L).start()
    }

    private fun viewSlideUp(view: View) {
        view.alpha = 0F
        view.animate().alpha(1F).setDuration(750L).start()

        view.translationY = 1000F
        view.animate().translationYBy(-1000F).setStartDelay(100L).setDuration(500L).start()
    }

    private fun viewSlideLeft(view: View) {
        view.alpha = 0F
        view.animate().alpha(1F).setDuration(750L).start()

        view.translationX = 1000F
        view.animate().translationXBy(-1000F).setStartDelay(100L).setDuration(500L).start()
    }

    private fun viewSlideRight(view: View) {
        view.alpha = 0F
        view.animate().alpha(1F).setDuration(750L).start()

        view.translationX = -1000F
        view.animate().translationXBy(1000F).setStartDelay(100L).setDuration(500L).start()
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
        setupFragment.tvNext.visibility = View.VISIBLE

        for (btn in listOfButtons) {
            if (btn == selectedBtn) {
                btn.animate().scaleX(scaleBig).setDuration(250L).start()
                btn.animate().scaleY(scaleBig).setDuration(250L).start()

                btn.animate().alpha(1F).setDuration(100L).start()
            } else {
                btn.animate().scaleX(scaleSmall).setDuration(100L).start()
                btn.animate().scaleY(scaleSmall).setDuration(100L).start()

                btn.animate().alpha(0.6F).setDuration(100L).start()
            }
        }
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

    private fun saveAppsTheme(accent: String, context: Context) {
        newTheme = accent

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = (activity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        editor.apply {
            putString(Constants.SHARED_PREFERENCES_KEY_ACCENT, accent)
            apply()
        }
    }

    private fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

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