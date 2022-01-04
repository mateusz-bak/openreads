package software.mdev.bookstracker.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import androidx.sqlite.db.SupportSQLiteQuery
import software.mdev.bookstracker.data.db.entities.Book

@Dao
interface BooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: Book)

    @Delete
    suspend fun delete(item: Book)

    @Query("SELECT * FROM Book WHERE id LIKE :id")
    fun getBook(id: Int?): LiveData<Book>

    @Query("SELECT * FROM Book WHERE item_bookIsDeleted LIKE 0")
    fun getNotDeletedBooks(): LiveData<List<Book>>

    @Query("UPDATE Book SET item_bookTitle =:bookTitle, " +
            "item_bookAuthor=:bookAuthor, " +
            "item_bookRating=:bookRating, " +
            "item_bookStatus=:bookStatus, " +
            "item_bookPriority=:bookPriority, " +
            "item_bookStartDate=:bookStartDateMs, " +
            "item_bookFinishDate=:bookFinishDateMs, " +
            "item_bookNumberOfPages=:bookNumberOfPagesInt, " +
            "item_bookTitle_ASCII=:bookTitle_ASCII, " +
            "item_bookAuthor_ASCII=:bookAuthor_ASCII, " +
            "item_bookIsDeleted=:bookIsDeleted, " +
            "item_bookCoverUrl=:bookCoverUrl, " +
            "item_bookOLID=:bookOLID, " +
            "item_bookISBN10=:bookISBN10, " +
            "item_bookISBN13=:bookISBN13, " +
            "item_bookPublishYear=:bookPublishYear, " +
            "item_bookIsFav=:bookIsFav, " +
            "item_bookCoverImg=:bookCoverImg, " +
            "item_bookNotes=:bookNotes, " +
            "item_bookTags=:bookTags " +
            "WHERE id=:id")
    suspend fun updateBook(id: Int?,
                           bookTitle: String,
                           bookAuthor: String,
                           bookRating: Float,
                           bookStatus: String,
                           bookPriority: String,
                           bookStartDateMs: String,
                           bookFinishDateMs: String,
                           bookNumberOfPagesInt: Int,
                           bookTitle_ASCII: String,
                           bookAuthor_ASCII: String,
                           bookIsDeleted: Boolean,
                           bookCoverUrl: String,
                           bookOLID: String,
                           bookISBN10: String,
                           bookISBN13: String,
                           bookPublishYear: Int,
                           bookIsFav: Boolean,
                           bookCoverImg: ByteArray?,
                           bookNotes: String,
                           bookTags: List<String>?
    )

    @Query("SELECT * FROM Book WHERE (item_bookTitle_ASCII LIKE '%' || :searchQuery || '%' OR item_bookAuthor_ASCII LIKE '%' || :searchQuery || '%' AND item_bookIsDeleted LIKE 0)")
    fun searchBooks(searchQuery: String): LiveData<List<Book>>

    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookTitle_ASCII DESC")
    fun getSortedBooksByTitleDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookTitle_ASCII ASC")
    fun getSortedBooksByTitleAsc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookAuthor_ASCII DESC")
    fun getSortedBooksByAuthorDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookAuthor_ASCII ASC")
    fun getSortedBooksByAuthorAsc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookRating DESC")
    fun getSortedBooksByRatingDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookRating ASC")
    fun getSortedBooksByRatingAsc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookNumberOfPages DESC")
    fun getSortedBooksByPagesDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookNumberOfPages ASC")
    fun getSortedBooksByPagesAsc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookStartDate DESC")
    fun getSortedBooksByStartDateDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookStartDate ASC")
    fun getSortedBooksByStartDateAsc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookFinishDate DESC")
    fun getSortedBooksByFinishDateDesc(bookStatus: String): LiveData<List<Book>>
    @Query("SELECT * FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0) ORDER BY item_bookFinishDate ASC")
    fun getSortedBooksByFinishDateAsc(bookStatus: String): LiveData<List<Book>>

    @Query("SELECT COUNT(id) FROM Book WHERE (item_bookStatus LIKE :bookStatus AND item_bookIsDeleted LIKE 0)")
    fun getBookCount(bookStatus: String): LiveData<Integer>

    @Query("SELECT * FROM Book WHERE item_bookIsDeleted LIKE 1 ORDER BY item_bookTitle_ASCII ASC")
    fun getDeletedBooks(): LiveData<List<Book>>

    // Checkpoint functionality, not yet supported in room but useful to avoid closing the db during the backup creation
    @RawQuery
    fun checkpoint(supportSQLiteQuery: SupportSQLiteQuery?): Int
}