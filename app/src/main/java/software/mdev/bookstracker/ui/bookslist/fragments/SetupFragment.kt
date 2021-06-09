package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.NavOptions
import androidx.navigation.fragment.findNavController
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.ListActivity
import kotlinx.android.synthetic.main.fragment_setup.*
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_NAME


class SetupFragment : Fragment(R.layout.fragment_setup) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val sharedPref = (activity as ListActivity).getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        if(sharedPref.getBoolean(SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE, false)) {
            val navOptions = NavOptions.Builder()
                .setPopUpTo(R.id.setupFragment, true)
                .build()
            findNavController().navigate(
                R.id.action_setupFragment_to_readFragment,
                savedInstanceState,
                navOptions
            )
        }

        fabLaunchApp.setOnClickListener{
            saveAppsFirstlaunch()
            findNavController().navigate(R.id.action_setupFragment_to_readFragment)
        }
    }

    private fun saveAppsFirstlaunch() {
        val sharedPref = (activity as ListActivity).getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        editor.apply {
            putBoolean(SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE, true)
            apply()
        }
    }
}