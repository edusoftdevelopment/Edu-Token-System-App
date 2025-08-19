import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldPizza extends StatefulWidget {
  const CustomTextFormFieldPizza({
    required this.hintText,
    required this.controller,
    required this.darkMode,
    this.width,
    this.height,
    this.onChanged,
    this.onSaved,
    super.key,
    this.isPassword = false,
    this.decoration,
    this.validator,
    this.sameBorder = false,
    this.borderColor,
    this.textStyle,
    this.contentPadding,
    this.insideColor,
    this.suffixIcon,
    this.borderRadius,
    this.onTap,
  }) : assert(
         sameBorder == false || borderColor != null,
         'borderColor is required when sameBorder is true',
       );
  final bool darkMode;
  final String hintText;
  final double? borderRadius;
  final bool isPassword;
  final Color? insideColor;
  final TextEditingController controller;
  final InputDecoration? decoration;
  final double? height;
  final double? width;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool? sameBorder;
  final Color? borderColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;
  final void Function()? onTap;

  @override
  State<CustomTextFormFieldPizza> createState() =>
      _CustomTextFormFieldPizzaState();
}

class _CustomTextFormFieldPizzaState extends State<CustomTextFormFieldPizza> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height, // Height ko uncomment kiya gaya hai
      child: TextFormField(
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.left,
        onTap: widget.onTap ?? () {},
        validator: widget.validator,
        cursorColor: widget.darkMode ? AppColors.kWhite : AppColors.kBlack,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        controller: widget.controller,
        obscureText: widget.isPassword ? obscureText : false,
        style:
            widget.textStyle ??
            Theme.of(context).textTheme.displaySmall?.copyWith(),
        expands: widget.height != null,
        maxLines: widget.height != null ? null : 1,
        minLines: widget.height != null ? null : 1,
        decoration:
            widget.decoration ??
            InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: widget.darkMode ? AppColors.kWhite : null,
              ),
              hintText: widget.hintText,
              filled: true,
              fillColor:
                  widget.insideColor ??
                  (widget.darkMode
                      ? AppColors.kAppBarColor
                      : const Color(0xFFF9FAFB)),
              contentPadding: widget.contentPadding ?? const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                borderSide: (widget.sameBorder ?? false)
                    ? BorderSide(
                        color:
                            widget.borderColor ??
                            (widget.darkMode
                                ? AppColors.kWhite
                                : AppColors.kBlack),
                      )
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                borderSide: (widget.sameBorder ?? false)
                    ? BorderSide(
                        color:
                            widget.borderColor ??
                            (widget.darkMode
                                ? AppColors.kWhite
                                : AppColors.kBlack),
                      )
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
                borderSide: BorderSide(
                  color:
                      widget.borderColor ??
                      (widget.darkMode ? AppColors.kWhite : AppColors.kBlack),
                ),
              ),
              suffixIcon:
                  widget.suffixIcon ??
                  (widget.isPassword
                      ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: widget.darkMode
                                ? AppColors.kWhite
                                : AppColors.kGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        )
                      : null),
            ),
      ),
    );
  }
}