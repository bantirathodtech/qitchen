import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget loadShimmer() {
  return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
          mainAxisExtent: 120),
      itemCount: 10,
      itemBuilder: (ctx, i) {
        return Column(
          children: [
            loadingShimmer(),
            const SizedBox(
              height: 10,
            )
          ],
        );
      });
}

Widget loadingShimmer() => Shimmer.fromColors(
      baseColor: Colors.black26,
      highlightColor: Colors.black54,
      period: const Duration(seconds: 1),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.black26,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 250,
                    height: 10,
                    color: Colors.black26,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 150,
                    height: 10,
                    color: Colors.black26,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
