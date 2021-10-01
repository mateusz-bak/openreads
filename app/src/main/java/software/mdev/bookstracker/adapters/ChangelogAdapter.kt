package software.mdev.bookstracker.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import software.mdev.bookstracker.R
import kotlinx.android.synthetic.main.item_changelog.view.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


class ChangelogAdapter(
    private val versions: List<Array<String>>
) : RecyclerView.Adapter<ChangelogAdapter.ViewPagerViewHolder>() {
    inner class ViewPagerViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewPagerViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_changelog, parent, false)

        return ViewPagerViewHolder(view)
    }

    var animateCard = true

    override fun onBindViewHolder(holder: ViewPagerViewHolder, position: Int) {
        holder.itemView.apply {
            setTextViews(position, holder.itemView)
            animateCardsShowUp(position, holder.itemView)

            cvCard.setOnClickListener {
                animateCardOnClick(holder.itemView)
            }
        }
    }

    override fun getItemCount(): Int {
        return versions.size
    }

    private fun setTextViews(position: Int, itemView: View) {
        itemView.tvChangelogVer.text = versions[position][0]
        itemView.tvChangelogDate.text = versions[position][1]

        var elements = versions[position].size - 1
        var string = ""

        for (item in 2..elements) {
            var element = versions[position][item]
            string += "- $element\n"
        }
        string = string.dropLast(1)
        itemView.tvChangelog.text = string
    }

    private fun animateCardsShowUp(position: Int, itemView: View) {
        var duration = 500L + 100L*position
        var translation = 1000F + 200F*position

        if (animateCard) {
            itemView.cvCard.translationY = translation
            itemView.cvCard.animate().translationYBy(-translation).setDuration(duration).start()

            itemView.cvCard.alpha = 0F
            itemView.cvCard.visibility = View.VISIBLE

            itemView.cvCard.animate().alpha(1F).setDuration(duration).start()

            MainScope().launch {
                delay(200L)
                animateCard = false
            }
        } else {
            itemView.cvCard.alpha = 1F
            itemView.cvCard.visibility = View.VISIBLE
        }
    }

    private fun animateCardOnClick(itemView: View) {
        var animDuration = 200L
        var scaleSmall = 0.95F
        var scaleBig = 1F

        itemView.cvCard.animate().scaleX(scaleSmall).setDuration(animDuration).start()
        itemView.cvCard.animate().scaleY(scaleSmall).setDuration(animDuration).start()

        MainScope().launch {
            delay(animDuration)
            itemView.cvCard.animate().scaleX(scaleBig).setDuration(animDuration).start()
            itemView.cvCard.animate().scaleY(scaleBig).setDuration(animDuration).start()
        }
    }
}