
import 'package:flutter/material.dart';
import '../util/dimensions.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({super.key, this.label, this.onTap});

  final String? label;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
            side:  BorderSide(color: Colors.white,)),
        leading: Text(label!,
          //   style: cairoBold.copyWith(
          // color: Theme.of(context).primaryColor,
          // fontSize: Dimensions.fontSizeLarge

        )),
        // trailing: const Icon(Icons.arrow_forward_ios,color: Color(0xff047940)),

    );
  }
}
