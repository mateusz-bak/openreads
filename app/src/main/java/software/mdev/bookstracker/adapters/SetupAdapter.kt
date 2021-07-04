package software.mdev.bookstracker.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.Navigation.findNavController
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_setup.view.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity

class SetupAdapter(
    private val activity: ListActivity,
    private val images: List<Int>,
    private val appVersion: String

) : RecyclerView.Adapter<SetupAdapter.ViewPagerViewHolder>() {
    inner class ViewPagerViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewPagerViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_setup, parent, false)

        view.fabLaunchApp.setOnClickListener {
            saveAppsFirstlaunch()
            findNavController(view).navigate(R.id.action_setupFragment_to_readFragment)
        }
        return ViewPagerViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewPagerViewHolder, position: Int) {
        val curImage = images[position]
        holder.itemView.ivSetupImage.setImageResource(curImage)
        when (position) {
            0 -> {
                holder.itemView.apply {
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_0)
                    fabLaunchApp.visibility = View.GONE
                    ivSwipeHint1.visibility = View.VISIBLE
                    ivSwipeHint2.visibility = View.VISIBLE
                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_0)
                }
            }
            1 -> {
                holder.itemView.apply {
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_1)
                    fabLaunchApp.visibility = View.GONE
                    ivSwipeHint1.visibility = View.VISIBLE
                    ivSwipeHint2.visibility = View.VISIBLE
                    tvSetupSwipeHint.visibility = View.VISIBLE
                }
            }
            2 -> {
                holder.itemView.apply {
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_2)
                    fabLaunchApp.visibility = View.GONE
                    ivSwipeHint1.visibility = View.VISIBLE
                    ivSwipeHint2.visibility = View.VISIBLE
                    tvSetupSwipeHint.visibility = View.VISIBLE
                }
            }
            3 -> {
                holder.itemView.apply {
                    tvSetupText.text = resources.getText(R.string.tvWelcomeText_3)
                    fabLaunchApp.visibility = View.VISIBLE
                    ivSwipeHint1.visibility = View.GONE
                    ivSwipeHint2.visibility = View.GONE
                    tvSetupSwipeHint.text = resources.getText(R.string.tvSetupSwipeHint_1)
                }
            }
        }
    }

    override fun getItemCount(): Int {
        return images.size
    }

    private fun saveAppsFirstlaunch() {
        val sharedPref =
            (activity).getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        editor.apply {
            putBoolean(Constants.SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE, false)
            putString(Constants.SHARED_PREFERENCES_KEY_APP_VERSION, appVersion)
            apply()
        }
    }
}