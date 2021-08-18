package software.mdev.bookstracker.api

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import software.mdev.bookstracker.other.Constants
import java.util.concurrent.TimeUnit

class RetrofitInstance {
    companion object {

        var gson = GsonBuilder()
            .setLenient()
            .create()

        private val retrofit by lazy {
            val logging = HttpLoggingInterceptor()
            logging.setLevel(HttpLoggingInterceptor.Level.BODY)
            val client = OkHttpClient.Builder()
                .addInterceptor(logging)
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .build()
            Retrofit.Builder()
                .baseUrl(Constants.BASE_URL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build()
        }

        val api by lazy {
            retrofit.create(BooksAPI::class.java)
        }

        val apiOLID by lazy {
            retrofit.create(BooksOLIDAPI::class.java)
        }

        val apiAuthors by lazy {
            retrofit.create(AuthorsAPI::class.java)
        }
    }
}