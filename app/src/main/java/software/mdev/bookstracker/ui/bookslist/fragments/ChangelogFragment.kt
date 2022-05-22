package software.mdev.bookstracker.ui.bookslist.fragments

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.NavOptions
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.fragment_changelog.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.adapters.ChangelogAdapter
import software.mdev.bookstracker.ui.bookslist.ListActivity

import software.mdev.bookstracker.other.Constants


class ChangelogFragment : Fragment(R.layout.fragment_changelog) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initSetupOfTextViews()
        animateViews()

        tvUpdateOk.setOnClickListener {
            saveUpdateSeen()
            navigateToBookList(savedInstanceState)
        }
    }

    private fun initSetupOfTextViews(){
        tvChangeLogTitle.alpha = 0F
        tvChangeLogSubTitle.alpha = 0F

        val string = getString(R.string.update_whats_new) + " " + getString(R.string.app_name) + "?"
        tvChangeLogSubTitle.text = string

        tvChangeLogTitle.translationY = 800F
        tvChangeLogSubTitle.translationY = 800F

        tvChangeLogTitle.visibility = View.VISIBLE
        tvChangeLogSubTitle.visibility = View.VISIBLE
    }

    private fun animateViews() {
        tvChangeLogTitle.animate().alpha(1F).setDuration(1000L).start()

        MainScope().launch {
            delay(1500L)

            if (tvChangeLogTitle != null)
                tvChangeLogTitle.animate().alpha(0F).setDuration(500L).start()

            delay(500L)
            if (tvChangeLogSubTitle != null)
                tvChangeLogSubTitle.animate().alpha(1F).setDuration(500L).start()

            if (tvChangeLogSubTitle != null)
                tvChangeLogSubTitle.animate().translationYBy(-800F).setStartDelay(500L).setDuration(500L).start()

            delay(500L)
            setupRv()

            delay(250L)
            if (context != null)
                showOkButton()
        }
    }

    private fun navigateToBookList(savedInstanceState: Bundle?) {
        val navOptions = NavOptions.Builder()
            .setPopUpTo(R.id.changelogFragment, true)
            .setExitAnim(R.anim.slide_out_left)
            .setEnterAnim(R.anim.slide_in_right)
            .build()

        findNavController().navigate(R.id.action_changelogFragment_to_booksFragment, savedInstanceState, navOptions)
    }

    private fun showOkButton() {
        tvUpdateOk.text = shuffleUpdateStrings()
        tvUpdateOk.bringToFront()
        tvUpdateOk.alpha = 0F
        tvUpdateOk.visibility = View.VISIBLE
        tvUpdateOk.animate().alpha(1F).setStartDelay(1000L).setDuration(400L).start()
        tvUpdateOk.isClickable = true

        MainScope().launch {

            delay(1300L)

            if (tvUpdateOk != null) {

                val animations = arrayOf(1F, 0.2F).map { translation ->
                    ObjectAnimator.ofFloat(tvUpdateOk, "alpha", translation).apply {
                        duration = 400
                        repeatCount = ObjectAnimator.INFINITE
                        repeatMode = ObjectAnimator.REVERSE
                    }
                }

                if (tvUpdateOk != null) {
                    delay(400L)
                    val set = AnimatorSet()
                    set.playTogether(animations)
                    set.start()
                }
            }
        }
    }

    private fun shuffleUpdateStrings(): String {
        return when ((1..10).random()) {
            2    -> getString(R.string.update_ok_2)
            3    -> getString(R.string.update_ok_3)
            4    -> getString(R.string.update_ok_4)
            5    -> getString(R.string.update_ok_5)
            6    -> getString(R.string.update_ok_6)
            7    -> getString(R.string.update_ok_7)
            8    -> getString(R.string.update_ok_8)
            9    -> getString(R.string.update_ok_9)
            10    -> getString(R.string.update_ok_10)
            else -> getString(R.string.update_ok_1)
        }
    }

    private fun setupRv() {
        if (context !=null) {
            var versions = getVersionStrings()

            val adapter = ChangelogAdapter(
                versions.reversed()
            )
            if (rvChangelog != null)
                rvChangelog.adapter = adapter
            if (rvChangelog != null)
                rvChangelog.layoutManager = LinearLayoutManager(view?.context)

            // bounce effect on the recyclerview
            if (rvChangelog != null) {
                OverScrollDecoratorHelper.setUpOverScroll(
                    rvChangelog,
                    OverScrollDecoratorHelper.ORIENTATION_VERTICAL
                )
            }
        }
    }

    private fun getVersionStrings(): List<Array<String>> {
            
        val version_1_10_0 = arrayOf(
            getString(R.string.changelog_ver_1_10_0),
            getString(R.string.changelog_date_1_10_0),
            getString(R.string.changelog_1_10_0_a),
            getString(R.string.changelog_1_10_0_b),
            getString(R.string.changelog_1_10_0_c),
            getString(R.string.changelog_1_10_0_d),
            getString(R.string.changelog_1_10_0_e)
        )

        val version_1_11_0 = arrayOf(
            getString(R.string.changelog_ver_1_11_0),
            getString(R.string.changelog_date_1_11_0),
            getString(R.string.changelog_1_11_0_a),
            getString(R.string.changelog_1_11_0_b),
            getString(R.string.changelog_1_11_0_c),
            getString(R.string.changelog_1_11_0_d),
            getString(R.string.changelog_1_11_0_e)
        )

        val version_1_12_0 = arrayOf(
            getString(R.string.changelog_ver_1_12_0),
            getString(R.string.changelog_date_1_12_0),
            getString(R.string.changelog_1_12_0_a),
            getString(R.string.changelog_1_12_0_b),
            getString(R.string.changelog_1_12_0_c),
            getString(R.string.changelog_1_12_0_d),
            getString(R.string.changelog_1_12_0_e)
        )

        val version_1_13_0 = arrayOf(
            getString(R.string.changelog_ver_1_13_0),
            getString(R.string.changelog_date_1_13_0),
            getString(R.string.changelog_1_13_0_a),
            getString(R.string.changelog_1_13_0_b),
            getString(R.string.changelog_1_13_0_c),
            getString(R.string.changelog_1_13_0_d),
            getString(R.string.changelog_1_13_0_e),
            getString(R.string.changelog_1_13_0_f),
            getString(R.string.changelog_1_13_0_g),
            getString(R.string.changelog_1_13_0_h),
            getString(R.string.changelog_1_13_0_i),
            getString(R.string.changelog_1_13_0_j),
            getString(R.string.changelog_1_13_0_k),
            getString(R.string.changelog_1_13_0_l),
            getString(R.string.changelog_1_13_0_m)
        )

        val version_1_14_0 = arrayOf(
            getString(R.string.changelog_ver_1_14_0),
            getString(R.string.changelog_date_1_14_0),
            getString(R.string.changelog_1_14_0_a),
            getString(R.string.changelog_1_14_0_b),
            getString(R.string.changelog_1_14_0_c),
            getString(R.string.changelog_1_14_0_d),
            getString(R.string.changelog_1_14_0_e),
            getString(R.string.changelog_1_14_0_f),
            getString(R.string.changelog_1_14_0_g),
            getString(R.string.changelog_1_14_0_h)
        )


        return listOf(
            version_1_10_0,
            version_1_11_0,
            version_1_12_0,
            version_1_13_0,
            version_1_14_0
        )
    }

    private fun saveUpdateSeen() {
        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        val editor = sharedPref?.edit()

        editor?.apply {
            putString(Constants.SHARED_PREFERENCES_KEY_APP_VERSION, resources.getString(R.string.app_version))
            apply()
        }
    }

    private fun getPreferenceLandingPage(context: Context): String {
        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        return sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_LANDING_PAGE,
            Constants.KEY_LANDING_PAGE_FINISHED
        ).toString()
    }
}