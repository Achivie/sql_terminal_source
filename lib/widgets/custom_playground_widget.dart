import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sql_terminal/models/all_playgrounds_model.dart';
import 'package:sql_terminal/models/user_model.dart';
import 'package:sql_terminal/providers/playground_widget_provider.dart';
import 'package:sql_terminal/services/encryption_service.dart';

import '../services/constants.dart';
import '../services/keys.dart';
import '../services/styles.dart';

class CustomPlaygroundWidget extends StatefulWidget {
  const CustomPlaygroundWidget({
    super.key,
    required this.playground,
    required this.onDeleteTap,
    required this.user,
  });

  final Playground playground;
  final VoidCallback onDeleteTap;
  final UserModel user;

  @override
  State<CustomPlaygroundWidget> createState() => _CustomPlaygroundWidgetState();
}

class _CustomPlaygroundWidgetState extends State<CustomPlaygroundWidget> {
  bool _isHovered = false;
  late Color containerColor;

  @override
  void initState() {
    containerColor = AppConstants().getRandomColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isHovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          // Handle tap event here

          context.go(
            "/${EncryptionService.encrypt(widget.user.data.uid)}${AppKeys.playgroundWithoutIDRouteKey}/${EncryptionService.encrypt(widget.playground.pid)}/${widget.playground.pName}",
          );
        },
        child: Consumer<PlaygroundWidgetProvider>(
          builder: (ctx, val, child) {
            return AnimatedContainer(
              padding: EdgeInsets.all(10),
              duration: Duration(
                milliseconds: 200,
              ),
              decoration: BoxDecoration(
                color: _isHovered ? AppColors.white : containerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playground.pName,
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        "Last Edited:",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          AppConstants.lastEditedString(
                              widget.playground.pLastEdited),
                          style: TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Text(
                      widget.playground.commands.trim().isEmpty
                          ? ""
                          : "Commands: ${widget.playground.commands}",
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Spacer(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     IconButton(
                  //       onPressed: widget.onDeleteTap,
                  //       icon: Icon(
                  //         Icons.delete_rounded,
                  //         color: AppColors.black,
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
