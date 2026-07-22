
import 'package:flutter/material.dart';

extension WidgetEx on Widget{
  Widget get fitBox => FittedBox(fit: BoxFit.scaleDown,child: this,);
  Widget get fitFlex => Flexible(child: FittedBox(fit: BoxFit.scaleDown,child: this,));
  Widget get fitExpand => Expanded(child: FittedBox(fit: BoxFit.scaleDown,child: this,));
  Widget  constrainedBoxMaxHeight(double value) => ConstrainedBox(constraints: BoxConstraints(maxHeight: value),
  child: this,
  );
  Widget  constrainedBoxMaxWidth(double value) => ConstrainedBox(constraints: BoxConstraints(maxWidth: value),
  child: this,
  );

}