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
import software.mdev.bookstracker.adapters.SetupAdapter
import software.mdev.bookstracker.other.Constants


class SetupFragment : Fragment(R.layout.fragment_setup) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val sharedPref = (activity as ListActivity).getSharedPreferences(
            Constants.SHARED_PREFERENCES_NAME,
            Context.MODE_PRIVATE
        )

        if (!sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE, true) &&
            sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_APP_VERSION, "v0.0.0") ==
            resources.getString(R.string.app_version)
        ) {
            val navOptions = NavOptions.Builder()
                .setPopUpTo(R.id.setupFragment, true)
                .build()
            findNavController().navigate(
                R.id.action_setupFragment_to_readFragment,
                savedInstanceState,
                navOptions
            )
        }

        val images = listOf(
            R.drawable.ic_svg_books,
            R.drawable.ic_svg_study,
            R.drawable.ic_svg_presentation,
            R.drawable.ic_svg_like
        )

        val adapter = SetupAdapter(
            activity as ListActivity,
            images,
            resources.getString(R.string.app_version)
        )
        vpSetup.adapter = adapter
    }
}