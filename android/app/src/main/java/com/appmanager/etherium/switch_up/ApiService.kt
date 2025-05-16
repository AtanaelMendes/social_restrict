package com.example.flutter_screentime

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.PUT

data class OrderBlock(
    val customerId: Int,
    val orders: List<Orders>,
)

data class Orders(
    val id: Int,
    val status: Int,
)

data class AppTime(
    val customerId: Int,
    val appId: Int,
    val time: Int,
    val companyId: Int,
)

interface RHBrasilOrderApi {
    @PUT("orders")
    fun putAllOrders(
        @Header("Authorization") token: String,
        @Body orderBlock: OrderBlock,
    ): Call<Void>
}

interface RHBrasilAppTimeApi {
    @POST("customers/use")
    fun postAppTime(
        @Header("Authorization") token: String,
        @Body appTime: AppTime,
    ): Call<Void>
}
