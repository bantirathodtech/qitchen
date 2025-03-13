import 'package:flutter/material.dart';

class HeaderContent extends StatelessWidget {
  const HeaderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Sproutz,',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Food Ordering App',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Icon(
                //   Icons.location_on_rounded,
                //   color: Colors.green,
                //   size: 16,
                // ),
                // SizedBox(width: 4),
                // Text(
                //   'Hyderabad,',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 14,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
                // SizedBox(width: 4),
                // Text(
                //   'Prathab',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 14,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
              ],
            ),
            // const Padding(
            //   padding: EdgeInsets.only(left: 20.0),
            //   child: Text(
            //     "Simply Dummy Text Of The Prin...",
            //     style: TextStyle(
            //       color: Colors.grey,
            //       fontSize: 10,
            //       fontWeight: FontWeight.w400,
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Text(
                "Search any restaurants and dishes",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // const Spacer(),
        // Container(
        //   width: 40,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFE8F5EC),
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   child: const Icon(
        //     Icons.notifications_outlined,
        //     color: Colors.green,
        //   ),
        // ),
      ],
    );
  }
}
