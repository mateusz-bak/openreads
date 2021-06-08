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


class SetupFragment : Fragment(R.layout.fragment_setup) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val sharedPref = (activity as ListActivity).getSharedPreferences("appPref", Context.MODE_PRIVATE)

        if(sharedPref.getBoolean("app_launched", false)) {
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
        val sharedPref = (activity as ListActivity).getSharedPreferences("appPref", Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        editor.apply {
            putBoolean("app_launched", true)
            apply()
        }
    }
}