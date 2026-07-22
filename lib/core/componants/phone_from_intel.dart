import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:res_reline/my_responsive.dart';
import 'package:boker/core/config/language/language_manager.dart';

class MyPhoneFromField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(PhoneNumber? phone, String formattedPhoneNumber)?
  onChanged; // Callback to return the updated phone number
  final PhoneNumber? initPhone;
  final bool withValidator;
  final double? borderRadius;
  final Color? enableBorderColor;
  final String? label;
  final String? hint;
  final ResHelper? res;
  MyPhoneFromField({
    super.key,
    this.controller,
    this.onChanged,
    String? initPhone,
    this.withValidator = true,
    this.label,
    this.hint,
    this.borderRadius,
    this.enableBorderColor, this.res,
  }) : initPhone =
           ((initPhone?.isNotEmpty ?? false) &&
               initPhone!.split("-").length >= 3)
           ? PhoneNumber(
               countryISOCode: initPhone.split("-")[0],
               countryCode: initPhone.split("-")[1],
               number: initPhone.split("-")[2],
             )
           : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
  final res = this.res ?? MyRes.of(context);
    return IntlPhoneField(
      initialCountryCode: initPhone?.countryISOCode ?? "OM",
      initialValue: initPhone?.number,
      showDropdownIcon: false,
      enableDropDown:false,
      showCountryFlag: false,
      invalidNumberMessage : 'Invalid Mobile Number'.tran,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style:  Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14.h
    ),
      flagsButtonPadding:  EdgeInsets.symmetric(horizontal: 14.h),
      dropdownTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14.h
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'Phone Number'.tran,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14.h
        ),
        errorMaxLines: 1,

        hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.h
        ),
        errorStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.red,
            fontSize: 14.h
        ),
        counterStyle:   Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.h
      ),

        contentPadding:  EdgeInsets.symmetric(
          horizontal: 16.h,
          vertical: 14.h,
        ),
        counter: const SizedBox.shrink(),
      ),
      validator: withValidator
          ? (phone) {
              try {
                final isValid = phone?.isValidNumber() ?? false;
                if (!isValid) {
                  return "Invalid phone number".tran;
                }
                return null;
              } catch (e) {
                if (e is NumberTooShortException) {
                  return "Number is short".tran;
                }
                if (e is NumberTooLongException) {
                  return "Number is long".tran;
                }
                return e.toString();
              }
            }
          : null,
      languageCode: "en",
      keyboardType: TextInputType.phone,
      onChanged: (phone) {
        final resul =
            "${phone.countryISOCode}-${phone.countryCode}-${phone.number}";
        controller?.text = resul;
        onChanged?.call(phone, resul);
      },
      onCountryChanged: (country) {
        initPhone?.countryISOCode = country.name;
      },
      onSaved: (newValue) {
        print("object ====");
      },
    );
  }
}