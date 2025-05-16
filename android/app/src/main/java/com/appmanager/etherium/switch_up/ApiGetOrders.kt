package com.example.flutter_screentime

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Query

data class Order(
    val id: String,
    val code: String,
    val apps: List<Apps>,
    val block: List<Block>,
    val unBlock: List<UnBlock>,
)

data class Apps(
    val appId: Int,
    val bundle: String,
)

data class Block(
    val id: Int,
    val bundle: String,
)

data class UnBlock(
    val id: Int,
    val bundle: String,
)

interface RHBrasilApi {
    @GET("orders")
    fun getAllOrders(
        @Header("Authorization") token: String,
        @Query("customerId") customerId: Int,
        @Query("companyId") companyId: Int,
    ): Call<Order>
}
