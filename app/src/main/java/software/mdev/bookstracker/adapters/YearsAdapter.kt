package software.mdev.bookstracker.adapters

import android.content.Context
import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.RecyclerView
import com.google.gson.Gson
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_book.view.*
import kotlinx.android.synthetic.main.item_filter_year.view.*
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import java.util.*

class YearsAdapter(

    var context: Context,
    var listActivity: ListActivity

) : RecyclerView.Adapter<YearsAdapter.YearViewHolder>() {
    inner class YearViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    private val differCallback = object : DiffUtil.ItemCallback<String>() {
        override fun areItemsTheSame(oldItem: String, newItem: String): Boolean {
            return oldItem == newItem
        }

        override fun areContentsTheSame(oldItem: String, newItem: String): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): YearViewHolder {
        return YearViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.item_filter_year, parent, false)
        )
    }

    private var onYearClickListener: ((String) -> Unit)? = null

    override fun onBindViewHolder(holder: YearViewHolder, position: Int) {
        val curYear = differ.currentList[position]
        holder.itemView.apply {
            tvFilterYear.text = curYear

            cbFilterYear.isClickable = false

            val sharedPref = (listActivity).getSharedPreferences(
                Constants.SHARED_PREFERENCES_NAME,
                Context.MODE_PRIVATE
            )
            val editor = sharedPref.edit()

            // Check shared preferences to see if checkbox should be ticked
            var gson1 = Gson()
            var emptyArray1: Array<String> =
                arrayOf(Calendar.getInstance().get(Calendar.YEAR).toString())
            var jsonString1 = gson1.toJson(emptyArray1)
            jsonString1 =
                sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString1)
            var currentArray1 = gson1.fromJson(jsonString1, Array<String>::class.java).toList()
            if (curYear in currentArray1) {
                cbFilterYear.isChecked = true
                tvFilterYear.setTextColor(getAccentColor(context))
                tvFilterYear.setTypeface(null, Typeface.BOLD)
            }

            clFilterDialog.setOnClickListener {
                var gson = Gson()
                var emptyArray: Array<String> =
                    arrayOf(Calendar.getInstance().get(Calendar.YEAR).toString())
                var jsonString = gson.toJson(emptyArray)

                jsonString =
                    sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString)
                var currentArray = gson.fromJson(jsonString, Array<String>::class.java).toList()

                if (cbFilterYear.isChecked) {
                    cbFilterYear.isChecked = false
                    tvFilterYear.setTextColor(ContextCompat.getColor(context, R.color.grey))
                    tvFilterYear.setTypeface(null, Typeface.NORMAL)

                    if (curYear in currentArray) {
                        currentArray = currentArray.minusElement(curYear)
                        jsonString = gson.toJson(currentArray)
                        editor.putString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString)
                        editor.apply()
                    }
                } else {
                    cbFilterYear.isChecked = true
                    tvFilterYear.setTextColor(getAccentColor(context))
                    tvFilterYear.setTypeface(null, Typeface.BOLD)

                    if (curYear !in currentArray) {
                        currentArray += curYear
                        jsonString = gson.toJson(currentArray)
                        editor.putString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString)
                        editor.apply()
                    }
                }

                jsonString =
                    sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString)
                currentArray = gson.fromJson(jsonString, Array<String>::class.java).toList()
            }
        }

        holder.itemView.apply {
            setOnClickListener {
                onYearClickListener?.let { it(curYear) }
            }
        }
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref =
            context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when (accent) {
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor =
                ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor =
                ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor =
                ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor =
                ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor =
                ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor =
                ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}