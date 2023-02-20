import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_app/common/const/data.dart';
import 'package:flutter_real_app/restaurant/component/restaurant_card.dart';
import 'package:flutter_real_app/restaurant/model/restaurant_model.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

  Future<List> paginateRestaraunt() async {
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final response = await dio.get(
      'http://$ip/restaurant',
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
    );

    return response.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List>(
          future: paginateRestaraunt(),
          builder: (context, AsyncSnapshot<List> snapshot) {
            if (snapshot.data == null) {
              return Container();
            }
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                final item = snapshot.data![index];
                final pItem = RestaurantModel.fromJson(
                  json: item,
                );
                return RestaurantCard(
                  image: Image.network(
                    'http://$ip${pItem.thumbUrl}',
                    fit: BoxFit.cover,
                  ),
                  name: pItem.name,
                  tags: pItem.tags,
                  ratingsCount: pItem.ratingsCount,
                  deliveryTime: pItem.deliveryTime,
                  deliveryFee: pItem.deliveryFee,
                  ratings: pItem.ratings,
                );
              },
              separatorBuilder: (_, index) {
                return const SizedBox(
                  height: 16.0,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
