import retrofit2.Call
import retrofit2.http.Field
import retrofit2.http.FormUrlEncoded
import retrofit2.http.POST

interface ApiService {
    @FormUrlEncoded
    @POST("app/endereco/carrega-cep-endereco.php")
    fun fetchData(
        @Field("endereco") endereco: String,
        @Field("tipoCEP") tipoCEP: String
    ): Call<String>
}