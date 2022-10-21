import 'package:honey/src/compiler/antlr.dart';
import 'package:honey/src/models/expression/expression.dart';

class LiteralVisitor extends HoneyTalkBaseVisitor<ValueExp> {
  @override
  ValueExp visitLiteralCardinal(LiteralCardinalContext ctx) {
    switch (ctx.cardinalValue()!.text) {
      case 'zero':
        return ValueExp(0);
      case 'one':
        return ValueExp(1);
      case 'two':
        return ValueExp(2);
      case 'three':
        return ValueExp(3);
      case 'four':
        return ValueExp(4);
      case 'five':
        return ValueExp(5);
      case 'six':
        return ValueExp(6);
      case 'seven':
        return ValueExp(7);
      case 'eight':
        return ValueExp(8);
      case 'nine':
        return ValueExp(9);
      case 'ten':
        return ValueExp(10);
      default:
        throw StateError(
          'Unrecognized cardinal literal: ${ctx.cardinalValue()}',
        );
    }
  }

  @override
  ValueExp visitLiteralString(LiteralStringContext ctx) {
    final strRaw = ctx.STRING_LITERAL()!.text!;
    final str = strRaw.substring(1, strRaw.length - 1);
    return ValueExp(str);
  }

  @override
  ValueExp visitLiteralRegex(LiteralRegexContext ctx) {
    final strRaw = ctx.REGEX_LITERAL()!.text!;
    final str = strRaw.split('/');
    return ValueExp.str(str[1], regexFlags: str.length == 3 ? str[2] : null);
  }

  @override
  ValueExp visitLiteralNumber(LiteralNumberContext ctx) {
    final str = ctx.NUMBER_LITERAL()!.text!;
    return ValueExp(str);
  }

  @override
  ValueExp visitLiteralBool(LiteralBoolContext ctx) {
    final str = ctx.BOOL_LITERAL()!.text!;
    return ValueExp(str);
  }
}